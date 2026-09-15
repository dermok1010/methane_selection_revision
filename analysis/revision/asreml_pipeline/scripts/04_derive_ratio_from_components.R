#!/usr/bin/env Rscript
# Derives each composite methane trait's heritability from the genetic and
# phenotypic (co)variances of its own underlying biological components --
# NOT a selection index or a complete cross-trait covariance structure.
# Scope explicitly narrowed by the user (2026-09-15): only the bivariate
# pairs a given composite trait actually needs are fit; pairwise
# correlations among the derived traits themselves, and any multivariate/
# selection-index work, are deferred to a later, separate task.
#
# Composite trait -> components required (see config/models.yaml's
# component_set for the exact bivariate pairs this implies):
#   MI (CH4/MBW), RMTMBW        -> CH4, MBW
#   CH4 ratio                   -> CH4, CO2
#   CH4/ADG, RMTADG             -> CH4, ADG
#   CH4/MM                      -> CH4, muscle
#   CH4/rumen                   -> CH4, rumen
#   CH4/LW                      -> CH4, weight (liveweight)
#   RMTMBW+CO2                  -> CH4, MBW, CO2 (needs CH4-MBW, CH4-CO2
#                                  AND MBW-CO2)
#
# Method:
#   Linear (residual) traits: for T = c'x (x = the relevant component
#   sub-vector, c fixed, e.g. c=(1,-b) for CH4-b*MBW), V_A(T)=c'Gc,
#   V_P(T)=c'Pc exactly -- no approximation, since T is by construction
#   linear in x. For RMTMBW+CO2, x=(CH4,MBW,CO2), c=(1,-b1,-b2), and G/P
#   are the 3x3 blocks assembled from the three pairwise bivariate fits.
#
#   Nonlinear (ratio) traits: for Q=f(x) e.g. CH4/MBW, first-order Taylor/
#   delta-method linearisation around the sample means, g=grad f(mean(x)),
#   V_A(Q)\approx g'Gg, V_P(Q)\approx g'Pg. Identical gradient already used
#   for real in the upstream Methane_Selection_Index_Analysis repo (commit
#   fb1f0a2cddb82ba322cfd86b4ad3d99830385a44: index_weight_methane.R:111-116,
#   MC_weight.R:169-174), extended from "selection response" to
#   "heritability" -- not a new derivation. CH4/(CH4+CO2) uses the direct
#   two-variable gradient wrt (CH4,CO2): dQ/dCH4=CO2/(CH4+CO2)^2,
#   dQ/dCO2=-CH4/(CH4+CO2)^2.
#
# Inputs: results/univariate_summary.csv (7 rows -- each trait's own
# variance) and results/bivariate_summary.csv (7 rows -- the pairwise
# covariances above), both from 03_parse_results.R on the --set=components
# run. Trait means come directly from data/phenotype_asreml.csv (the
# linearisation point for ratio gradients).
#
# Residual coefficients (b): recalculated from this pipeline's own cleaned
# dataset by 00_prepare_asreml_phenotype.R (RMTMBW b=0.7722; RMTMBW+CO2
# b1=0.1591/b2=0.00907 from the JOINT regression CH4~MBW+CO2, not two
# separate simple regressions; RMTADG b=2.9920). Independently cross-
# checked against the original manuscript-scale dataset
# (~/PAC_data_pipeline/data/external/paper3/P3_co2_data.csv, 15,869
# records, exact manuscript match): legacy b=0.77217, b1/b2=0.1590647/
# 0.00907138, b=2.991979 -- agree to 4 decimal places, so both are
# reported but there is no material discrepancy to resolve.

suppressPackageStartupMessages({})

pipeline_root <- normalizePath(
  file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE))), ".."),
  mustWork = FALSE
)
if (!dir.exists(file.path(pipeline_root, "results"))) pipeline_root <- getwd()
results_dir <- file.path(pipeline_root, "results")

uni_path <- file.path(results_dir, "univariate_summary.csv")
bi_path <- file.path(results_dir, "bivariate_summary.csv")
if (!file.exists(uni_path) || !file.exists(bi_path)) {
  stop("results/univariate_summary.csv and/or bivariate_summary.csv not found -- ",
       "run 03_parse_results.R on HPC output for the --set=components (or ",
       "--set=components_trial) models first.")
}
uni <- read.csv(uni_path, stringsAsFactors = FALSE)
bi <- read.csv(bi_path, stringsAsFactors = FALSE)

pheno <- read.csv(file.path(pipeline_root, "data", "phenotype_asreml.csv"))
VARCOL <- c(methane = "ch4_g_day2_1v3", mbw = "Metabolic_BW", weight = "weight",
            adg = "adg", co2 = "co2_g_day2_1v3", muscle = "ct_muscle_kg", rumen = "rumen")
mu <- setNames(sapply(VARCOL, function(v) mean(pheno[[v]], na.rm = TRUE)), names(VARCOL))

get_uni <- function(code) {
  row <- uni[uni$trait_code == code, ]
  if (nrow(row) != 1) stop("Expected exactly one univariate_summary.csv row for '", code, "'")
  list(VA = row$sigma_ped, VP = row$sigma_ped + row$sigma_ide + row$sigma_residual,
       convergence = row$convergence)
}
get_bi <- function(a, b) {
  row <- bi[bi$pair %in% c(paste0(a, "_", b), paste0(b, "_", a)), ]
  if (nrow(row) != 1) stop("Expected exactly one bivariate_summary.csv row for pair '", a, "-", b, "'")
  # sigma_ped_c/sigma_res_c are covariances -- symmetric regardless of
  # which of the pair was fit as trait 1 vs trait 2.
  list(CovA = row$sigma_ped_c,
       CovP = row$sigma_res_c + row$sigma_ped_c,  # ide(ANI_ID) is shared,
       # not trait-specific (config/models.yaml's random_effects comment),
       # so it has no separately estimated covariance term to add here --
       # matches 03_parse_results.R's own convention.
       convergence = row$convergence)
}

not_conv <- character(0)
check_conv <- function(label, convergence) if (convergence != "CONVERGED") not_conv <<- c(not_conv, paste0(label, " (", convergence, ")"))

ch4 <- get_uni("methane"); check_conv("methane", ch4$convergence)

# ---------------------------------------------------------------------
# Residual coefficients (see header)
# ---------------------------------------------------------------------
B_MBW <- 0.7722; B_MBW_LEGACY <- 0.77217
B_MBWCO2 <- c(mbw = 0.1591, co2 = 0.00907); B_MBWCO2_LEGACY <- c(mbw = 0.1590647, co2 = 0.00907138)
B_ADG <- 2.9920; B_ADG_LEGACY <- 2.991979

# ---------------------------------------------------------------------
# One row per composite trait: builds its own small G/P block from just
# the component(s) it needs, applies the linear-combination or ratio-
# gradient formula, and records the underlying component estimates used
# so the derivation is fully auditable alongside the result.
# ---------------------------------------------------------------------

ratio_result <- function(code, label, comp_code) {
  comp <- get_uni(comp_code); check_conv(comp_code, comp$convergence)
  pair <- get_bi("methane", comp_code); check_conv(paste0("methane-", comp_code), pair$convergence)
  mu_x <- mu[["methane"]]; mu_y <- mu[[comp_code]]
  a1 <- 1 / mu_y; a2 <- -mu_x / mu_y^2
  VA <- a1^2 * ch4$VA + 2 * a1 * a2 * pair$CovA + a2^2 * comp$VA
  VP <- a1^2 * ch4$VP + 2 * a1 * a2 * pair$CovP + a2^2 * comp$VP
  data.frame(trait = code, label = label, type = "ratio", h2 = VA / VP, VA = VA, VP = VP,
             VA_ch4 = ch4$VA, VP_ch4 = ch4$VP, VA_comp1 = comp$VA, VP_comp1 = comp$VP,
             CovA_ch4_comp1 = pair$CovA, CovP_ch4_comp1 = pair$CovP,
             VA_comp2 = NA, VP_comp2 = NA, CovA_ch4_comp2 = NA, CovP_ch4_comp2 = NA,
             CovA_comp1_comp2 = NA, CovP_comp1_comp2 = NA, stringsAsFactors = FALSE)
}

ratio2_result_ch4ratio <- function() {
  co2 <- get_uni("co2"); check_conv("co2", co2$convergence)
  pair <- get_bi("methane", "co2"); check_conv("methane-co2", pair$convergence)
  mu_x <- mu[["methane"]]; mu_y <- mu[["co2"]]
  denom <- (mu_x + mu_y)^2
  a1 <- mu_y / denom; a2 <- -mu_x / denom
  VA <- a1^2 * ch4$VA + 2 * a1 * a2 * pair$CovA + a2^2 * co2$VA
  VP <- a1^2 * ch4$VP + 2 * a1 * a2 * pair$CovP + a2^2 * co2$VP
  data.frame(trait = "ch4ratio", label = "CH4/(CH4+CO2)", type = "ratio2", h2 = VA / VP, VA = VA, VP = VP,
             VA_ch4 = ch4$VA, VP_ch4 = ch4$VP, VA_comp1 = co2$VA, VP_comp1 = co2$VP,
             CovA_ch4_comp1 = pair$CovA, CovP_ch4_comp1 = pair$CovP,
             VA_comp2 = NA, VP_comp2 = NA, CovA_ch4_comp2 = NA, CovP_ch4_comp2 = NA,
             CovA_comp1_comp2 = NA, CovP_comp1_comp2 = NA, stringsAsFactors = FALSE)
}

linear_result_1cov <- function(code, label, comp_code, b) {
  comp <- get_uni(comp_code); check_conv(comp_code, comp$convergence)
  pair <- get_bi("methane", comp_code); check_conv(paste0("methane-", comp_code), pair$convergence)
  VA <- ch4$VA + b^2 * comp$VA - 2 * b * pair$CovA
  VP <- ch4$VP + b^2 * comp$VP - 2 * b * pair$CovP
  data.frame(trait = code, label = label, type = "linear", h2 = VA / VP, VA = VA, VP = VP,
             VA_ch4 = ch4$VA, VP_ch4 = ch4$VP, VA_comp1 = comp$VA, VP_comp1 = comp$VP,
             CovA_ch4_comp1 = pair$CovA, CovP_ch4_comp1 = pair$CovP,
             VA_comp2 = NA, VP_comp2 = NA, CovA_ch4_comp2 = NA, CovP_ch4_comp2 = NA,
             CovA_comp1_comp2 = NA, CovP_comp1_comp2 = NA, stringsAsFactors = FALSE)
}

linear_result_rmtmbwco2 <- function() {
  mbw <- get_uni("mbw"); check_conv("mbw", mbw$convergence)
  co2 <- get_uni("co2"); check_conv("co2", co2$convergence)
  p_ch4_mbw <- get_bi("methane", "mbw"); check_conv("methane-mbw", p_ch4_mbw$convergence)
  p_ch4_co2 <- get_bi("methane", "co2"); check_conv("methane-co2", p_ch4_co2$convergence)
  p_mbw_co2 <- get_bi("mbw", "co2"); check_conv("mbw-co2", p_mbw_co2$convergence)

  c_vec <- c(1, -B_MBWCO2["mbw"], -B_MBWCO2["co2"])
  G3 <- matrix(c(ch4$VA,        p_ch4_mbw$CovA, p_ch4_co2$CovA,
                 p_ch4_mbw$CovA, mbw$VA,        p_mbw_co2$CovA,
                 p_ch4_co2$CovA, p_mbw_co2$CovA, co2$VA), 3, 3)
  P3 <- matrix(c(ch4$VP,        p_ch4_mbw$CovP, p_ch4_co2$CovP,
                 p_ch4_mbw$CovP, mbw$VP,        p_mbw_co2$CovP,
                 p_ch4_co2$CovP, p_mbw_co2$CovP, co2$VP), 3, 3)
  VA <- as.numeric(t(c_vec) %*% G3 %*% c_vec)
  VP <- as.numeric(t(c_vec) %*% P3 %*% c_vec)
  data.frame(trait = "ch4rmtmbwco2", label = "RMTMBW+CO2", type = "linear", h2 = VA / VP, VA = VA, VP = VP,
             VA_ch4 = ch4$VA, VP_ch4 = ch4$VP, VA_comp1 = mbw$VA, VP_comp1 = mbw$VP,
             CovA_ch4_comp1 = p_ch4_mbw$CovA, CovP_ch4_comp1 = p_ch4_mbw$CovP,
             VA_comp2 = co2$VA, VP_comp2 = co2$VP,
             CovA_ch4_comp2 = p_ch4_co2$CovA, CovP_ch4_comp2 = p_ch4_co2$CovP,
             CovA_comp1_comp2 = p_mbw_co2$CovA, CovP_comp1_comp2 = p_mbw_co2$CovP, stringsAsFactors = FALSE)
}

results <- rbind(
  ratio_result("ch4mbw", "MI (CH4/MBW)", "mbw"),
  ratio2_result_ch4ratio(),
  ratio_result("ch4adg", "CH4/ADG", "adg"),
  ratio_result("ch4muscle", "CH4/MM", "muscle"),
  ratio_result("ch4rumen", "CH4/rumen", "rumen"),
  ratio_result("ch4lw", "CH4/LW", "weight"),
  linear_result_1cov("ch4rmtmbw", "RMTMBW", "mbw", B_MBW),
  linear_result_rmtmbwco2(),
  linear_result_1cov("ch4rmtadg", "RMTADG", "adg", B_ADG)
)

write.csv(results, file.path(results_dir, "derived_h2.csv"), row.names = FALSE)

cat("\n=============== DERIVED COMPOSITE-TRAIT HERITABILITIES ===============\n")
print(results[, c("trait", "label", "type", "h2")], digits = 4)

cat("\n=============== COMPONENT PARAMETERS USED ===============\n")
print(results[, c("trait", "VA_ch4", "VA_comp1", "CovA_ch4_comp1", "VA_comp2", "CovA_ch4_comp2", "CovA_comp1_comp2")],
      digits = 4)

if (length(not_conv) > 0) {
  cat("\n*** WARNING: the following models did not report CONVERGED -- treat their\n",
      "derived quantities as provisional until reviewed:\n  ", paste(not_conv, collapse = "\n  "), "\n", sep = "")
}

cat("\nResidual coefficients used (recalculated / legacy, for comparison):\n")
cat(sprintf("  RMTMBW:     b=%.4f (legacy %.4f)\n", B_MBW, B_MBW_LEGACY))
cat(sprintf("  RMTMBW+CO2: b_mbw=%.4f (legacy %.4f), b_co2=%.5f (legacy %.5f)\n",
            B_MBWCO2["mbw"], B_MBWCO2_LEGACY["mbw"], B_MBWCO2["co2"], B_MBWCO2_LEGACY["co2"]))
cat(sprintf("  RMTADG:     b=%.4f (legacy %.4f)\n", B_ADG, B_ADG_LEGACY))

cat("\nWritten to", file.path(results_dir, "derived_h2.csv"), "\n")
cat("\nNOTE: scope is heritabilities only, per the user's instruction -- pairwise\n",
    "correlations among these derived traits, and any multivariate/selection-index\n",
    "work, are deferred to a later, separate task. SE/uncertainty propagation is\n",
    "also deferred until these point estimates are confirmed.\n", sep = "")

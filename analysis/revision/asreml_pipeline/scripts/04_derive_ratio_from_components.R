#!/usr/bin/env Rscript
# Derives every ratio and residual methane trait's heritability, and its
# genetic/phenotypic correlation with any other component or derived trait,
# from a single assembled 7x7 genetic (G) and phenotypic (P) covariance
# matrix over the underlying component traits -- CH4, MBW, liveweight
# (weight), ADG, CO2, muscle mass, rumen volume -- instead of fitting each
# constructed phenotype as its own ASReml trait.
#
# Conceptual basis (Julius van der Werf, via the user, 2026-09-15): do not
# fit a constructed ratio/residual as though it were an independent trait.
# Fit the components, estimate their G/P (co)variance structure once, and
# derive every constructed trait's properties from that structure.
#
#   Linear (residual) traits: for T = c'x (x = component vector, c fixed,
#   e.g. c = (1, -b) for CH4 - b*W), V_A(T) = c'Gc, V_P(T) = c'Pc exactly --
#   no approximation, since T is by construction linear in x.
#
#   Nonlinear (ratio) traits: for Q = f(x) e.g. CH4/W, first-order Taylor/
#   delta-method linearisation around the sample means, g = grad f(mean(x)),
#   V_A(Q) \approx g'Gg, V_P(Q) \approx g'Pg. This is the identical gradient
#   already used for real in the upstream Methane_Selection_Index_Analysis
#   repo (commit fb1f0a2cddb82ba322cfd86b4ad3d99830385a44:
#   index_weight_methane.R:111-116, MC_weight.R:169-174), extended from
#   "selection response" to "heritability/genetic correlation" -- not a new
#   derivation.
#
#   General correlation rule: for two traits T1 = c1'x (or g1 at the
#   linearisation point) and T2 = c2'x (or g2), Cov_A(T1,T2) = c1'Gc2 and
#   Cov_P(T1,T2) = c1'Pc2, giving rg/rp in the usual way. This is what lets
#   Table 3's cross-pairs (e.g. RMTMBW-RMTADG, CH4/MM-RMTADG) be derived
#   without ever fitting those two constructed traits together.
#
# Inputs: results/univariate_summary.csv (7 rows -- diagonal of G/P) and
# results/bivariate_summary.csv (21 rows -- off-diagonal), both produced by
# 03_parse_results.R from the --set=components run. Trait means come
# directly from data/phenotype_asreml.csv (the linearisation point for
# ratio gradients, matching the "around observed trait means" convention
# already used upstream).
#
# Residual coefficients (b): recalculated from this pipeline's own cleaned
# dataset by 00_prepare_asreml_phenotype.R (RMTMBW b=0.7722; RMTMBW+CO2
# b1=0.1591/b2=0.00907 from the JOINT multiple regression CH4~MBW+CO2, not
# two separate simple regressions; RMTADG b=2.9920). Independently verified
# here against the original manuscript-scale dataset
# (~/PAC_data_pipeline/data/external/paper3/P3_co2_data.csv, 15,869 records,
# exact manuscript match) by rerunning the identical lm() calls: legacy
# b=0.77217, b1/b2=0.1590647/0.00907138, b=2.991979 -- agree with the
# recalculated values to 4 decimal places, so both are reported below but
# there is no material legacy-vs-recalculated discrepancy to resolve.

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

BASIS <- c("methane", "mbw", "weight", "adg", "co2", "muscle", "rumen")
VARCOL <- c(methane = "ch4_g_day2_1v3", mbw = "Metabolic_BW", weight = "weight",
            adg = "adg", co2 = "co2_g_day2_1v3", muscle = "ct_muscle_kg", rumen = "rumen")
mu <- setNames(sapply(VARCOL, function(v) mean(pheno[[v]], na.rm = TRUE)), BASIS)

# ---------------------------------------------------------------------
# Assemble the 7x7 genetic (G) and phenotypic (P) covariance matrices.
# Diagonal from univariate_summary.csv; off-diagonal from
# bivariate_summary.csv's 21 pairs (any convergence failures are
# reported, not silently dropped).
#
# Phenotypic variance for each trait includes ALL relevant variance
# components (sigma_ped + sigma_ide + sigma_residual), not residual
# variance alone, per the user's explicit instruction for repeated-record
# traits (CH4/MBW/weight/CO2: 25.4% of animals have >1 record; ADG:
# 25.1%; muscle/rumen: only 3.2%, so their PE term is expected to be
# poorly identified/near-zero, not necessarily a fitting error).
# Phenotypic covariance excludes the ide(ANI_ID) cross-term, matching
# 03_parse_results.R's own convention (ide(ANI_ID) is a single shared,
# not trait-specific, PE term for every model in this pipeline -- see
# config/models.yaml's random_effects comment -- so it has no separately
# estimated covariance component to add).
# ---------------------------------------------------------------------

n <- length(BASIS)
G <- matrix(NA_real_, n, n, dimnames = list(BASIS, BASIS))
P <- matrix(NA_real_, n, n, dimnames = list(BASIS, BASIS))
uni_convergence <- setNames(rep(NA_character_, n), BASIS)

for (code in BASIS) {
  row <- uni[uni$trait_code == code, ]
  if (nrow(row) != 1) stop("Expected exactly one univariate_summary.csv row for '", code, "'")
  uni_convergence[code] <- row$convergence
  G[code, code] <- row$sigma_ped
  P[code, code] <- row$sigma_ped + row$sigma_ide + row$sigma_residual
}

bi_convergence <- list()
for (i in seq_len(n - 1)) {
  for (j in seq(i + 1, n)) {
    a <- BASIS[i]; b <- BASIS[j]
    row <- bi[bi$pair %in% c(paste0(a, "_", b), paste0(b, "_", a)), ]
    if (nrow(row) != 1) stop("Expected exactly one bivariate_summary.csv row for pair '", a, "-", b, "'")
    bi_convergence[[paste0(a, "-", b)]] <- row$convergence
    # sigma_ped_c/sigma_res_c are covariances -- symmetric regardless of
    # which of the pair was fit as trait 1 vs trait 2, so no order
    # resolution is needed here (unlike sigma_ped_1/sigma_ped_2, which
    # this script never uses since each trait's own variance is taken
    # from its univariate fit instead).
    G[a, b] <- G[b, a] <- row$sigma_ped_c
    P[a, b] <- P[b, a] <- row$sigma_res_c + row$sigma_ped_c
  }
}

write.csv(as.data.frame(G), file.path(results_dir, "component_G.csv"), row.names = TRUE)
write.csv(as.data.frame(P), file.path(results_dir, "component_P.csv"), row.names = TRUE)

not_converged <- names(uni_convergence)[uni_convergence != "CONVERGED"]
not_converged_bi <- names(bi_convergence)[unlist(bi_convergence) != "CONVERGED"]
if (length(not_converged) > 0) cat("WARNING: univariate model(s) not CONVERGED:", paste(not_converged, collapse = ", "), "\n")
if (length(not_converged_bi) > 0) cat("WARNING: bivariate model(s) not CONVERGED:", paste(not_converged_bi, collapse = ", "), "\n")

eig_G <- eigen(G, symmetric = TRUE, only.values = TRUE)$values
eig_P <- eigen(P, symmetric = TRUE, only.values = TRUE)$values
cat("\nG eigenvalues:", paste(round(eig_G, 4), collapse = ", "), "\n")
cat("P eigenvalues:", paste(round(eig_P, 4), collapse = ", "), "\n")
G_is_PD <- all(eig_G > -1e-8 * max(abs(eig_G)))
P_is_PD <- all(eig_P > -1e-8 * max(abs(eig_P)))
if (!G_is_PD) cat("*** WARNING: assembled G is NOT positive-definite (patchwork-of-bivariate-fits risk). ",
                   "Derived quantities below are NOT reliable until this is resolved ",
                   "(re-run as a joint multivariate model, or apply and disclose a nearPD correction).\n")
if (!P_is_PD) cat("*** WARNING: assembled P is NOT positive-definite.\n")

# ---------------------------------------------------------------------
# Derived-trait definitions as vectors over BASIS: `type="linear"` uses a
# fixed coefficient vector (exact); `type="ratio"` uses a gradient
# evaluated at the means (delta-method approximation), computed by the
# `gradient` function supplied.
# ---------------------------------------------------------------------

e <- function(code) { v <- setNames(rep(0, n), BASIS); v[code] <- 1; v }

# Residual coefficients: recalculated (current cleaned dataset) vs legacy
# (original manuscript-scale P3_co2_data.csv) -- see header; both reported,
# recalculated used for the derivation itself since it matches this
# pipeline's own phenotype file exactly.
B_MBW <- 0.7722; B_MBW_LEGACY <- 0.77217
B_MBWCO2 <- c(mbw = 0.1591, co2 = 0.00907); B_MBWCO2_LEGACY <- c(mbw = 0.1590647, co2 = 0.00907138)
B_ADG <- 2.9920; B_ADG_LEGACY <- 2.991979

derived <- list(
  ch4mbw    = list(type = "ratio",  label = "CH4/MBW",       num = "methane", den = "mbw"),
  ch4lw     = list(type = "ratio",  label = "CH4/LW",        num = "methane", den = "weight"),
  ch4adg    = list(type = "ratio",  label = "CH4/ADG",       num = "methane", den = "adg"),
  ch4muscle = list(type = "ratio",  label = "CH4/MM",        num = "methane", den = "muscle"),
  ch4rumen  = list(type = "ratio",  label = "CH4/rumen",     num = "methane", den = "rumen"),
  ch4ratio  = list(type = "ratio2", label = "CH4/(CH4+CO2)", num = "methane", den = "co2"),
  ch4rmtmbw    = list(type = "linear", label = "RMTMBW",       c = e("methane") - B_MBW * e("mbw")),
  ch4rmtmbwco2 = list(type = "linear", label = "RMTMBW+CO2",   c = e("methane") - B_MBWCO2["mbw"] * e("mbw") - B_MBWCO2["co2"] * e("co2")),
  ch4rmtadg    = list(type = "linear", label = "RMTADG",       c = e("methane") - B_ADG * e("adg"))
)

# Gradient for Q = X/Y at means (mu_x, mu_y): dQ/dX = 1/mu_y, dQ/dY = -mu_x/mu_y^2.
ratio_gradient <- function(num, den) {
  mu_x <- mu[[num]]; mu_y <- mu[[den]]
  e(num) / mu_y - e(den) * mu_x / mu_y^2
}
# Gradient for Q = CH4/(CH4+CO2) directly wrt (CH4, CO2) (chain rule wrt
# the two original components, not via an intermediate Y=CH4+CO2 variable):
# dQ/dCH4 = CO2/(CH4+CO2)^2, dQ/dCO2 = -CH4/(CH4+CO2)^2.
ratio2_gradient <- function(num, den) {
  mu_x <- mu[[num]]; mu_y <- mu[[den]]
  denom <- (mu_x + mu_y)^2
  e(num) * (mu_y / denom) - e(den) * (mu_x / denom)
}

get_vector <- function(def) {
  switch(def$type,
    linear = def$c,
    ratio  = ratio_gradient(def$num, def$den),
    ratio2 = ratio2_gradient(def$num, def$den)
  )
}

vecs <- lapply(derived, get_vector)
VA <- sapply(vecs, function(v) as.numeric(t(v) %*% G %*% v))
VP <- sapply(vecs, function(v) as.numeric(t(v) %*% P %*% v))
h2 <- VA / VP

h2_table <- data.frame(trait = names(derived), label = sapply(derived, `[[`, "label"),
                        type = sapply(derived, `[[`, "type"), VA = VA, VP = VP, h2 = h2,
                        row.names = NULL)
write.csv(h2_table, file.path(results_dir, "derived_h2.csv"), row.names = FALSE)

cat("\n=============== DERIVED TRAIT HERITABILITIES ===============\n")
print(h2_table[, c("trait", "label", "type", "h2")], digits = 4)

# ---------------------------------------------------------------------
# Full pairwise genetic/phenotypic correlation matrix among the 9 derived
# traits AND the 7 raw components (reproduces Table 3's cross-pairs, e.g.
# RMTMBW-RMTADG, CH4/MM-RMTADG, plus Tables 4-5's derived/component-vs-CH4
# correlations), all from the single G/P -- no additional ASReml runs.
# ---------------------------------------------------------------------

all_vecs <- c(vecs, setNames(lapply(BASIS, e), BASIS))
all_VA <- sapply(all_vecs, function(v) as.numeric(t(v) %*% G %*% v))
all_VP <- sapply(all_vecs, function(v) as.numeric(t(v) %*% P %*% v))

nm <- names(all_vecs)
rg_mat <- matrix(NA_real_, length(nm), length(nm), dimnames = list(nm, nm))
rp_mat <- rg_mat
for (i in seq_along(nm)) for (j in seq_along(nm)) {
  covA <- as.numeric(t(all_vecs[[i]]) %*% G %*% all_vecs[[j]])
  covP <- as.numeric(t(all_vecs[[i]]) %*% P %*% all_vecs[[j]])
  rg_mat[i, j] <- covA / sqrt(all_VA[i] * all_VA[j])
  rp_mat[i, j] <- covP / sqrt(all_VP[i] * all_VP[j])
}
write.csv(as.data.frame(rg_mat), file.path(results_dir, "derived_rg_matrix.csv"), row.names = TRUE)
write.csv(as.data.frame(rp_mat), file.path(results_dir, "derived_rp_matrix.csv"), row.names = TRUE)

cat("\nWrote results/component_G.csv, component_P.csv, derived_h2.csv, ",
    "derived_rg_matrix.csv, derived_rp_matrix.csv\n", sep = "")
cat("\nNOTE: point estimates only -- SE/uncertainty propagation for these",
    "derived quantities is deferred (delta method on ASReml's average-information",
    "matrix, or a parametric bootstrap, per the user's explicit instruction",
    "to get point estimates working first).\n")

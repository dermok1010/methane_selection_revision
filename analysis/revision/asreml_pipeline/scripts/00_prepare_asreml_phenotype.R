# Build the curated, ASReml-ready phenotype file for the revision's
# submitted-style model sweep.
#
# Reproduces the trait-derivation/column-selection logic of the legacy
# data_generation.R (analysis/legacy/PAC_data_pipeline/scripts/data_generation.R,
# also documented in docs/asreml_legacy_map.md Section 2) against this
# repo's own verified, canonical PAC pipeline output -- NOT a
# reinterpretation of the residual traits (that's the deferred
# "component-trait redesign"; this step only reproduces the existing
# simple-OLS construction so the submitted-style models can be run at
# all). The exploratory correlation/plotting code at the end of the
# legacy script is not reproduced here -- it produced no output file.

# Usage: Rscript 00_prepare_asreml_phenotype.R --platform=vm|hpc  (default: vm)
# Paths come from config/paths.yaml -- this script does not hardcode
# platform-specific paths itself, per the pipeline's portability
# requirement.

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(yaml))

args <- commandArgs(trailingOnly = TRUE)
platform <- sub("^--platform=", "", grep("^--platform=", args, value = TRUE))
if (length(platform) == 0) platform <- "vm"
stopifnot(platform %in% c("vm", "hpc"))

script_dir <- dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)))
pipeline_root <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
if (!dir.exists(file.path(pipeline_root, "config"))) pipeline_root <- getwd()

paths_cfg <- read_yaml(file.path(pipeline_root, "config", "paths.yaml"))[[platform]]
models_cfg <- read_yaml(file.path(pipeline_root, "config", "models.yaml"))

input_path <- paths_cfg$raw_phenotype_file
output_path <- file.path(pipeline_root, "data", models_cfg$phenotype_file)

cat("Platform:", platform, "\n")
cat("Input: ", input_path, "\n")
cat("Output:", output_path, "\n\n")

data <- read.csv(input_path)

data <- data %>%
  mutate(SEX = ifelse(SEX == "FALSE", "F", SEX))

cat("SEX distribution:\n")
print(table(data$SEX, useNA = "ifany"))

data$age_in_years <- round((data$age_at_treatment / 365), 0)
data$age_in_years <- pmin(data$age_in_years, 7)  # cap at 7 years, as legacy did
data$age_in_months <- round((data$age_at_treatment) / 30, 0)
data$age_in_weeks <- round((data$age_at_treatment) / 7, 0)
data$methane_per_lw <- (data$ch4_g_day2_1v3 / data$weight)

# Rearing/birth rank are growing-animal concepts; set to NA for ewes.
data <- data %>%
  mutate(
    BIRTH_RANK   = ifelse(bio_group == "ewe", NA, BIRTH_RANK),
    REARING_RANK = ifelse(bio_group == "ewe", NA, REARING_RANK)
  )

asreml_data <- data %>%
  select(
    ANI_ID, ch4_g_day2_1v3, co2_g_day2_1v3, ch4_ratio, methane_per_dmi,
    methane_per_mbw, Metabolic_BW, SEX, TX, BR, SU, CL, CV, LY, UN, het, rec,
    age_in_years, ch4_GroupNumber, weight, DMI, adg, methane_per_adg,
    methane_per_rumen, methane_per_muscle, rumen, age_in_months, age_in_weeks,
    REARING_RANK, BIRTH_RANK, ewe_birth_rank, ewe_rearing_rank,
    dam_parity_group_num, ct_muscle_kg, methane_per_lw
  )

# ---- Residual ("adjusted") CH4 traits: simple OLS residuals, no fixed
# effects or CG adjustment, exactly as in the legacy script ----

ccmbw <- complete.cases(asreml_data$ch4_g_day2_1v3, asreml_data$Metabolic_BW)
fitmbw <- lm(ch4_g_day2_1v3 ~ Metabolic_BW, data = asreml_data[ccmbw, ])
asreml_data$ch4_adj_MBW <- NA_real_
asreml_data$ch4_adj_MBW[ccmbw] <- resid(fitmbw)

ccmbw_co2 <- complete.cases(
  asreml_data$ch4_g_day2_1v3, asreml_data$Metabolic_BW, asreml_data$co2_g_day2_1v3
)
fitmbw_co2 <- lm(
  ch4_g_day2_1v3 ~ Metabolic_BW + co2_g_day2_1v3, data = asreml_data[ccmbw_co2, ]
)
asreml_data$ch4_adj_MBW_co2 <- NA_real_
asreml_data$ch4_adj_MBW_co2[ccmbw_co2] <- resid(fitmbw_co2)

ccdmi <- complete.cases(asreml_data$ch4_g_day2_1v3, asreml_data$DMI)
fitdmi <- lm(ch4_g_day2_1v3 ~ DMI, data = asreml_data[ccdmi, ])
asreml_data$ch4_adj_DMI <- NA_real_
asreml_data$ch4_adj_DMI[ccdmi] <- resid(fitdmi)

ccadg <- complete.cases(asreml_data$ch4_g_day2_1v3, asreml_data$adg)
fitadg <- lm(ch4_g_day2_1v3 ~ adg, data = asreml_data[ccadg, ])
asreml_data$ch4_adj_adg <- NA_real_
asreml_data$ch4_adj_adg[ccadg] <- resid(fitadg)

asreml_data$adg_g <- (asreml_data$adg * 1000)

# ---- Growing/mature stage split at the manuscript's own <660-days cutoff
# (2026-09-18, per user instruction) ----
#
# The manuscript itself already defines "growing animals" as <660 days at
# measurement -- the cutoff used to restrict ADG/CH4-ADG/CH4-MM/CH4-rumen/
# RMTADG to a subset of records (docs/manuscript_context.md Section 5).
# Two new revision analyses reuse this same official cutoff rather than
# inventing a new one:
#   (a) stage_660 groups every record for a heterogeneous-residual-variance
#       sensitivity model (Reviewer 1's contemporary-group/scale-
#       heterogeneity concern -- see --set=stage_het in
#       01_generate_models.R). This generalizes, and supersedes for the
#       main pipeline, the earlier single-trait pilot
#       (analysis/diagnostics/reviewer_a2_a3/a_ch4_stage_het_residual.as),
#       which used a different, ad hoc age_in_years<2 (~730 days) split --
#       that pilot's own result and files are left untouched, just no
#       longer the cutoff used going forward here.
#   (b) ch4_young/ch4_old split CH4 itself into two age-class pseudo-traits
#       for a young-vs-mature bivariate genetic-correlation model
#       (--set=young_old), answering the scope decision left open in
#       analysis/diagnostics/reviewer_a2_a3/README.md's A3 section.
asreml_data$stage_660 <- ifelse(data$age_at_treatment < 660, "young", "mature")
asreml_data$ch4_young <- ifelse(asreml_data$stage_660 == "young", asreml_data$ch4_g_day2_1v3, NA_real_)
asreml_data$ch4_old   <- ifelse(asreml_data$stage_660 == "mature", asreml_data$ch4_g_day2_1v3, NA_real_)

# ---- Contemporary-group-mean residual-heterogeneity class (2026-09-18,
# per user instruction -- adapted from ~/Dermot_analysis/Phd/Paper_3/
# 2_genetic_analysis/scripts/CG_variance_adjust.R, a real prior ASReml/
# MiX99 analysis the user had already built and run for a related
# project) ----
#
# stage_660 (above) is an age-based PROXY for Reviewer 1's contemporary-
# group heteroscedasticity concern -- literally fitting one residual
# variance per ch4_GroupNumber (1435 levels) is intractable (most groups
# are far too small to estimate their own variance). This is the more
# direct version: bin each contemporary group by its OWN mean CH4 into
# tertiles, computed WITHIN each data `source` (14 distinct farm/study
# codes here, e.g. AYAF/CT/HILL/etc. -- every ch4_GroupNumber belongs to
# exactly one source, confirmed 1435 unique (source, ch4_GroupNumber)
# combinations = exactly the CG count) rather than pooling tertiles
# across sources with different baseline CH4 levels. Consecutively
# numbered per source (source i's three tertile classes are
# 3*(i-1)+1 .. 3*(i-1)+3), giving up to 14*3=42 classes -- fewer where a
# source has too few CGs to form 3 tertiles (HILL has only 2 CGs, the
# smallest; ntile() distributes as evenly as possible rather than
# erroring). Used as `residual sat(cg_mean_cl).idv(units)` in
# --set=cg_het, alongside (not replacing) the stage_660-based models.
cg_means <- data %>%
  group_by(source, ch4_GroupNumber) %>%
  summarise(cg_mean = mean(ch4_g_day2_1v3, na.rm = TRUE), cg_n = n(), .groups = "drop") %>%
  mutate(source_cl = as.integer(factor(source))) %>%
  group_by(source_cl) %>%
  mutate(mean_class = ntile(cg_mean, 3)) %>%
  ungroup() %>%
  mutate(cg_mean_cl = (source_cl - 1L) * 3L + mean_class)

asreml_data$cg_mean_cl <- cg_means$cg_mean_cl[
  match(data$ch4_GroupNumber, cg_means$ch4_GroupNumber)
]
cat("\ncg_mean_cl class sizes (n contemporary groups, n records):\n")
print(cg_means %>% count(cg_mean_cl, name = "n_cg"))
stopifnot(!anyNA(asreml_data$cg_mean_cl))

# ---- CH4 ratio on a molar basis (2026-09-21, per user request) --------
#
# The manuscript's CH4-ratio trait (ch4_ratio, above) is
# g_CH4/(g_CH4+g_CO2) -- a mass fraction. Reviewer 1 flags that this
# trait's units are never stated in the manuscript at all. This adds a
# molar-basis alternative, mol_CH4/(mol_CH4+mol_CO2), to check whether
# the low heritability/repeatability reported for the ratio trait
# (h2=0.08, t=0.09 -- the reviewers' headline discrepancy vs. Jonker et
# al. 2018's h2=0.17-0.25) is sensitive to which basis the ratio is
# expressed on.
#
# No molar-mass conversion (16.04 g/mol CH4, 44.01 g/mol CO2) is needed:
# ch4_l_day_1v3/co2_l_day_1v3 (already in the raw phenotype file) are
# CH4's and CO2's own volumetric flow rates from the SAME PAC chamber
# airstream at the SAME time as each record's ch4_g_day2_1v3/
# co2_g_day2_1v3. By the ideal gas law, n = PV/(RT): for two gases at
# identical P and T, the mole ratio equals the volume ratio exactly --
# P and T cancel, regardless of the two gases' different molar masses.
# (Sanity-checked against this file's own data: the implied g/L density
# for both ch4_g_day2_1v3/ch4_l_day_1v3 and co2_g_day2_1v3/
# co2_l_day_1v3 varies record-to-record in exactly the way ideal-gas
# density varies with the file's own temp/press columns -- i.e. the g
# columns are themselves already a per-record ideal-gas conversion of
# the l columns, not a fixed-density rescaling -- so this is a real
# molar quantity, not an approximation.)
asreml_data$ch4_ratio_mol <- ifelse(
  !is.na(data$ch4_l_day_1v3) & !is.na(data$co2_l_day_1v3) &
    (data$ch4_l_day_1v3 + data$co2_l_day_1v3) > 0,
  data$ch4_l_day_1v3 / (data$ch4_l_day_1v3 + data$co2_l_day_1v3),
  NA_real_
)

cat("\nFinal column list (", ncol(asreml_data), " columns):\n", sep = "")
print(colnames(asreml_data))

cat("\nRow count:", nrow(asreml_data), "\n")

dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)

write.csv(asreml_data, output_path, row.names = FALSE)

cat("\nWritten to:", output_path, "\n")

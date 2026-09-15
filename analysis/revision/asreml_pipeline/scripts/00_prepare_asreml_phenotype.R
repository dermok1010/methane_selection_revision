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

cat("\nFinal column list (", ncol(asreml_data), " columns):\n", sep = "")
print(colnames(asreml_data))

cat("\nRow count:", nrow(asreml_data), "\n")

dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)

write.csv(asreml_data, output_path, row.names = FALSE)

cat("\nWritten to:", output_path, "\n")

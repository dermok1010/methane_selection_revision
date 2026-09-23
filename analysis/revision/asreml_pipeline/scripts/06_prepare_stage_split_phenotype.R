# Split the already-prepared phenotype_asreml.csv into two row-filtered
# files, one per stage_660 level (young < 660d, mature >= 660d), for the
# stage-split bivariate check (docs/revision_plan.md Section 4E,
# 2026-09-23).
#
# Why this exists: the bivariate stage-heterogeneous-RESIDUAL approach
# (sat(stage_660).us(Trait).units / idh(stage_660).us(Trait).units) is
# abandoned for structural reasons (sat() silently collapses to one
# section in a bivariate/Trait-sectioned model; idh() combined with
# us(Trait) violates ASReml's "one variance function per compound term"
# rule, Functional-Specification.pdf Section 7.2). Splitting the DATA by
# stage and fitting two ordinary, already-working homogeneous-residual
# bivariate models instead sidesteps all of that -- no exotic residual
# syntax needed, since within a single stage subset there is no
# heterogeneity to model. This directly tests whether the CROSS-TRAIT
# genetic correlation itself differs between young and mature animals,
# which the existing young_old check (CH4 vs itself across stages) and
# the univariate stage_het VA-stability check (each trait's OWN genetic
# variance, not the cross-trait covariance) don't quite cover.
#
# Both output files keep the FULL original column set/order (just fewer
# rows) so they are a drop-in replacement for phenotype_asreml.csv --
# field_definition_lines() in 01_generate_models.R depends only on
# config/models.yaml's column list, not on which physical file is read.
#
# Usage: Rscript 06_prepare_stage_split_phenotype.R
# (platform-independent -- filters the unified phenotype file already
# built by 00_prepare_asreml_phenotype.R, does not touch raw HPC-only
# sources, so this can run on the VM even though ASReml itself cannot.)

suppressPackageStartupMessages({
  library(dplyr)
  library(yaml)
})

script_dir <- dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)))
pipeline_root <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
if (!dir.exists(file.path(pipeline_root, "config"))) pipeline_root <- getwd()

models_cfg <- read_yaml(file.path(pipeline_root, "config", "models.yaml"))
input_path <- file.path(pipeline_root, "data", models_cfg$phenotype_file)
if (!file.exists(input_path)) {
  stop(
    input_path, " does not exist -- run 00_prepare_asreml_phenotype.R first ",
    "(this script only filters that already-built file, it does not build ",
    "it from raw sources)."
  )
}

cat("Reading", input_path, "\n")
pheno <- read.csv(input_path)

if (!"stage_660" %in% names(pheno)) {
  stop("stage_660 column not found in ", input_path)
}

stage_counts <- table(pheno$stage_660, useNA = "ifany")
cat("stage_660 level counts in the full file:\n")
print(stage_counts)
if (!all(c("young", "mature") %in% names(stage_counts))) {
  stop("Expected 'young' and 'mature' levels in stage_660, found: ",
       paste(names(stage_counts), collapse = ", "))
}

young <- filter(pheno, stage_660 == "young")
mature <- filter(pheno, stage_660 == "mature")

young_path <- file.path(pipeline_root, "data", "phenotype_asreml_young.csv")
mature_path <- file.path(pipeline_root, "data", "phenotype_asreml_mature.csv")

write.csv(young, young_path, row.names = FALSE)
write.csv(mature, mature_path, row.names = FALSE)

cat(sprintf(
  "\nWrote %s (%d rows) and %s (%d rows), out of %d total rows in the source file.\n",
  young_path, nrow(young), mature_path, nrow(mature), nrow(pheno)
))

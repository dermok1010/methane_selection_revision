# Populate run/ (gitignored execution directory) with everything ASReml
# needs to actually run: the generated .as/.pin files from models/, the
# phenotype file, and the pedigree file -- under the bare filenames the
# .as files reference (ASReml resolves paths relative to its working
# directory, so nothing here is platform-specific except which absolute
# source paths config/paths.yaml points at).
#
# Usage: Rscript 02_stage_run_dir.R --platform=vm|hpc
#
# The pedigree file from analysis/revision/pedigree/01_ped_maker.R is
# already topologically sorted (parents before offspring, verified by
# that script's own structural checks) -- it is copied directly to
# <pedigree_file>.SRT so ASReml recognises it as pre-sorted and skips
# its own !SORT pass (ASReml-4.2-Functional-Specification.pdf Section
# 8, "!SORT... if pedigreefile is specified as basename.SRT and this
# file already exists, ASReml will assume the sorting has already been
# performed").

suppressPackageStartupMessages(library(yaml))

args <- commandArgs(trailingOnly = TRUE)
platform <- sub("^--platform=", "", grep("^--platform=", args, value = TRUE))
if (length(platform) == 0) stop("Usage: Rscript 02_stage_run_dir.R --platform=vm|hpc")
stopifnot(platform %in% c("vm", "hpc"))

script_dir <- dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)))
pipeline_root <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
if (!dir.exists(file.path(pipeline_root, "config"))) pipeline_root <- getwd()

paths_all <- read_yaml(file.path(pipeline_root, "config", "paths.yaml"))
paths_cfg <- paths_all[[platform]]
rel <- paths_all$relative
models_cfg <- read_yaml(file.path(pipeline_root, "config", "models.yaml"))

run_dir <- file.path(pipeline_root, rel$run_dir)
models_dir <- file.path(pipeline_root, rel$models_dir)
state_dir <- file.path(pipeline_root, rel$state_dir)
dir.create(run_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(state_dir, showWarnings = FALSE, recursive = TRUE)

# ---- phenotype file ----
phenotype_src <- file.path(pipeline_root, "data", models_cfg$phenotype_file)
if (!file.exists(phenotype_src)) {
  stop(
    "Phenotype file not found at ", phenotype_src, " -- run ",
    "00_prepare_asreml_phenotype.R --platform=", platform, " first."
  )
}
file.copy(phenotype_src, file.path(run_dir, models_cfg$phenotype_file), overwrite = TRUE)
cat("Staged phenotype file:", models_cfg$phenotype_file, "\n")

# ---- pedigree file ----
pedigree_src <- paths_cfg$pedigree_file
if (!file.exists(pedigree_src)) {
  stop(
    "Pedigree file not found at ", pedigree_src, " (config/paths.yaml ",
    "platform: ", platform, ") -- check config/paths.yaml is pointing ",
    "at the right file for this platform."
  )
}
file.copy(pedigree_src, file.path(run_dir, models_cfg$pedigree_file), overwrite = TRUE)
cat("Staged pedigree file:", models_cfg$pedigree_file,
    "(pre-sorted; ASReml will not re-sort it)\n")

# ---- generated model files ----
as_files <- list.files(models_dir, pattern = "\\.(as|pin)$", full.names = TRUE)
if (length(as_files) == 0) {
  stop("No .as/.pin files in ", models_dir, " -- run 01_generate_models.R first.")
}
file.copy(as_files, run_dir, overwrite = TRUE)
cat("Staged", length(as_files), "model files (.as/.pin) into", run_dir, "\n")

cat("\nrun/ is ready. On HPC, submit with slurm/submit_batch.sh; on the VM\n")
cat("(no ASReml installed here by design) this step only prepares run/ for\n")
cat("inspection/git-diffing before the directory is synced to HPC.\n")

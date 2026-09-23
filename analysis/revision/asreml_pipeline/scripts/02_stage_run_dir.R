# Populate run/<jobname>/ (gitignored execution directories, one per
# model) with everything ASReml needs to actually run: that model's
# .as/.pin file plus its own copies of the phenotype and pedigree files.
#
# Usage: Rscript 02_stage_run_dir.R --platform=vm|hpc
#
# ---------------------------------------------------------------------
# Why one directory PER JOB, not one shared run/ for everything: a real
# HPC trial run (2026-09-15) submitted 3 jobs sharing a single run/
# directory. The one that happened to run alone completed and converged
# normally; the two that ran concurrently both crashed with a Fortran
# runtime error ("forrtl: severe (28): CLOSE error, unit 7") a few
# seconds in, never producing a .asr file. ASReml writes some files
# under fixed, non-job-prefixed names in its working directory rather
# than names derived from the .as basename -- ainverse.bin and
# asrdata.bin are two documented examples
# (ASReml-4.2-Functional-Specification.pdf Section 11.3.2) -- so two
# ASReml processes sharing a working directory race on those files. The
# legacy Slurm scripts (analysis/legacy/asreml_scripts/*.slurm) only
# ever ran one ASReml job at a time from a given directory (a plain
# sequential for-loop in h_cor.slurm/ped_cor.slurm), which is consistent
# with this. Giving every job its own directory avoids the race
# entirely and keeps jobs independently parallelisable.
#
# The pedigree file from analysis/revision/pedigree/01_ped_maker.R is
# already topologically sorted -- copied directly to <pedigree_file>.SRT
# in each job directory so ASReml recognises it as pre-sorted and skips
# re-sorting (Section 8 of the manual).
# ---------------------------------------------------------------------

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

phenotype_src <- file.path(pipeline_root, "data", models_cfg$phenotype_file)
if (!file.exists(phenotype_src)) {
  stop(
    "Phenotype file not found at ", phenotype_src, " -- run ",
    "00_prepare_asreml_phenotype.R --platform=", platform, " first."
  )
}

pedigree_src <- paths_cfg$pedigree_file
if (!file.exists(pedigree_src)) {
  stop(
    "Pedigree file not found at ", pedigree_src, " (config/paths.yaml ",
    "platform: ", platform, ") -- check config/paths.yaml is pointing ",
    "at the right file for this platform."
  )
}

as_files <- list.files(models_dir, pattern = "\\.as$", full.names = TRUE)
if (length(as_files) == 0) {
  stop("No .as files in ", models_dir, " -- run 01_generate_models.R first.")
}

for (as_path in as_files) {
  jobname <- sub("\\.as$", "", basename(as_path))
  job_dir <- file.path(run_dir, jobname)
  dir.create(job_dir, showWarnings = FALSE, recursive = TRUE)

  file.copy(as_path, file.path(job_dir, basename(as_path)), overwrite = TRUE)
  pin_path <- sub("\\.as$", ".pin", as_path)
  if (file.exists(pin_path)) {
    file.copy(pin_path, file.path(job_dir, basename(pin_path)), overwrite = TRUE)
  }

  # Each job's .as file names its own phenotype data file on the line
  # immediately following the pedigree file -- normally
  # models_cfg$phenotype_file for every job, but gen_bivariate()'s
  # phenotype_file override (2026-09-23, stage-split bivariate check)
  # can point a specific job at a different, smaller file (e.g. a
  # stage_660-filtered subset) living alongside it in data/. Read it
  # back from the .as file itself rather than assuming the global name,
  # so this generalises to any future per-job override too.
  as_lines <- readLines(as_path, warn = FALSE)
  pheno_line <- grep("!SKIP 1 !MVINCLUDE", as_lines, value = TRUE)
  job_phenotype_file <- if (length(pheno_line) == 1) {
    sub("\\s.*$", "", trimws(pheno_line))
  } else {
    models_cfg$phenotype_file
  }
  job_phenotype_src <- file.path(pipeline_root, "data", job_phenotype_file)
  if (!file.exists(job_phenotype_src)) {
    stop(
      jobname, "'s .as file references phenotype data ", job_phenotype_file,
      " but ", job_phenotype_src, " does not exist -- generate it before staging."
    )
  }
  file.copy(job_phenotype_src, file.path(job_dir, job_phenotype_file), overwrite = TRUE)
  file.copy(pedigree_src, file.path(job_dir, models_cfg$pedigree_file), overwrite = TRUE)

  cat(
    "Staged ", jobname, " -> ", job_dir,
    if (job_phenotype_file != models_cfg$phenotype_file) {
      sprintf(" (phenotype: %s)", job_phenotype_file)
    } else {
      ""
    },
    "\n", sep = ""
  )
}

cat("\n", length(as_files), " job director", if (length(as_files) == 1) "y" else "ies",
    " ready under ", run_dir, "\n", sep = "")
cat("On HPC, submit with slurm/submit_batch.sh; on the VM (no ASReml\n")
cat("installed here by design) this step only prepares run/ for\n")
cat("inspection before syncing to HPC.\n")

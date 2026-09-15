#!/usr/bin/env Rscript
# Generate ASReml .as/.pin job files from config/models.yaml.
#
# Usage:
#   Rscript 01_generate_models.R --set=validation
#   Rscript 01_generate_models.R --set=full
#   Rscript 01_generate_models.R --set=components_trial  # small trial: 7
#                                                   # univariate + 3
#                                                   # representative pairs
#   Rscript 01_generate_models.R --set=components  # full 7-univariate +
#                                                   # 21-bivariate component
#                                                   # set, see config's
#                                                   # component_set/
#                                                   # component_traits
#
# Writes into <pipeline_root>/models/ (git-tracked). Does not run ASReml,
# does not touch run/. See README.md for the full VM -> HPC workflow.
#
# ---------------------------------------------------------------------
# On VPREDICT index provenance (read before changing the bivariate
# template): the numeric indices in each bivariate VPREDICT block below
# are NOT guessed. They were decoded by hand from a real, converged
# legacy result (analysis/legacy/asreml_scripts/bi_ch4_ch4ratio.asr),
# whose Model_Term table prints, in this exact order for this exact
# model structure (Trait.ped(ANI_ID) declared first, ide(ANI_ID) second,
# in the model line's !r clause):
#   1. ide(ANI_ID)         IDV_V            (single shared PE value)
#   2. Residual            US_V  1 1        (trait 1 residual variance)
#   3. Residual            US_C  2 1        (residual covariance)
#   4. Residual            US_V  2 2        (trait 2 residual variance)
#   5. Trait.ANI_ID (ped)  US_V  1 1        (trait 1 genetic variance)
#   6. Trait.ANI_ID (ped)  US_C  2 1        (genetic covariance)
#   7. Trait.ANI_ID (ped)  US_V  2 2        (trait 2 genetic variance)
# i.e. ASReml's print order is NOT the declaration order (ped is
# declared first but prints last) -- do not assume otherwise for a
# differently-ordered model. Because every bivariate model generated
# here uses the identical declaration order and G-structure, this same
# numbering is expected to hold for every pair -- but this is a
# structural inference from ONE worked example, not verified against
# every pair (ASReml is not installed on the VM to check). The output
# parser (03_parse_results.R) therefore does NOT trust these indices
# alone: it independently re-derives h2/rg/rp/re from the Model_Term
# table by NAME and flags any case where the two disagree. Treat any
# such flag as a sign this assumption has broken down for that pair.
# ---------------------------------------------------------------------

suppressPackageStartupMessages({
  library(yaml)
})

args <- commandArgs(trailingOnly = TRUE)
set_arg <- sub("^--set=", "", grep("^--set=", args, value = TRUE))
if (length(set_arg) == 0) set_arg <- "validation"
stopifnot(set_arg %in% c("validation", "full", "components", "components_trial"))

pipeline_root <- normalizePath(
  file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE))), ".."),
  mustWork = FALSE
)
if (!dir.exists(file.path(pipeline_root, "config"))) {
  # Fallback for interactive/Rscript-without-file invocation.
  pipeline_root <- getwd()
}

cfg <- read_yaml(file.path(pipeline_root, "config", "models.yaml"))
models_dir <- file.path(pipeline_root, "models")
dir.create(models_dir, showWarnings = FALSE, recursive = TRUE)

# ---------------------------------------------------------------------
# ASReml's field-definition block is POSITIONAL (one line per data-file
# column, in order -- ASReml-4.2-Functional-Specification.pdf Section
# 5.4). Validate config$phenotype_columns against the actual phenotype
# file header before generating anything: a silent mismatch here would
# misalign every single generated model without any error until a human
# happened to check the .asr data summary by hand.
# ---------------------------------------------------------------------
phenotype_data_path <- file.path(pipeline_root, "data", cfg$phenotype_file)
if (file.exists(phenotype_data_path)) {
  actual_header <- strsplit(readLines(phenotype_data_path, n = 1), ",")[[1]]
  actual_header <- gsub('^"|"$', "", actual_header)
  expected_header <- sapply(cfg$phenotype_columns, `[[`, "name")
  if (!identical(actual_header, expected_header)) {
    cat("Expected (config$phenotype_columns):\n"); print(expected_header)
    cat("Actual (", phenotype_data_path, "):\n", sep = ""); print(actual_header)
    stop(
      "phenotype_columns in config/models.yaml does not match the actual ",
      "column order of ", phenotype_data_path, ". Refusing to generate ",
      "models -- ASReml field definitions are positional, so this would ",
      "silently misalign every model. Update config/models.yaml to match."
    )
  }
  cat("Field-definition block validated against", phenotype_data_path, "\n")
} else {
  cat(
    "WARNING: ", phenotype_data_path, " not found -- generating models ",
    "WITHOUT validating phenotype_columns against the real file header. ",
    "Re-run this script after staging the phenotype file to get that check.\n",
    sep = ""
  )
}

field_definition_lines <- function() {
  vapply(cfg$phenotype_columns, function(col) {
    suffix <- if (col$name == "ANI_ID") {
      "!P"
    } else if (col$type == "A") {
      "* !A"
    } else {
      "1"
    }
    sprintf(" %s %s", col$name, suffix)
  }, character(1))
}

fixed_terms <- cfg$fixed_effects
fixed_uni <- paste(c("mu", fixed_terms), collapse = " ")
fixed_bi <- paste(c("Trait", paste0("Tr.", fixed_terms)), collapse = " ")

trait_by_code <- setNames(cfg$traits, sapply(cfg$traits, `[[`, "code"))
# component_traits (config/models.yaml) are the raw denominator variables
# behind each ratio trait (e.g. Metabolic_BW behind CH4/MBW) -- kept in a
# separate list, not merged into cfg$traits, so that --set=full's
# generate_all_pairs (all pairwise combinations of cfg$traits) is
# unaffected by their addition. They're only reachable via --set=components.
if (!is.null(cfg$component_traits)) {
  trait_by_code <- c(trait_by_code,
                      setNames(cfg$component_traits, sapply(cfg$component_traits, `[[`, "code")))
}

# ---------------------------------------------------------------------
# Note on the fixed-effects list: the legacy bi_ch4_ch4ratio.as file has
# "Tr.het Tr.het" (het listed twice) in its fixed-effects formula, and
# has Tr.dam_parity_group_num out of order relative to the univariate
# models' term ordering -- both artefacts of hand-editing individual
# .as files. This config's single canonical `fixed_effects` list is used
# for every model generated here, so neither artefact is reproduced.
# ---------------------------------------------------------------------

legacy_scripts_dir <- normalizePath(
  file.path(pipeline_root, "..", "..", "legacy", "asreml_scripts"),
  mustWork = FALSE
)

# Extract the G/R-structure declaration block (between the model formula
# line and "VPREDICT") verbatim from a matching legacy bi_<a>_<b>.as file,
# if one exists, for use as tuned starting values. Returns NULL if no
# matching legacy file is found for this pair (either name order).
get_legacy_structure_block <- function(code1, code2) {
  alias1 <- trait_by_code[[code1]]$legacy_bi_alias
  alias2 <- trait_by_code[[code2]]$legacy_bi_alias
  c1_variants <- unique(c(code1, alias1))
  c2_variants <- unique(c(code2, alias2))
  name_pairs <- expand.grid(a = c1_variants, b = c2_variants, stringsAsFactors = FALSE)
  candidates <- unlist(lapply(seq_len(nrow(name_pairs)), function(i) {
    a <- name_pairs$a[i]; b <- name_pairs$b[i]
    file.path(legacy_scripts_dir, c(sprintf("bi_%s_%s.as", a, b), sprintf("bi_%s_%s.as", b, a)))
  }))
  found <- candidates[file.exists(candidates)]
  if (length(found) == 0) return(NULL)

  lines <- readLines(found[1], warn = FALSE)
  model_line_idx <- grep("~", lines)[1]
  vpredict_idx <- grep("^VPREDICT", lines)[1]
  if (is.na(model_line_idx) || is.na(vpredict_idx) || vpredict_idx <= model_line_idx + 1) {
    return(NULL)
  }
  block <- lines[(model_line_idx + 1):(vpredict_idx - 1)]
  block <- block[!(block == "" & cumsum(block != "") == 0)]  # drop leading blanks
  while (length(block) > 0 && block[length(block)] == "") block <- block[-length(block)]
  if (length(block) == 0) return(NULL)
  block
}

# ---- univariate template ----

gen_univariate <- function(trait) {
  as_lines <- c(
    sprintf(
      "!WORKSPACE %d !CONTINUE !NODISPLAY !LOGFILE !MAXIT %d !MP %d",
      cfg$workspace_mb, cfg$maxit, cfg$mp_threads
    ),
    sprintf("univariate_%s -- generated by 01_generate_models.R", trait$code),
    field_definition_lines(),
    "",
    cfg$pedigree_file,
    sprintf("%s !SKIP 1 !MVINCLUDE", cfg$phenotype_file),
    "",
    sprintf(
      "%s ~ %s !r %s",
      trait$variable, fixed_uni, cfg$random_effects$univariate
    ),
    "",
    "VPREDICT !DEFINE",
    "P Phen 1 2 3",
    "H direct 1 4",
    "P ani_all 1 2",
    "H repeat 5 4",
    ""
  )
  writeLines(as_lines, file.path(models_dir, sprintf("a_uni_%s.as", trait$code)))

  pin_lines <- c(
    "P Phen 1 2 3",
    "H direct 1 4",
    "P ani_all 1 2",
    "H repeat 5 4"
  )
  writeLines(pin_lines, file.path(models_dir, sprintf("a_uni_%s.pin", trait$code)))
}

# ---- bivariate template ----

gen_bivariate <- function(trait1, trait2) {
  code_pair <- sprintf("%s_%s", trait1$code, trait2$code)

  structure_block <- get_legacy_structure_block(trait1$code, trait2$code)
  if (is.null(structure_block)) {
    structure_block <- c(
      "# No matching legacy bi_*.as file found for this pair -- no tuned",
      "# starting values available. ASReml will auto-initialize this",
      "# Trait.ped(ANI_ID) US structure from the data. If convergence is",
      "# poor, consider bootstrapping starting values with !MAXIT 0 (see",
      "# ASReml-4.2-Functional-Specification.pdf Section 5.8) and rerunning",
      "# with !CONTINUE 2 (!TSV)."
    )
    cat("  NOTE: no legacy starting values for ", code_pair,
        " -- see comment in generated .as file\n", sep = "")
  }

  as_lines <- c(
    sprintf(
      "!WORKSPACE %d !CONTINUE !NODISPLAY !LOGFILE !MAXIT %d !MP %d",
      cfg$workspace_mb, cfg$maxit, cfg$mp_threads
    ),
    sprintf("bivariate_%s -- generated by 01_generate_models.R", code_pair),
    field_definition_lines(),
    "",
    cfg$pedigree_file,
    sprintf("%s !SKIP 1 !MVINCLUDE", cfg$phenotype_file),
    "",
    sprintf(
      "%s %s ~ %s !r %s",
      trait1$variable, trait2$variable, fixed_bi, cfg$random_effects$bivariate
    ),
    "",
    structure_block,
    "",
    "VPREDICT !DEFINE",
    "P Vp1 1 2 5",
    "P Vp2 1 4 7",
    "P Cp 3 6",
    "H h2_1 5 Vp1",
    "H h2_2 7 Vp2",
    "R rg 5 6 7",
    "R re 2 3 4",
    "R cp Vp1 Cp Vp2",
    ""
  )
  writeLines(as_lines, file.path(models_dir, sprintf("bi_%s.as", code_pair)))

  pin_lines <- c(
    "P Vp1 1 2 5",
    "P Vp2 1 4 7",
    "P Cp 3 6",
    "H h2_1 5 Vp1",
    "H h2_2 7 Vp2",
    "R rg 5 6 7",
    "R re 2 3 4",
    "R cp Vp1 Cp Vp2"
  )
  writeLines(pin_lines, file.path(models_dir, sprintf("bi_%s.pin", code_pair)))
}

# ---- select what to generate ----

if (set_arg == "validation") {
  uni_codes <- cfg$validation_set$univariate
  bi_pairs <- cfg$validation_set$bivariate
} else if (set_arg %in% c("components", "components_trial")) {
  # Full pairwise (co)variance structure among the 7 underlying component
  # traits (CH4 + 6 denominators), for deriving every ratio/residual
  # trait's h2/rg from component (co)variances instead of fitting each
  # constructed phenotype directly -- docs/revision_plan.md Section 5 step
  # 7, per Julius van der Werf's framework. See
  # scripts/04_derive_ratio_from_components.R for the derivation itself.
  # components_trial is a small representative subset run first.
  set_key <- if (set_arg == "components") "component_set" else "component_trial_set"
  uni_codes <- cfg[[set_key]]$univariate
  bi_pairs <- cfg[[set_key]]$bivariate
} else {
  uni_codes <- sapply(cfg$traits, `[[`, "code")
  if (isTRUE(cfg$full_sweep$generate_all_pairs)) {
    bi_pairs <- combn(uni_codes, 2, simplify = FALSE)
  } else {
    bi_pairs <- list()
  }
  exclude <- cfg$full_sweep$exclude_pairs
  if (length(exclude) > 0) {
    exclude_keys <- sapply(exclude, function(p) paste(sort(unlist(p)), collapse = "|"))
    bi_pairs <- Filter(
      function(p) !(paste(sort(unlist(p)), collapse = "|") %in% exclude_keys),
      bi_pairs
    )
  }
}

cat(sprintf("Generating '%s' set: %d univariate, %d bivariate models\n",
            set_arg, length(uni_codes), length(bi_pairs)))

for (code in uni_codes) {
  trait <- trait_by_code[[code]]
  if (is.null(trait)) stop("Unknown trait code in config: ", code)
  gen_univariate(trait)
  cat("  wrote a_uni_", code, ".as\n", sep = "")
}

for (pair in bi_pairs) {
  t1 <- trait_by_code[[pair[[1]]]]
  t2 <- trait_by_code[[pair[[2]]]]
  if (is.null(t1) || is.null(t2)) stop("Unknown trait code in pair: ", paste(pair, collapse = ","))
  gen_bivariate(t1, t2)
  cat("  wrote bi_", t1$code, "_", t2$code, ".as\n", sep = "")
}

cat("\nDone. Models written to:", models_dir, "\n")
cat("These reference the phenotype/pedigree files by bare filename only --\n")
cat("run scripts/02_stage_run_dir.sh on whichever platform will execute them\n")
cat("to populate run/ before submitting.\n")

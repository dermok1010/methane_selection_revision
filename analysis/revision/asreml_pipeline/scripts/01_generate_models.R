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
stopifnot(set_arg %in% c("validation", "full", "components", "components_trial",
                          "pe_sensitivity", "pe_sensitivity_final"))

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

# ---- functional-syntax !INIT fallback for pairs with no legacy .as file ----
#
# 2026-09-17: bi_methane_co2, bi_methane_adg, bi_methane_rumen and
# bi_mbw_co2 (the 4 of 7 --set=components pairs with no legacy bivariate
# starting values) failed on HPC three submissions running with
# "Iteration aborted because of singularities in AI matrix" -- landing
# on implausible boundary heritabilities (e.g. h2~1.0 or h2~0.0). Root
# cause: CO2's raw genetic variance is ~1000-19000x the other traits' on
# this scale (see run/a_uni_co2 etc., below), and the classic bare
# `Trait.ped(ANI_ID)` term does NOT get Release 4's improved
# phenotypic-variance-based auto-initialisation -- per
# ASReml-4.2-Functional-Specification.pdf Section 7.7.5, that only
# applies "with the functional specification" (i.e. us()/idv()-wrapped
# terms), not the classic bare term names used elsewhere in this
# pipeline for consistency with the legacy .as files.
#
# Fix: for these 4 pairs only, use the functional us(Trait !INIT ...
# !GP).ped(ANI_ID) form with explicit starting values -- diagonal
# (V11, V22) taken from each trait's own converged univariate
# ped(ANI_ID) Sigma (run/a_uni_<code>/*.asr, confirmed CONVERGED
# 2026-09-15/16), and 0 for the starting covariance (C21). This is not
# an invented number: it's the identical "fit diagonal matrices ...
# using initial values from univariate analyses" strategy the manual's
# own worked multivariate example uses for exactly this problem
# (Section 16.11). Order is lower-triangle row-wise, per Section
# 7.7.5's documented requirement for !INIT with us(). !GP keeps the
# matrix positive definite during early iterations, same as every
# other structure block in this pipeline. ide(ANI_ID) is left as the
# plain classic term -- it wasn't implicated in any of the 4 failures.
# ---------------------------------------------------------------------
# Delta-method SEs for component-derived composite-trait h2 (2026-09-17,
# per user's written revision plan A1: "Calculate SEs for the
# component-derived h2 values using the delta method (preferably ASReml
# vpredict ... using the sampling covariance matrix of the variance-
# component estimates)"). scripts/04_derive_ratio_from_components.R
# computes each composite trait's VA/VP point estimate in R from
# univariate_summary.csv + bivariate_summary.csv, but has no SE -- it
# can't, because it combines parameter estimates from SEPARATE ASReml
# runs (a univariate fit and a bivariate fit) with no shared sampling
# covariance matrix between them.
#
# Fix: for composite traits built from exactly the pair (CH4, comp) --
# i.e. every one except RMTMBW+CO2, which needs a third trait -- the
# SAME bivariate model already estimates VA_ch4, CovA and VA_comp
# jointly (indices 5, 6, 7 in this pipeline's documented VPREDICT
# numbering, see the file-header comment), so its own .vvp sampling
# covariance matrix is exactly what the delta method needs. Appending
# extra VPREDICT lines to that SAME bivariate .as/.pin file lets ASReml
# compute both the point estimate AND its correct joint-delta-method SE
# directly -- no new model fit required, just reprocessing the already-
# converged .rsv via the .pin file (see README's "Convergence and
# !CONTINUE" section on .pin post-processing being separate from the
# main iteration).
#
# Coefficients (a1^2, 2*a1*a2, a2^2 for ratio traits; 1, -2b, b^2 for
# linear/residual traits) are precomputed in R from this pipeline's own
# trait means/betas -- IDENTICAL formulas to
# scripts/04_derive_ratio_from_components.R's ratio_result()/
# ratio2_result_ch4ratio()/linear_result_1cov(), so the point estimate
# ASReml reports here should match derived_h2.csv exactly; any
# disagreement is itself a useful cross-check.
#
# Deliberately conservative on VPREDICT grammar: only the two forms
# confirmed in reference/ASReml-4.2-Functional-Specification.pdf Section
# 13.2.1 are used -- "name * coefficient" (single-term scaling, e.g.
# "F genvar idv(Sire) * 4") and pure "+"-separated addition of
# already-named components (e.g. "F phenvar idv(Sire) + idv(units)").
# The manual's compact multi-coefficient-per-line form ("F label a +
# b*cb + c") is NOT used because its grammar for >1 independently
# weighted term per line isn't fully confirmed from available examples
# -- chaining single-coefficient P lines avoids that ambiguity entirely
# at the cost of a few extra lines.
composite_vpredict_specs <- list(
  methane_mbw = list(
    list(prefix = "mi",  h2_name = "mi_h2",  label = "MI=CH4/MBW",
         c1 = 0.0020476511, c2 = -0.0033179877, c3 = 0.0013441062),
    list(prefix = "rtm", h2_name = "rtm_h2", label = "RMTMBW",
         c1 = 1, c2 = -1.5444, c3 = 0.596293)
  ),
  methane_co2 = list(
    list(prefix = "cr", h2_name = "cr_h2", label = "CH4ratio=CH4/(CH4+CO2)",
         c1 = 0.00000066560967, c2 = -0.000000020035280, c3 = 0.00000000015076871)
  ),
  methane_adg = list(
    list(prefix = "ca",  h2_name = "ca_h2",  label = "CH4/ADG",
         c1 = 29.88687532, c2 = -5850.750901, c3 = 286340.4566),
    list(prefix = "rta", h2_name = "rta_h2", label = "RMTADG",
         c1 = 1, c2 = -5.984, c3 = 8.952064)
  ),
  methane_muscle = list(
    list(prefix = "cm", h2_name = "cm_h2", label = "CH4/MM",
         c1 = 0.007288099237, c2 = -0.0222798497, c3 = 0.01702747474)
  ),
  methane_rumen = list(
    list(prefix = "cru", h2_name = "cru_h2", label = "CH4/rumen",
         c1 = 0.02632939992, c2 = -0.1529862087, c3 = 0.2222304736)
  ),
  methane_weight = list(
    list(prefix = "cl", h2_name = "cl_h2", label = "CH4/LW",
         c1 = 0.0002542448978, c2 = -0.0001451674372, c3 = 0.00002072173818)
  )
  # mbw_co2: not given a composite spec here -- it's only used as the
  # third pairwise block for RMTMBW+CO2, which needs all three of
  # (methane,mbw), (methane,co2) and (mbw,co2) simultaneously. A single
  # bivariate model's .vvp cannot give a joint delta-method SE across
  # three separate model fits; that composite's SE stays deferred until
  # a CH4-MBW-CO2 trivariate model is fit (revision plan A1, "if
  # feasible and stable").
)

# Emits the extra VPREDICT lines for a composite trait spec, referencing
# the bivariate model's own indices 5 (VA trait1), 6 (CovA), 7 (VA
# trait2) for the genetic part and the already-defined named quantities
# Vp1/Cp/Vp2 for the phenotypic part (see gen_bivariate's base VPREDICT
# block). p = spec's prefix, used to keep every generated name unique
# and short within the file.
# idx1/idx2/idx3 are the model's own indices for (VA trait1, CovA,
# VA trait2) -- 5,6,7 for the standard shared-PE structure (see the
# file-header comment), but a different, empirically-confirmed triple
# for the PE-sensitivity variant (see petrait_vpredict_lines below),
# since changing the PE structure changes every downstream index.
composite_vpredict_lines_idx <- function(spec, idx1 = 5, idx2 = 6, idx3 = 7) {
  p <- spec$prefix
  # ASReml is a fixed-format Fortran-style parser; scientific notation
  # ("e-07") is avoided in generated coefficients for the same reason
  # already established elsewhere in this generator (see the
  # !INIT starting-value formatting above) -- format(..., scientific =
  # FALSE) with enough digits to not lose precision on the smallest
  # coefficients here (CH4-ratio's are ~1e-10).
  fmt <- function(x) format(x, scientific = FALSE, trim = TRUE, digits = 12)
  c(
    sprintf("# %s (delta-method SE via ASReml VPREDICT, see composite_vpredict_specs)", spec$label),
    sprintf("P %sa1 %d * %s", p, idx1, fmt(spec$c1)),
    sprintf("P %sa2 %d * %s", p, idx2, fmt(spec$c2)),
    sprintf("P %sa3 %d * %s", p, idx3, fmt(spec$c3)),
    sprintf("P %sVA %sa1 + %sa2 + %sa3", p, p, p, p),
    sprintf("P %sp1 Vp1 * %s", p, fmt(spec$c1)),
    sprintf("P %sp2 Cp * %s", p, fmt(spec$c2)),
    sprintf("P %sp3 Vp2 * %s", p, fmt(spec$c3)),
    sprintf("P %sVP %sp1 + %sp2 + %sp3", p, p, p, p),
    sprintf("H %s %sVA %sVP", spec$h2_name, p, p)
  )
}
composite_vpredict_lines <- function(spec) composite_vpredict_lines_idx(spec)

uni_ped_sigma <- c(
  methane = 3.91959,     # run/a_uni_methane -- CONVERGED
  co2     = 19164.6,     # run/a_uni_co2     -- CONVERGED
  adg     = 0.000587469, # run/a_uni_adg     -- CONVERGED
  rumen   = 0.166881,    # run/a_uni_rumen   -- CONVERGED (note: this
                          # trait's ide(ANI_ID) itself had Sigma/SE=0.52,
                          # i.e. barely identifiable -- see README's
                          # note on rumen's 780 records / 3.2% repeat
                          # rate; the ped(ANI_ID) value used here is
                          # still the best available estimate)
  mbw     = 2.19097      # run/a_uni_mbw     -- CONVERGED
)
functional_init_pairs <- c("methane_co2", "methane_adg", "methane_rumen", "mbw_co2")

# ---- PE-sensitivity variant: shared vs. trait-specific permanent
# environment (2026-09-17) --------------------------------------------
#
# Every bivariate model's ide(ANI_ID) term is a SINGLE value shared
# across both traits (config/models.yaml's random_effects$bivariate
# comment: a deliberate, faithful reproduction of the legacy submitted
# analysis's own modelling choice, not a simplification introduced
# here). Cross-checking each bivariate model's own within-model genetic
# variance against that trait's univariate estimate (2026-09-17, see
# docs/revision_plan.md decision log) found this breaks down badly for
# trait pairs whose own PE variances are on very different scales from
# CH4's: bi_methane_weight's within-model VA(weight) came out 2.3x its
# univariate value, bi_methane_co2's VA(co2) came out 2.1x -- consistent
# with PE variance that can't be represented by one shared scalar
# leaking into the genetic (ped) variance estimate instead. mbw/adg/
# muscle/rumen showed only mild (~15-30%) drift, plausibly ordinary
# joint-estimation variation rather than the same structural problem.
#
# Sensitivity check: refit methane_weight and methane_co2 with
# diag(Trait).ide(ANI_ID) instead -- trait-specific PE variances, no PE
# covariance between traits (the more conservative option; a full
# us(Trait).ide(ANI_ID) would add a PE-covariance parameter these
# sparse-repeat traits may not identify well). This is a genuine
# departure from the legacy-faithful model spec, so it's generated as a
# separately-named, separately-versioned variant (suffix _petrait), not
# a silent edit to the original.
#
# Changing the PE structure changes how many parameters ASReml estimates
# and their print order -- the existing VPREDICT index numbering (see
# the file-header comment) was decoded from ONE specific model structure
# and is not safe to reuse blindly here. Per the ASReml manual (Section
# 13.2, "If the user is in doubt of the name or number of a parameter
# then running the program with VPREDICT !DEFINE and a blank line will
# construct a .pvc file with the names and numbers of parameters
# identified"), this generates a DISCOVERY-ONLY run first (no derived
# h2/SE block yet) -- the real index numbering gets read off that run's
# .pvc output before any VPREDICT h2 block is written for these two
# pairs.
pe_sensitivity_pairs <- c("methane_weight", "methane_co2")
uni_ide_sigma <- c(methane = 1.18589, weight = 28.0808, co2 = 17141)

# ---- PE-sensitivity, final .pin (2026-09-17) -------------------------
# The two discovery-only runs above CONVERGED and confirmed the
# diagnosis (weight/co2's within-model genetic variance dropped from
# 2.1-2.3x their univariate values back to within normal ~6-11% drift
# once PE is trait-specific -- see docs/revision_plan.md decision log).
# Real index numbering read off both .pvc files by hand (NOT assumed --
# this is exactly why the discovery step existed): for both pairs,
# Residual prints as 1:3 (V11,C21,V22), the pedigree US block as 4:6
# (V11,C21,V22), then diag(Trait).ide(ANI_ID) as 7:8 (V1,V2) -- PE now
# prints AFTER pedigree, unlike the shared-ide structure where it
# printed first as a single component. diag() has no PE covariance term
# by construction, so Cp (phenotypic covariance) sums only the residual
# and pedigree covariances, matching the original's own convention for
# ide's (non-)contribution to Cp.
petrait_vpredict_lines <- function(composite_spec) {
  base <- c(
    "P Vp1 7 1 4",
    "P Vp2 8 3 6",
    "P Cp 2 5",
    "H h2_1 4 Vp1",
    "H h2_2 6 Vp2",
    "R rg 4 5 6",
    "R re 1 2 3",
    "R cp Vp1 Cp Vp2"
  )
  c(base, composite_vpredict_lines_idx(composite_spec, idx1 = 4, idx2 = 5, idx3 = 6))
}

gen_bivariate_pe_sensitivity_final <- function(jobname, composite_spec) {
  lines <- petrait_vpredict_lines(composite_spec)
  writeLines(lines, file.path(models_dir, sprintf("%s.pin", jobname)))
  cat("  wrote ", jobname, ".pin (final, indices confirmed from discovery run)\n", sep = "")
}

gen_bivariate_pe_sensitivity <- function(trait1, trait2) {
  code_pair <- sprintf("%s_%s", trait1$code, trait2$code)
  ide1 <- uni_ide_sigma[[trait1$code]]
  ide2 <- uni_ide_sigma[[trait2$code]]
  if (is.null(ide1) || is.null(ide2)) {
    stop("No recorded univariate ide(ANI_ID) starting value for ", code_pair,
         " -- add it to uni_ide_sigma above before generating this pair.")
  }
  pe_term <- sprintf(
    "diag(Trait !INIT %s %s).ide(ANI_ID)",
    format(ide1, scientific = FALSE, trim = TRUE),
    format(ide2, scientific = FALSE, trim = TRUE)
  )
  gen_bivariate(trait1, trait2, pe_term = pe_term, discovery_only = TRUE,
                filename_suffix = "_petrait")
}

# ---- bivariate template ----

gen_bivariate <- function(trait1, trait2, pe_term = "ide(ANI_ID)",
                           discovery_only = FALSE, filename_suffix = "") {
  code_pair <- sprintf("%s_%s", trait1$code, trait2$code)
  reverse_pair <- sprintf("%s_%s", trait2$code, trait1$code)

  structure_block <- get_legacy_structure_block(trait1$code, trait2$code)
  random_term <- sub("ide\\(ANI_ID\\)$", pe_term, cfg$random_effects$bivariate)

  if (is.null(structure_block) && (code_pair %in% functional_init_pairs ||
                                    reverse_pair %in% functional_init_pairs)) {
    v11 <- uni_ped_sigma[[trait1$code]]
    v22 <- uni_ped_sigma[[trait2$code]]
    if (is.null(v11) || is.null(v22)) {
      stop("No recorded univariate ped(ANI_ID) starting value for ", code_pair,
           " -- add it to uni_ped_sigma above before generating this pair.")
    }
    random_term <- sprintf(
      "us(Trait !INIT %s 0 %s !GP).ped(ANI_ID) %s",
      format(v11, scientific = FALSE, trim = TRUE),
      format(v22, scientific = FALSE, trim = TRUE),
      pe_term
    )
    structure_block <- c(
      "# Functional-syntax !INIT starting values used instead of a legacy",
      "# structure block -- see uni_ped_sigma/functional_init_pairs comment",
      "# above this function for the full explanation. Starting values are",
      "# in the model line itself (us(Trait !INIT ...)), not here."
    )
    cat("  NOTE: ", code_pair,
        " -- no legacy starting values; using functional us(Trait !INIT ",
        format(v11, scientific = FALSE, trim = TRUE), " 0 ",
        format(v22, scientific = FALSE, trim = TRUE),
        " !GP).ped(ANI_ID)\n", sep = "")
  } else if (is.null(structure_block)) {
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

  # discovery_only pairs (PE-sensitivity variants) skip the numbered
  # VPREDICT block entirely -- the parameter order for a changed
  # structure isn't known yet (see gen_bivariate_pe_sensitivity's header
  # comment), so guessing indices here would repeat exactly the mistake
  # this cross-check was designed to catch.
  composite_specs <- if (discovery_only) NULL else composite_vpredict_specs[[code_pair]]
  composite_lines <- if (!is.null(composite_specs)) {
    unlist(lapply(composite_specs, composite_vpredict_lines))
  } else {
    character(0)
  }
  vpredict_lines <- if (discovery_only) {
    c(
      "# Discovery-only VPREDICT: no derived quantities yet. Per",
      "# ASReml-4.2-Functional-Specification.pdf Section 13.2, a bare",
      "# VPREDICT !DEFINE + blank line reports every parameter's real",
      "# name and number in the .pvc file -- read those off before",
      "# writing any h2/SE block for this changed model structure."
    )
  } else {
    c(
      "P Vp1 1 2 5",
      "P Vp2 1 4 7",
      "P Cp 3 6",
      "H h2_1 5 Vp1",
      "H h2_2 7 Vp2",
      "R rg 5 6 7",
      "R re 2 3 4",
      "R cp Vp1 Cp Vp2",
      composite_lines
    )
  }
  out_name <- sprintf("bi_%s%s", code_pair, filename_suffix)

  as_lines <- c(
    sprintf(
      "!WORKSPACE %d !CONTINUE !NODISPLAY !LOGFILE !MAXIT %d !MP %d",
      cfg$workspace_mb, cfg$maxit, cfg$mp_threads
    ),
    sprintf("bivariate_%s -- generated by 01_generate_models.R", out_name),
    field_definition_lines(),
    "",
    cfg$pedigree_file,
    sprintf("%s !SKIP 1 !MVINCLUDE", cfg$phenotype_file),
    "",
    sprintf(
      "%s %s ~ %s !r %s",
      trait1$variable, trait2$variable, fixed_bi, random_term
    ),
    "",
    structure_block,
    "",
    "VPREDICT !DEFINE",
    vpredict_lines,
    ""
  )
  writeLines(as_lines, file.path(models_dir, sprintf("%s.as", out_name)))

  pin_lines <- vpredict_lines
  writeLines(pin_lines, file.path(models_dir, sprintf("%s.pin", out_name)))
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
} else if (set_arg == "pe_sensitivity") {
  # See gen_bivariate_pe_sensitivity's header comment -- no univariate
  # models needed (reuses existing converged ones' ide estimates as
  # !INIT values), just the 2 discovery-only bivariate pairs.
  uni_codes <- character(0)
  bi_pairs <- lapply(pe_sensitivity_pairs, function(p) strsplit(p, "_")[[1]])
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

if (set_arg == "pe_sensitivity_final") {
  # Writes ONLY the .pin (not .as) for the 2 PE-sensitivity pairs, using
  # the index numbering confirmed from their discovery runs' real .pvc
  # output (see petrait_vpredict_lines' header comment) -- these already
  # CONVERGED, so only .pin post-processing is needed, not a fresh fit.
  gen_bivariate_pe_sensitivity_final("bi_methane_weight_petrait",
                                      composite_vpredict_specs[["methane_weight"]][[1]])
  gen_bivariate_pe_sensitivity_final("bi_methane_co2_petrait",
                                      composite_vpredict_specs[["methane_co2"]][[1]])
  cat("\nDone.\n")
  quit(save = "no", status = 0)
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
  if (set_arg == "pe_sensitivity") {
    gen_bivariate_pe_sensitivity(t1, t2)
    cat("  wrote bi_", t1$code, "_", t2$code, "_petrait.as (discovery-only)\n", sep = "")
  } else {
    gen_bivariate(t1, t2)
    cat("  wrote bi_", t1$code, "_", t2$code, ".as\n", sep = "")
  }
}

cat("\nDone. Models written to:", models_dir, "\n")
cat("These reference the phenotype/pedigree files by bare filename only --\n")
cat("run scripts/02_stage_run_dir.sh on whichever platform will execute them\n")
cat("to populate run/ before submitting.\n")

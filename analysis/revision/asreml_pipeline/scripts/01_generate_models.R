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
#   Rscript 01_generate_models.R --set=stage_het    # Reviewer 1 CG-
#                                                   # heteroscedasticity:
#                                                   # residual sat(stage_660)
#                                                   # for each Table 2 trait
#   Rscript 01_generate_models.R --set=young_old    # young(<660d)-vs-
#                                                   # mature CH4 bivariate
#                                                   # genetic correlation
#   Rscript 01_generate_models.R --set=bi_cg_het_trial
#                                                   # one discovery-only
#                                                   # CH4 x CH4/MBW prototype
#                                                   # with CG-mean-class-
#                                                   # specific residual US
#                                                   # matrices (Reviewer 1)
#   Rscript 01_generate_models.R --set=key_bivariates
#                                                   # 2026-09-20 curated
#                                                   # bivariate matrix (23
#                                                   # pairs) -- supersedes
#                                                   # --set=full as the
#                                                   # production target,
#                                                   # see config's
#                                                   # key_bivariates_*
#                                                   # comment
#   Rscript 01_generate_models.R --set=key_bivariates_cg_het
#                                                   # CG-heterogeneous
#                                                   # residual variant of
#                                                   # the 18 key_bivariates
#                                                   # pairs involving a
#                                                   # trait where cg_het
#                                                   # mattered. Generation
#                                                   # only -- do not submit
#                                                   # before bi_cg_het_trial
#                                                   # confirms the structure
#                                                   # is stable (see config
#                                                   # comment)
#   Rscript 01_generate_models.R --set=mol_ratio   # 2026-09-21: CH4 ratio
#                                                   # on a molar basis
#                                                   # (ch4_ratio_mol) --
#                                                   # its own univariate
#                                                   # model plus a bivariate
#                                                   # vs. the mass-basis
#                                                   # ch4_ratio, see config's
#                                                   # mol_ratio_set comment
#   Rscript 01_generate_models.R --set=bi_stage_het_scale_trial
#                                                   # 2026-09-23: after
#                                                   # sat(stage_660).us(Trait)
#                                                   # hit MAX_ATTEMPTS_EXCEEDED
#                                                   # for methane x ch4mbw
#                                                   # (Trait 2 PE pinned at a
#                                                   # zero boundary), retry
#                                                   # with idh(stage_660)
#                                                   # .us(Trait).units --
#                                                   # per-stage residual
#                                                   # scale, one shared trait
#                                                   # correlation -- for
#                                                   # methane x ch4mbw AND
#                                                   # methane x mbw
#
# Writes into <pipeline_root>/models/ (git-tracked). Does not run ASReml,
# does not touch run/. See README.md for the full VM -> HPC workflow.
#
# ---------------------------------------------------------------------
# CAUTION on regenerating an already-run job under the SAME name with a
# DIFFERENT model structure (2026-09-21, bi_ch4ratio_ch4ratiomol): every
# generated .as carries !CONTINUE, which makes ASReml resume from any
# <jobname>.rsv already sitting in run/<jobname>/. If that .rsv was
# written by a PREVIOUS run of a structurally different model (e.g.
# switching from a shared ide(ANI_ID) PE term to independent
# diag(Trait).ide(ANI_ID), as choose_pe_term() does automatically once a
# trait's univariate estimate lands in results/univariate_summary.csv),
# the parameter count/order no longer matches and ASReml silently
# restarts from garbage values -- observed here as a residual variance
# of 52 and -87 (real scale: ~1e-5) and "Iteration aborted because of
# singularities in AI matrix". This is why every other structural
# revision in this pipeline (_petrait, _cg_het, _cg_het_trial, etc.)
# uses a NEW suffixed job name rather than overwriting the original --
# that sidesteps this entirely by giving it a fresh run/ directory. If a
# job's .as must be regenerated in place with a changed structure, `rm
# -rf run/<jobname>` before re-staging so there is nothing stale to
# restart from.
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
                          "pe_sensitivity", "pe_sensitivity_final",
                          "stage_het", "young_old", "young_old_final", "cg_het",
                          "bi_cg_het_trial", "key_bivariates", "key_bivariates_cg_het",
                          "key_bivariates_final", "bi_cg_het_scale_trial",
                          "key_bivariates_cg_het_scale", "mol_ratio",
                          "bi_stage_het_trial", "bi_stage_het_scale_trial",
                          "bi_stage_split"))

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
  mbw     = 2.19097,     # run/a_uni_mbw     -- CONVERGED
  # Added 2026-09-20: the same "no legacy starting values -> classic
  # bare Trait.ped(ANI_ID) auto-init fails" problem hit 9 of the 23
  # key_bivariates pairs (all either an alt-methane-definition-vs-CH4
  # pair with no prior legacy .as, or a ratio/residual trait paired
  # against its own denominator -- an entirely new category with no
  # legacy counterpart at all). Values read from results/
  # univariate_summary.csv's real CONVERGED sigma_ped column (pulled
  # back from HPC), not re-derived.
  ch4adg        = 1290.36,     # results/univariate_summary.csv -- CONVERGED
  ch4rmtmbwco2  = 2.7319,      # results/univariate_summary.csv -- CONVERGED
  ch4rmtadg     = 2.40876,     # results/univariate_summary.csv -- CONVERGED
  ch4ratio      = 1.94886e-06, # results/univariate_summary.csv -- CONVERGED
  ch4rmtmbw     = 2.53612,     # results/univariate_summary.csv -- CONVERGED
  ch4muscle     = 0.0382923,   # results/univariate_summary.csv -- CONVERGED
  muscle        = 0.396422     # results/univariate_summary.csv -- CONVERGED
)
functional_init_pairs <- c(
  "methane_co2", "methane_adg", "methane_rumen", "mbw_co2",
  # Added 2026-09-20 (see uni_ped_sigma comment above): same fix,
  # extended to the 9 key_bivariates pairs that failed with the classic
  # bare genetic term. Confirmed 2026-09-20 that the functional-!INIT
  # form uses the IDENTICAL VPREDICT parameter numbering (1:3 Residual,
  # 4:6 genetic, 7:8 PE) as the classic form -- methane_co2/adg/rumen/
  # mbw_co2 above already use this same final numbering successfully
  # (check_agree_rg/rp both TRUE), so no separate discovery step is
  # needed for these 9 either.
  "methane_ch4adg", "methane_ch4rmtmbwco2", "methane_ch4rmtadg",
  "ch4ratio_co2", "ch4rmtmbw_mbw", "ch4rmtmbwco2_co2",
  "ch4rmtadg_adg", "ch4adg_adg", "ch4muscle_muscle"
)

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
petrait_vpredict_lines <- function(composite_spec = NULL) {
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
  if (is.null(composite_spec)) return(base)
  c(base, composite_vpredict_lines_idx(composite_spec, idx1 = 4, idx2 = 5, idx3 = 6))
}

gen_bivariate_pe_sensitivity_final <- function(jobname, composite_spec) {
  lines <- petrait_vpredict_lines(composite_spec)
  writeLines(lines, file.path(models_dir, sprintf("%s.pin", jobname)))
  cat("  wrote ", jobname, ".pin (final, indices confirmed from discovery run)\n", sep = "")
}

# ---- key_bivariates final .pin (2026-09-20) ----------------------------
# Real parameter numbering (1:3 Residual, 4:6 genetic, 7:8 independent
# PE) confirmed against a converged bi_methane_ch4mbw.asr -- identical to
# the petrait numbering above, now confirmed on a THIRD, previously-
# unchecked pair, all sharing the same independent-PE term declaration
# order (see docs/revision_plan.md decision log). Applies to every
# key_bivariates pair since all 23 used independent PE at generation
# time (none fell back to shared ide(ANI_ID) -- every pair had both
# traits' CONVERGED univariate estimates on file). Reuses
# petrait_vpredict_lines() rather than re-deriving the same 8 indices a
# third time. Where a pair has a composite_vpredict_specs entry (the 6
# methane-vs-component pairs, e.g. methane_mbw -> MI + RMTMBW), appends
# ALL of that pair's composite delta-method blocks (a pair can have more
# than one composite trait depending on it), giving derived_h2.csv a
# path to be regenerated from these SAME independent-PE fits instead of
# the stale pre-2026-09-18 shared-PE ones.
gen_key_bivariates_final <- function(code_pair) {
  specs <- composite_vpredict_specs[[code_pair]]
  lines <- petrait_vpredict_lines()
  if (!is.null(specs)) {
    lines <- c(lines, unlist(lapply(specs, function(s) {
      composite_vpredict_lines_idx(s, idx1 = 4, idx2 = 5, idx3 = 6)
    })))
  }
  writeLines(lines, file.path(models_dir, sprintf("bi_%s.pin", code_pair)))
  cat("  wrote bi_", code_pair, ".pin (final, indices confirmed against a converged key_bivariates .asr",
      if (!is.null(specs)) ", incl. composite h2 delta-method SE" else "", ")\n", sep = "")
}

# ---- bi_young_old final .pin (2026-09-18) -------------------------------
# Real parameter numbering read off run/bi_young_old/bi_young_old.pvc on
# HPC after CONVERGED (not assumed -- this model's structure is unique on
# this VM: idh(Trait).units residual, diag(Trait).ide(ANI_ID) PE with no
# at(Trait,i) restriction so BOTH traits have a PE term, us(Trait).ped
# genetic):
#   1 = idh(Trait).units, young residual variance (9.12208)
#   2 = idh(Trait).units, old residual variance   (10.7478)
#   3 = us(Trait).ped(ANI_ID) V(1,1), young genetic variance (1.23722)
#   4 = us(Trait).ped(ANI_ID) C(2,1), genetic covariance     (1.87648)
#   5 = us(Trait).ped(ANI_ID) V(2,2), old genetic variance   (2.89891)
#   6 = diag(Trait).ide(ANI_ID), young PE variance (0.00000, boundary/B)
#   7 = diag(Trait).ide(ANI_ID), old PE variance   (4.00575)
# idh(Trait) has no residual covariance term by construction (that's the
# whole point of the fix -- it's structurally inestimable, see
# gen_bivariate_young_old's header comment), so there is no "re"
# (residual correlation) to compute here, unlike the standard bivariate
# template's re line.
#
# ASReml's R statistic puts the NUMERATOR in the MIDDLE position, not
# first -- "R name idx1 idx2 idx3" computes idx2/sqrt(idx1*idx3), i.e.
# (var1, covariance, var2), not (covariance, var1, var2). Got this wrong
# the first time (wrote "R rg 4 3 5", which computed var1/sqrt(cov*var2)
# = 0.5305 -- nonsense) and only caught it because ASReml's own printed
# rg didn't match the correlation matrix it had already printed
# separately (0.9902). Confirmed correct by cross-referencing the
# already-working "R rp Vp1 Cp Vp2" line right below (Cp, the named
# covariance parameter, is also in the middle) and the standard
# bivariate template's "R rg 5 6 7" (index 6 = covariance, per this
# file's own header-comment numbering of the classic structure).
gen_young_old_final <- function() {
  lines <- c(
    "P Vp1 1 3 6",
    "P Vp2 2 5 7",
    "P Cp 4",
    "H h2_1 3 Vp1",
    "H h2_2 5 Vp2",
    "R rg 3 4 5",
    "R rp Vp1 Cp Vp2"
  )
  writeLines(lines, file.path(models_dir, "bi_young_old.pin"))
  cat("  wrote bi_young_old.pin (final, indices confirmed from converged .pvc)\n")
}

# ---- Independent PE for all --set=full bivariate models (2026-09-18,
# per user instruction) --------------------------------------------------
#
# The 2026-09-17 PE-sensitivity check above (methane_weight, methane_co2)
# confirmed the shared ide(ANI_ID) structural problem is real, but was
# deliberately scoped to only the 2 pairs with >2x genetic-variance
# inflation -- docs/revision_plan.md's 2026-09-17 decision log entry
# explicitly left "this remains an open question" for the other pairs
# (mbw/adg/muscle/rumen), which showed milder (~15-30%) drift and were not
# resubmitted. The user has now closed that open question: every bivariate
# model should use independent (trait-specific) PE where possible, not
# just the 2 worst-affected pairs.
#
# "Where possible" = a real, CONVERGED univariate ide(ANI_ID) estimate
# exists for BOTH traits in results/univariate_summary.csv (written by
# 03_parse_results.R) to seed diag(Trait !INIT ...).ide(ANI_ID)'s starting
# values -- diag() is a log-linked variance component and cannot start at
# exactly 0, so a value is floored at a small positive epsilon rather than
# used raw. If either trait has no CONVERGED univariate result on file
# (never fit, or failed to converge), this falls back to the original
# shared ide(ANI_ID) term and says why in a comment in the generated file
# -- this is the genuine "not possible" case, not a judgement that the
# fix doesn't apply.
#
# Every pair using the new diag(Trait) structure is generated
# discovery-only (see gen_bivariate_pe_sensitivity's header comment above
# for why: changing the PE structure changes the VPREDICT parameter print
# order, and that order is only actually confirmed, from real .pvc output,
# for the 2 pilot pairs' specific model structure -- not assumed to
# generalize to every pair without checking, per this pipeline's own
# stated discipline). Pairs that fall back to shared ide(ANI_ID) keep the
# original, already-confirmed non-discovery VPREDICT numbering unchanged.
uni_summary_path <- file.path(pipeline_root, "results", "univariate_summary.csv")
uni_ide_sigma_full <- list()
uni_convergence_full <- list()
if (file.exists(uni_summary_path)) {
  usum <- read.csv(uni_summary_path, stringsAsFactors = FALSE)
  uni_ide_sigma_full <- setNames(as.list(usum$sigma_ide), usum$trait_code)
  uni_convergence_full <- setNames(as.list(usum$convergence), usum$trait_code)
} else {
  cat("WARNING: ", uni_summary_path, " not found -- every pair will fall ",
      "back to the shared ide(ANI_ID) term (no univariate PE estimates ",
      "available yet to seed independent PE). Run scripts/03_parse_results.R ",
      "once the univariate sweep has CONVERGED on HPC, then regenerate.\n",
      sep = "")
}

choose_pe_term <- function(trait1, trait2) {
  ide1 <- uni_ide_sigma_full[[trait1$code]]
  ide2 <- uni_ide_sigma_full[[trait2$code]]
  ok1 <- !is.null(ide1) && !is.na(ide1) &&
    isTRUE(uni_convergence_full[[trait1$code]] == "CONVERGED")
  ok2 <- !is.null(ide2) && !is.na(ide2) &&
    isTRUE(uni_convergence_full[[trait2$code]] == "CONVERGED")
  if (!ok1 || !ok2) {
    missing_code <- if (!ok1) trait1$code else trait2$code
    return(list(
      term = "ide(ANI_ID)", independent = FALSE,
      note = sprintf(
        "independent PE not used for %s_%s -- no CONVERGED univariate ide(ANI_ID) estimate on file for %s in results/univariate_summary.csv. Falling back to the legacy shared ide(ANI_ID) term.",
        trait1$code, trait2$code, missing_code)
    ))
  }
  eps <- 1e-6  # diag() variance components are log-linked; cannot start at exactly 0
  fmt_init <- function(x) format(x, scientific = FALSE, trim = TRUE, digits = 12)
  list(
    term = sprintf("diag(Trait !INIT %s %s).ide(ANI_ID)",
                    fmt_init(max(ide1, eps)), fmt_init(max(ide2, eps))),
    independent = TRUE, note = NULL
  )
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
                           discovery_only = FALSE, filename_suffix = "",
                           note = NULL, genetic_term = NULL,
                           genetic_term_reason = NULL,
                           residual_term = NULL,
                           ignore_legacy_structure = FALSE,
                           phenotype_file = NULL) {
  # phenotype_file overrides cfg$phenotype_file for this job only -- used
  # by gen_bivariate_stage_split() (2026-09-23) to point a job at a
  # stage-660-filtered phenotype file instead of the full dataset. NULL
  # (the default) means every other caller is unaffected.
  if (is.null(phenotype_file)) phenotype_file <- cfg$phenotype_file
  code_pair <- sprintf("%s_%s", trait1$code, trait2$code)
  reverse_pair <- sprintf("%s_%s", trait2$code, trait1$code)

  # A pair in functional_init_pairs needs the functional us(Trait !INIT
  # ...).ped(ANI_ID) form specifically because the classic bare
  # Trait.ped(ANI_ID) term doesn't get ASReml's improved auto-init
  # (Section 7.7.5) -- true regardless of whether a legacy structure
  # block with tuned classic-form starting values happens to exist for
  # this pair. Confirmed 2026-09-20: bi_ch4rmtadg_adg and
  # bi_ch4muscle_muscle DO have legacy .as files (with real tuned
  # classic-form starting values), and still landed on degenerate
  # boundary/near-singular fits under the new independent-PE structure
  # -- the legacy values were tuned for the old shared-PE model, and the
  # classic-form auto-init limitation applies independent of whether
  # starting values are supplied. So functional_init_pairs membership
  # overrides legacy-block lookup, not just the "no legacy block found"
  # fallback.
  force_functional <- code_pair %in% functional_init_pairs || reverse_pair %in% functional_init_pairs
  structure_block <- if (isTRUE(ignore_legacy_structure) || force_functional) {
    NULL
  } else {
    get_legacy_structure_block(trait1$code, trait2$code)
  }
  random_term <- sub("ide\\(ANI_ID\\)$", pe_term, cfg$random_effects$bivariate)

  if (is.null(structure_block) && !is.null(genetic_term)) {
    # Explicit override (e.g. bi_young_old.as): the classic bare
    # Trait.ped(ANI_ID) term doesn't get ASReml's improved phenotypic-
    # variance-based auto-initialisation (Functional-Specification.pdf
    # Section 7.7.5 -- confirmed the hard way 2026-09-18: bi_young_old.as
    # aborted after 1 iteration with "singularities in AI matrix" using
    # the classic form, then converged cleanly in the sibling
    # sheep-methane-genomics-microbiome repo's bi_ch4_microtrait.as using
    # this same functional us(Trait).ped(ANI_ID) form with no !INIT).
    random_term <- sub("^Trait\\.ped\\(ANI_ID\\)", genetic_term, random_term)
    # Default reason text is specifically what was confirmed for
    # bi_young_old (2026-09-18) -- do NOT reuse this default for a
    # different pair without evidence, since it makes a per-pair
    # empirical claim ("aborted this specific pair") that would be
    # false for any pair never actually tried with the classic form.
    # Callers generalizing this override to other pairs (e.g. the
    # cg_het functions below) must pass their own accurate
    # genetic_term_reason instead.
    reason_lines <- if (!is.null(genetic_term_reason)) {
      genetic_term_reason
    } else {
      c(
        "# Trait.ped(ANI_ID) -- the classic form doesn't get ASReml's",
        "# improved auto-initialisation and aborted this specific pair",
        "# after 1 iteration with an AI-matrix singularity (2026-09-18).",
        "# No !INIT values available (no prior univariate fit of either",
        "# pseudo-trait to seed one from) -- functional syntax still gets",
        "# the improved auto-init regardless."
      )
    }
    structure_block <- c(
      sprintf("# Functional-syntax genetic term (%s), not classic bare", genetic_term),
      reason_lines
    )
    cat("  NOTE: ", code_pair, " -- using functional ", genetic_term, "\n", sep = "")
  } else if (is.null(structure_block) && (code_pair %in% functional_init_pairs ||
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
    legacy_overridden <- !is.null(get_legacy_structure_block(trait1$code, trait2$code))
    structure_block <- c(
      if (legacy_overridden) {
        c("# A legacy bi_*.as structure block EXISTS for this pair but is",
          "# deliberately overridden -- functional_init_pairs membership",
          "# means the classic bare Trait.ped(ANI_ID) auto-init problem",
          "# applies regardless of whether starting values are supplied",
          "# (confirmed 2026-09-20 for this exact pair). See uni_ped_sigma/",
          "# functional_init_pairs comment above this function.")
      } else {
        c("# Functional-syntax !INIT starting values used instead of a legacy",
          "# structure block -- see uni_ped_sigma/functional_init_pairs comment",
          "# above this function for the full explanation.")
      },
      "# Starting values are in the model line itself (us(Trait !INIT ...)), not here."
    )
    cat("  NOTE: ", code_pair,
        if (legacy_overridden) " -- legacy starting values overridden; using functional us(Trait !INIT "
        else " -- no legacy starting values; using functional us(Trait !INIT ",
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

  if (!is.null(note)) {
    structure_block <- c(sprintf("# NOTE: %s", note), structure_block)
  }

  as_lines <- c(
    sprintf(
      "!WORKSPACE %d !CONTINUE !NODISPLAY !LOGFILE !MAXIT %d !MP %d",
      cfg$workspace_mb, cfg$maxit, cfg$mp_threads
    ),
    sprintf("bivariate_%s -- generated by 01_generate_models.R", out_name),
    field_definition_lines(),
    "",
    cfg$pedigree_file,
    # !ASUV required whenever the residual structure is anything other
    # than the US default (Functional-Specification.pdf Section 8.2:
    # "to use an error structure other than US for the residual stratum
    # you must also specify !ASUV ... and include mv in the model if
    # there are missing values") -- confirmed the hard way 2026-09-18:
    # without it, idh(Trait).units aborted immediately with "Missing
    # values in the data are not accommodated in the model specified."
    sprintf(
      "%s !SKIP 1 !MVINCLUDE%s",
      phenotype_file, if (!is.null(residual_term)) " !ASUV" else ""
    ),
    "",
    sprintf(
      "%s %s ~ %s%s !r %s",
      trait1$variable, trait2$variable, fixed_bi,
      if (!is.null(residual_term)) " mv" else "",
      random_term
    ),
    if (!is.null(residual_term)) sprintf("residual %s", residual_term) else character(0),
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

# ---- stage-heterogeneous-residual template (Reviewer 1) ----
#
# Generalizes analysis/diagnostics/reviewer_a2_a3/a_ch4_stage_het_residual.as
# (CH4 only, CONVERGED on HPC 2026-09-17, real ~2.4x residual-variance
# difference found between stages) to any trait: identical fixed/random-
# effects specification to gen_univariate, but with
# `residual sat(stage_660).idv(units)` instead of a single pooled residual
# variance. Discovery-only VPREDICT, same discipline as that pilot and as
# gen_bivariate_pe_sensitivity above -- sat(stage_660).idv(units) is a new
# residual structure for every trait except CH4 (whose real parameter
# numbering was confirmed at 1=ped, 2=ide, 3=sat(stage,1), 4=sat(stage,2)
# for the OLD age_in_years<2 stage split; not assumed to carry over here,
# both because the split variable changed and because this pipeline does
# not assume numbering generalizes across traits without checking).
gen_univariate_stage_het <- function(trait) {
  as_lines <- c(
    sprintf(
      "!WORKSPACE %d !CONTINUE !NODISPLAY !LOGFILE !MAXIT %d !MP %d",
      cfg$workspace_mb, cfg$maxit, cfg$mp_threads
    ),
    sprintf("univariate_%s_stage_het -- generated by 01_generate_models.R, see README's Reviewer-1 CG-heteroscedasticity section", trait$code),
    field_definition_lines(),
    "",
    cfg$pedigree_file,
    sprintf("%s !SKIP 1 !MVINCLUDE", cfg$phenotype_file),
    "",
    sprintf(
      "%s ~ %s !r %s",
      trait$variable, fixed_uni, cfg$random_effects$univariate
    ),
    "residual sat(stage_660).idv(units)",
    "",
    "VPREDICT !DEFINE",
    "# Discovery-only: per ASReml-4.2-Functional-Specification.pdf Section",
    "# 13.2, a bare VPREDICT !DEFINE + blank line reports every parameter's",
    "# real name and number in the .pvc file -- read those off before",
    "# writing any stage-specific h2/repeatability block for this trait.",
    ""
  )
  writeLines(as_lines, file.path(models_dir, sprintf("a_uni_%s_stage_het.as", trait$code)))

  pin_lines <- c(
    "# Discovery-only: see the .as file's VPREDICT comment."
  )
  writeLines(pin_lines, file.path(models_dir, sprintf("a_uni_%s_stage_het.pin", trait$code)))
}

# ---- contemporary-group-mean heterogeneous-residual template (Reviewer 1) ----
#
# More direct than gen_univariate_stage_het's age-based proxy: residual
# variance heterogeneous by cg_mean_cl (up to 41 classes -- each
# ch4_GroupNumber's own mean CH4, tertile-binned within its data source,
# see scripts/00_prepare_asreml_phenotype.R and config/models.yaml's
# cg_het_traits comment for the full method, adapted directly from a real
# prior analysis the user had already built for a related project).
# Discovery-only, same discipline as gen_univariate_stage_het -- this is
# an even-newer residual structure (a 41-level classification never used
# in this pipeline before) than stage_660's 2-level one.
gen_univariate_cg_het <- function(trait) {
  as_lines <- c(
    sprintf(
      "!WORKSPACE %d !CONTINUE !NODISPLAY !LOGFILE !MAXIT %d !MP %d",
      cfg$workspace_mb, cfg$maxit, cfg$mp_threads
    ),
    sprintf("univariate_%s_cg_het -- generated by 01_generate_models.R, see README's Reviewer-1 CG-heteroscedasticity section", trait$code),
    field_definition_lines(),
    "",
    cfg$pedigree_file,
    sprintf("%s !SKIP 1 !MVINCLUDE", cfg$phenotype_file),
    "",
    sprintf(
      "%s ~ %s !r %s",
      trait$variable, fixed_uni, cfg$random_effects$univariate
    ),
    "residual sat(cg_mean_cl).idv(units)",
    "",
    "VPREDICT !DEFINE",
    "# Discovery-only: per ASReml-4.2-Functional-Specification.pdf Section",
    "# 13.2, a bare VPREDICT !DEFINE + blank line reports every parameter's",
    "# real name and number in the .pvc file -- read those off before",
    "# writing any class-specific h2/repeatability block for this trait.",
    ""
  )
  writeLines(as_lines, file.path(models_dir, sprintf("a_uni_%s_cg_het.as", trait$code)))

  pin_lines <- c(
    "# Discovery-only: see the .as file's VPREDICT comment."
  )
  writeLines(pin_lines, file.path(models_dir, sprintf("a_uni_%s_cg_het.pin", trait$code)))
}

# ---- CG-heterogeneous bivariate prototype (Reviewer 1) --------------
#
# 2026-09-18 follow-up after the univariate cg_het sweep.  The rich
# source-within-CG-mean residual structure was estimable for the
# full-information methane definitions but not for the ADG/CT subsets.
# Before propagating heterogeneous residuals into a broad bivariate
# sweep, fit ONE central full-data pair (CH4 x CH4/MBW) as a discovery
# model and compare its genetic correlation with the current
# homogeneous-residual estimate.
#
# This is deliberately a stress-test rather than a final production
# specification: sat(cg_mean_cl).us(Trait).units gives every
# source-within-mean class its own 2x2 residual US matrix (variance 1,
# covariance, variance 2). With ~30 classes this is ~90 residual
# parameters. If this proves unstable or non-estimable, do NOT force
# convergence or infer that residual heterogeneity is irrelevant; the
# next step is a more parsimonious heterogeneous-scale/common-correlation
# structure. Discovery-only VPREDICT because the parameter ordering is
# unique to this model and must be read from its real .pvc/.asr output.
# Functional us(Trait).ped(ANI_ID) is used here for the CG-heterogeneous
# residual structure's own sake -- any functional-syntax term gets
# ASReml's improved phenotypic-variance-based auto-initialisation
# (Functional-Specification.pdf Section 7.7.5), which is worth having
# for a ~90-parameter residual structure regardless of whether the
# classic bare Trait.ped(ANI_ID) form would also have worked. This is
# NOT a claim that the classic form was tried and failed for these
# specific pairs (only bi_young_old, a different model entirely, was
# actually tested that way) -- see gen_bivariate's genetic_term_reason
# parameter.
cg_het_genetic_term_reason <- c(
  "# Trait.ped(ANI_ID) -- functional syntax is used deliberately here",
  "# to get ASReml's improved auto-initialisation for this parameter-",
  "# rich CG-heterogeneous residual structure. This is NOT a claim that",
  "# the classic bare form was tried and failed for this specific pair",
  "# (untested) -- unlike bi_young_old, where that was actually",
  "# confirmed. No !INIT values given for the genetic term since none",
  "# apply cleanly to the classic-vs-functional distinction here."
)

gen_bivariate_cg_het_trial <- function() {
  t1 <- trait_by_code[["methane"]]
  t2 <- trait_by_code[["ch4mbw"]]
  if (is.null(t1) || is.null(t2)) {
    stop("methane/ch4mbw trait definitions missing from config/models.yaml")
  }
  pe <- choose_pe_term(t1, t2)
  note <- paste(
    "Reviewer-1 CG-heterogeneity prototype only:",
    "CH4 x CH4/MBW with class-specific residual US matrices;",
    "discovery-only; do not generalise to the full bivariate sweep",
    "unless the fit is stable and scientifically useful."
  )
  gen_bivariate(
    t1, t2,
    pe_term = pe$term,
    discovery_only = TRUE,
    filename_suffix = "_cg_het_trial",
    note = note,
    genetic_term = "us(Trait).ped(ANI_ID)",
    genetic_term_reason = cg_het_genetic_term_reason,
    residual_term = "sat(cg_mean_cl).us(Trait).units",
    ignore_legacy_structure = TRUE
  )
}

# ---- CG-heterogeneous bivariate matrix, generalized (2026-09-20) ------
#
# Same model structure as gen_bivariate_cg_het_trial (the single CH4 x
# CH4/MBW prototype above), parameterized to any pair -- generates the
# key_bivariates_cg_het list from config/models.yaml (18 pairs: every
# key_bivariates pair with at least one trait in cg_het's 5-trait
# "matters" set). See that config list's comment for why these are
# generated but must NOT be submitted to HPC before the single prototype
# above has confirmed the structure actually converges to something
# sensible -- generating them now just means they're ready the moment
# that check passes, not that they should run immediately.
gen_bivariate_cg_het <- function(code1, code2) {
  t1 <- trait_by_code[[code1]]
  t2 <- trait_by_code[[code2]]
  if (is.null(t1) || is.null(t2)) {
    stop("Unknown trait code in key_bivariates_cg_het pair: ", code1, ",", code2)
  }
  pe <- choose_pe_term(t1, t2)
  note <- paste(
    "Reviewer-1 CG-heterogeneity follow-up (2026-09-20, generalized from",
    "the bi_methane_ch4mbw_cg_het_trial prototype):",
    sprintf("%s x %s", t1$code, t2$code),
    "with class-specific residual US matrices; discovery-only; DO NOT",
    "submit before the single trial prototype has confirmed this",
    "structure is stable -- see config/models.yaml's key_bivariates_cg_het",
    "comment."
  )
  gen_bivariate(
    t1, t2,
    pe_term = pe$term,
    discovery_only = TRUE,
    filename_suffix = "_cg_het",
    note = note,
    genetic_term = "us(Trait).ped(ANI_ID)",
    genetic_term_reason = cg_het_genetic_term_reason,
    residual_term = "sat(cg_mean_cl).us(Trait).units",
    ignore_legacy_structure = TRUE
  )
}

# ---- CG-heterogeneous-SCALE bivariate prototype (2026-09-20 follow-up) --
#
# bi_methane_ch4mbw_cg_het_trial (sat(cg_mean_cl).us(Trait).units, above)
# failed outright on HPC 2026-09-20: "Variance structure does not match
# data". Diagnosed against the real staged phenotype file -- NOT a
# missingness mismatch between the two traits (every cg_mean_cl class has
# identical non-missing counts for both, since ch4mbw is derived from
# ch4 itself) -- the real cause is several classes having as few as 4
# records (classes 28/29), nowhere near enough to identify a full
# 3-parameter 2x2 US covariance matrix per class. sat() is not a normal
# direct-product variance function (ASReml-4.2-Functional-Specification.pdf
# Section 7.2/7.3.2): it fits a COMPLETELY SEPARATE structure per level,
# which is why the trial had 208 variance parameters, not the ~123 a
# naive per-class-US count would suggest.
#
# Fix: idh(cg_mean_cl).us(Trait).units instead. idh() IS a genuine
# direct-product variance-model function (Table 7.1: "independent with
# separate variances", one scale parameter per level) -- combined with
# .us(Trait) in a direct product (Section 7.2's worked example,
# idv(column).ar1(row)), this gives each class its own residual SCALE
# while SHARING one us(Trait) correlation/covariance structure across
# every class (41 scale parameters + 3 shared covariance parameters = 44
# total, not 208). This is exactly the "more parsimonious heterogeneous-
# scale/common-correlation structure" the original trial's own comment
# named as the fallback if the full per-class US proved unstable.
gen_bivariate_cg_het_scale_trial <- function() {
  t1 <- trait_by_code[["methane"]]
  t2 <- trait_by_code[["ch4mbw"]]
  if (is.null(t1) || is.null(t2)) {
    stop("methane/ch4mbw trait definitions missing from config/models.yaml")
  }
  pe <- choose_pe_term(t1, t2)
  note <- paste(
    "Reviewer-1 CG-heterogeneous-SCALE prototype (2026-09-20 follow-up,",
    "after sat(cg_mean_cl).us(Trait).units failed with 'Variance structure",
    "does not match data' -- several classes have as few as 4 records,",
    "too few for a full per-class covariance matrix):",
    "CH4 x CH4/MBW with idh(cg_mean_cl).us(Trait).units --",
    "per-class residual SCALE, one SHARED trait correlation across all",
    "classes; discovery-only; do not generalise to key_bivariates_cg_het_scale",
    "unless this fit is stable and scientifically useful."
  )
  gen_bivariate(
    t1, t2,
    pe_term = pe$term,
    discovery_only = TRUE,
    filename_suffix = "_cg_het_scale_trial",
    note = note,
    genetic_term = "us(Trait).ped(ANI_ID)",
    genetic_term_reason = cg_het_genetic_term_reason,
    residual_term = "idh(cg_mean_cl).us(Trait).units",
    ignore_legacy_structure = TRUE
  )
}

# ---- CG-heterogeneous-SCALE bivariate matrix, generalized (2026-09-20) --
#
# Generates key_bivariates_cg_het_scale (config/models.yaml): a NARROWER
# list than key_bivariates_cg_het's 18 pairs -- per user instruction,
# drops any pair whose non-"matters" partner trait is one of the 4
# already confirmed NON-estimable under univariate cg_het (ch4adg,
# ch4muscle, ch4rumen, ch4rmtadg) -- pairing them bivariately is very
# unlikely to succeed either, for the same underlying reason (their own
# univariate cg_het models hit the identical AI-matrix-singularity
# pattern). 13 pairs, not 18. Same "do not submit before the trial
# confirms stability" gate as key_bivariates_cg_het.
gen_bivariate_cg_het_scale <- function(code1, code2) {
  t1 <- trait_by_code[[code1]]
  t2 <- trait_by_code[[code2]]
  if (is.null(t1) || is.null(t2)) {
    stop("Unknown trait code in key_bivariates_cg_het_scale pair: ", code1, ",", code2)
  }
  pe <- choose_pe_term(t1, t2)
  note <- paste(
    "Reviewer-1 CG-heterogeneous-SCALE follow-up (2026-09-20, generalized",
    "from the bi_methane_ch4mbw_cg_het_scale_trial prototype):",
    sprintf("%s x %s", t1$code, t2$code),
    "with idh(cg_mean_cl).us(Trait).units (per-class scale, shared",
    "correlation); discovery-only; DO NOT submit before the scale trial",
    "prototype has confirmed this structure is stable -- see",
    "config/models.yaml's key_bivariates_cg_het_scale comment."
  )
  gen_bivariate(
    t1, t2,
    pe_term = pe$term,
    discovery_only = TRUE,
    filename_suffix = "_cg_het_scale",
    note = note,
    genetic_term = "us(Trait).ped(ANI_ID)",
    genetic_term_reason = cg_het_genetic_term_reason,
    residual_term = "idh(cg_mean_cl).us(Trait).units",
    ignore_legacy_structure = TRUE
  )
}

# ---- Stage-heterogeneous bivariate prototype (2026-09-21 follow-up) -----
#
# The two abandoned cg_het bivariate attempts (docs/revision_plan.md
# Section 4C) failed for a reason specific to cg_mean_cl: its 41 classes
# range from 4 to 1763 records, far too unbalanced for a per-class
# bivariate covariance structure regardless of trait pair -- the trial
# pair (methane x ch4mbw) already used the two fullest-record traits
# available, so it wasn't a trait-selection problem. stage_660 (already
# used at the univariate level by --set=stage_het) is structurally very
# different: only 2 classes, both well-populated (~7,600 young /
# ~8,269 mature records), so sat(stage_660).us(Trait).units gives just
# 2 separate 2x2 residual US matrices (6 parameters total) -- nowhere
# near the cg_mean_cl attempts' scale, and much closer to the CONVERGED
# univariate sat(stage_660).idv(units) model's own 2-parameter residual.
#
# Two pairs generated (2026-09-21, both user-directed): methane x co2
# and methane x ch4mbw. methane/co2 is the literal component pair
# behind ch4_ratio's component-derived heritability
# (scripts/04_derive_ratio_from_components.R), and the cg_het per-class
# extraction earlier the same day (docs/revision_plan.md Section 4B
# follow-up) found ch4_ratio was the one trait where CG-mean
# heterogeneity moved h2/t sharply in the OPPOSITE direction from the
# other four traits (permanent-environment variance recovering from a
# near-zero homogeneous-model estimate) -- testing stage-heterogeneity
# on the actual methane/co2 covariance speaks directly to whether that
# component-derived ch4_ratio h2 is similarly sensitive. methane x
# ch4mbw is the original abandoned cg_het bivariate trial pair
# (Section 4C) -- both traits are among cg_het's 5-trait "matters" set
# and both showed a real (not just ch4_ratio's outlier) shift under
# univariate CG-heterogeneity, so it's a natural second stage_660 pair,
# not just a repeat of the failed structure with a different grouping.
gen_bivariate_stage_het_trial <- function(code1, code2) {
  t1 <- trait_by_code[[code1]]
  t2 <- trait_by_code[[code2]]
  if (is.null(t1) || is.null(t2)) {
    stop(code1, "/", code2, " trait definitions missing from config/models.yaml")
  }
  pe <- choose_pe_term(t1, t2)
  note <- sprintf(paste(
    "Reviewer-1/component-derivation stage-heterogeneity prototype",
    "(2026-09-21): %s x %s -- with class-specific residual US matrices",
    "by stage_660 (growing/mature); discovery-only; do not generalise",
    "to other pairs unless the fit is stable and scientifically useful."
  ), t1$code, t2$code)
  gen_bivariate(
    t1, t2,
    pe_term = pe$term,
    discovery_only = TRUE,
    filename_suffix = "_stage_het_trial",
    note = note,
    genetic_term = "us(Trait).ped(ANI_ID)",
    genetic_term_reason = c(
      "# Trait.ped(ANI_ID) -- functional syntax used deliberately for the",
      "# improved auto-initialisation, consistent with every other",
      "# heterogeneous-residual prototype in this pipeline. This is NOT a",
      "# claim that the classic bare form was tried and failed for this",
      "# specific pair (untested)."
    ),
    residual_term = "sat(stage_660).us(Trait).units",
    ignore_legacy_structure = TRUE
  )
}

# ---- Stage-heterogeneous-SCALE bivariate prototype (2026-09-23 follow-up) --
#
# bi_methane_ch4mbw_stage_het_trial (sat(stage_660).us(Trait).units, above)
# hit MAX_ATTEMPTS_EXCEEDED on HPC without converging: Trait 2's
# (methane_per_mbw) diag(Trait).ide(ANI_ID) came out pinned at exactly
# 0.00000 (code F) across the pipeline's own automatic !CONTINUE retries
# (docs/revision_plan.md Section 4E, 23 Sep correction -- this is NOT the
# stale-.rsv trap, .rsv reuse across retries is by design). Under the
# homogeneous-residual bivariate model that same PE component is small
# (0.00158, ~6% of Trait 2's total variance) but genuinely estimated, not
# zero, so it's a real but marginal signal, not numerically absent.
#
# stage_660's two classes are well-populated (~7,600/~8,269 records),
# unlike cg_mean_cl's 4-1763-record spread, so this isn't the original
# cg_het small-class problem sat() couldn't handle. The likely issue is
# parameter richness instead: sat(stage_660).us(Trait).units estimates a
# SEPARATE trait residual correlation per stage (2 fully-independent 2x2
# US matrices), and methane/ch4mbw's occasion-level residual correlation
# is expected to be very high regardless of stage (ch4mbw is literally
# ch4/MBW computed from the same record) -- re-estimating that
# near-degenerate correlation twice, independently, is one more thing
# competing with Trait 2's already-marginal PE for identification.
#
# Same idh() substitution already used for the cg_mean_cl case (above):
# idh(stage_660).us(Trait).units gives each stage its own residual SCALE
# but shares ONE us(Trait) trait-correlation/covariance structure across
# both stages (5 residual parameters: 2 scale + 3 shared, vs sat()'s 6
# fully-independent ones). This keeps heterogeneous residual variance by
# stage -- the part Reviewer 1 actually asked about -- while removing the
# one redundant, near-degenerate parameter.
#
# Two pairs (2026-09-23, user-directed): methane x ch4mbw (retry of the
# failed trial under this more parsimonious structure) and methane x mbw
# (the raw metabolic-bodyweight component trait feeding the ch4mbw
# ratio -- not derived from the same record as methane, and its own
# univariate ide(ANI_ID) CONVERGED with a real, non-collapsed PE estimate
# of 1.91896, results/univariate_summary.csv -- a cleaner diagnostic for
# whether the residual-heterogeneity idea itself is estimable here, run
# in parallel with the ch4mbw retry rather than instead of it).
gen_bivariate_stage_het_scale_trial <- function(code1, code2) {
  t1 <- trait_by_code[[code1]]
  t2 <- trait_by_code[[code2]]
  if (is.null(t1) || is.null(t2)) {
    stop(code1, "/", code2, " trait definitions missing from config/models.yaml")
  }
  pe <- choose_pe_term(t1, t2)
  note <- sprintf(paste(
    "Stage-heterogeneous-SCALE bivariate prototype (2026-09-23, after",
    "sat(stage_660).us(Trait).units hit MAX_ATTEMPTS_EXCEEDED for methane",
    "x ch4mbw with Trait 2's PE pinned at a zero boundary): %s x %s --",
    "idh(stage_660).us(Trait).units, per-stage residual SCALE with one",
    "SHARED trait correlation across stages; discovery-only; do not",
    "generalise beyond this trial pair unless the fit is stable and",
    "scientifically useful."
  ), t1$code, t2$code)
  gen_bivariate(
    t1, t2,
    pe_term = pe$term,
    discovery_only = TRUE,
    filename_suffix = "_stage_het_scale_trial",
    note = note,
    genetic_term = "us(Trait).ped(ANI_ID)",
    genetic_term_reason = c(
      "# Trait.ped(ANI_ID) -- functional syntax used deliberately for the",
      "# improved auto-initialisation, consistent with every other",
      "# heterogeneous-residual prototype in this pipeline. This is NOT a",
      "# claim that the classic bare form was tried and failed for this",
      "# specific pair (untested)."
    ),
    residual_term = "idh(stage_660).us(Trait).units",
    ignore_legacy_structure = TRUE
  )
}

# ---- Stage-SPLIT bivariate check (2026-09-23) ----
#
# Both attempts at modelling stage_660 residual heterogeneity WITHIN one
# bivariate fit are abandoned for structural ASReml reasons (see the two
# prototypes above): sat(stage_660).us(Trait).units silently collapses to
# one residual section instead of two in a Trait-sectioned (bivariate)
# model ("Warning: Fewer sections of data than expected", confirmed by
# grepping the .asr for every printed Sigma value -- sat(stage_660,2)
# never receives one); idh(stage_660).us(Trait).units is structurally
# invalid regardless of data (two variance-type functions, idh() and
# us(), in one compound term -- Functional-Specification.pdf Section 7.2
# explicitly requires exactly one).
#
# This sidesteps the whole problem by splitting the DATA instead of the
# residual structure: fit two ORDINARY (homogeneous-residual, no
# residual_term override -- the same structure as the already-CONVERGED
# bi_methane_ch4mbw.as) bivariate models, one on young-stage records
# only, one on mature-stage records only
# (scripts/06_prepare_stage_split_phenotype.R). Comparing rg_young vs
# rg_mature directly answers the reviewer-facing question this whole
# line of work is for -- does the CROSS-TRAIT genetic correlation itself
# differ by stage -- which the univariate stage_het VA-stability check
# (each trait's OWN genetic variance, not the cross-trait covariance)
# and the young_old check (CH4 vs itself across stages, not CH4 vs
# ch4mbw) don't quite cover on their own.
#
# Same genetic/PE term choice as the already-confirmed homogeneous
# bi_methane_ch4mbw.as (classic Trait.ped(ANI_ID), independent PE via
# choose_pe_term()) so 03_parse_results.R's by-NAME Model_Term parsing
# (not a hand-indexed VPREDICT block) applies exactly as it already does
# for that pair -- no new structure to discover here, just a smaller,
# stage-restricted sample.
gen_bivariate_stage_split <- function(code1, code2, stage) {
  stopifnot(stage %in% c("young", "mature"))
  t1 <- trait_by_code[[code1]]
  t2 <- trait_by_code[[code2]]
  if (is.null(t1) || is.null(t2)) {
    stop(code1, "/", code2, " trait definitions missing from config/models.yaml")
  }
  pe <- choose_pe_term(t1, t2)
  note <- sprintf(paste(
    "Stage-split bivariate check (2026-09-23): %s x %s fit on %s-stage",
    "records only (stage_660), ordinary homogeneous residual -- see",
    "scripts/06_prepare_stage_split_phenotype.R and this file's",
    "gen_bivariate_stage_split() header comment for why (bivariate",
    "stage-heterogeneous RESIDUAL structures are abandoned for structural",
    "ASReml reasons; this tests the same question by splitting the data",
    "instead). Compare rg from this fit against the other stage and",
    "against the full-data bi_methane_ch4mbw.as rg=0.8478 (SE 0.0152)."
  ), t1$code, t2$code, stage)
  gen_bivariate(
    t1, t2,
    pe_term = pe$term,
    discovery_only = pe$independent,
    filename_suffix = sprintf("_%s", stage),
    note = note,
    phenotype_file = sprintf("phenotype_asreml_%s.csv", stage)
  )
}

# ---- young(<660d)-vs-mature CH4 bivariate genetic correlation ----
#
# Treats ch4_young/ch4_old (scripts/00_prepare_asreml_phenotype.R --
# CH4 itself, missing outside that record's own age-based stage) as two
# correlated pseudo-traits, the classic across-environment bivariate
# genetic-correlation design. Answers the scope decision explicitly left
# open in analysis/diagnostics/reviewer_a2_a3/README.md's A3 section.
gen_bivariate_young_old <- function() {
  yop <- cfg$young_old_pair
  if (is.null(yop)) stop("config/models.yaml has no young_old_pair block.")
  t1 <- list(code = "young", variable = yop$variable1, label = yop$label1)
  t2 <- list(code = "old",   variable = yop$variable2, label = yop$label2)
  # Unlike every pair in --set=full/components, neither pseudo-trait has
  # ever been fit on its own (both are new columns derived from
  # ch4_g_day2_1v3, not existing traits with their own univariate ide(ANI_ID)
  # estimate) -- so there is no !INIT value to seed independent PE with.
  # diag(Trait).ide(ANI_ID) with NO !INIT still gets ASReml's improved
  # phenotypic-variance-based auto-initialisation (Functional-
  # Specification.pdf Section 7.7.5 -- applies to any functional-syntax
  # term, not just !INIT'd ones), the same fix already used for
  # methane_co2/methane_adg/methane_rumen/mbw_co2 above. Fitting the two
  # stages with a shared ide(ANI_ID) would force identical PE magnitude in
  # both age stages, which the CH4 stage-heterogeneity pilot already found
  # implausible (residual variance alone differs ~2.4x by stage) -- so this
  # does NOT fall back to shared PE the way choose_pe_term() would for a
  # pair with no univariate estimate; the fallback there is about missing
  # DATA to seed !INIT with, not about whether independent PE is
  # appropriate here.
  # Residual structure forced independent (idh(Trait).units, heterogeneous
  # variances but NO covariance), not left to ASReml's US default -- the
  # functional-genetic-term fix alone still aborted after 1 iteration
  # (2026-09-18) with the RESIDUAL covariance specifically flagged
  # Sigma/SE=0 and Code S ("Singular Information matrix... no information
  # in the data for this parameter"). This is structural, not a scaling
  # problem: no single measurement occasion ever has both a young-stage
  # and old-stage value (mutually exclusive by construction, see
  # 00_prepare_asreml_phenotype.R), so a residual covariance between them
  # is genuinely inestimable -- the standard fix for this "same trait,
  # two environments" design is to constrain it to zero rather than let
  # ASReml try (and fail) to estimate it. The genetic covariance remains
  # freely estimated (us(Trait).ped(ANI_ID)) since cross-occasion animal
  # relationships DO carry information linking the two stages.
  gen_bivariate(t1, t2, pe_term = "diag(Trait).ide(ANI_ID)",
                discovery_only = TRUE, filename_suffix = "",
                genetic_term = "us(Trait).ped(ANI_ID)",
                residual_term = "idh(Trait).units")
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
} else if (set_arg == "mol_ratio") {
  # CH4 ratio on a molar basis (2026-09-21) -- see config/models.yaml's
  # mol_ratio_set comment and scripts/00_prepare_asreml_phenotype.R for
  # the trait's derivation.
  uni_codes <- cfg$mol_ratio_set$univariate
  bi_pairs <- cfg$mol_ratio_set$bivariate
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

if (set_arg == "stage_het") {
  traits <- cfg$stage_het_traits
  if (is.null(traits) || length(traits) == 0) {
    stop("config/models.yaml has no stage_het_traits list.")
  }
  cat(sprintf("Generating 'stage_het' set: %d univariate models\n", length(traits)))
  for (code in traits) {
    trait <- trait_by_code[[code]]
    if (is.null(trait)) stop("Unknown trait code in stage_het_traits: ", code)
    gen_univariate_stage_het(trait)
    cat("  wrote a_uni_", code, "_stage_het.as (discovery-only)\n", sep = "")
  }
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "cg_het") {
  traits <- cfg$cg_het_traits
  if (is.null(traits) || length(traits) == 0) {
    stop("config/models.yaml has no cg_het_traits list.")
  }
  cat(sprintf("Generating 'cg_het' set: %d univariate models\n", length(traits)))
  for (code in traits) {
    trait <- trait_by_code[[code]]
    if (is.null(trait)) stop("Unknown trait code in cg_het_traits: ", code)
    gen_univariate_cg_het(trait)
    cat("  wrote a_uni_", code, "_cg_het.as (discovery-only)\n", sep = "")
  }
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "bi_cg_het_trial") {
  cat("Generating 'bi_cg_het_trial' set: 1 bivariate discovery model\n")
  gen_bivariate_cg_het_trial()
  cat("  wrote bi_methane_ch4mbw_cg_het_trial.as (discovery-only)\n")
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "bi_stage_het_trial") {
  cat("Generating 'bi_stage_het_trial' set: 3 bivariate discovery models\n")
  gen_bivariate_stage_het_trial("methane", "co2")
  cat("  wrote bi_methane_co2_stage_het_trial.as (discovery-only)\n")
  gen_bivariate_stage_het_trial("methane", "ch4mbw")
  cat("  wrote bi_methane_ch4mbw_stage_het_trial.as (discovery-only)\n")
  # 2026-09-23: methane x mbw added as a cleaner diagnostic than
  # methane x ch4mbw for whether the stage-heterogeneous residual
  # structure itself is estimable. ch4mbw (methane_per_mbw) is a
  # ratio-derived trait whose PE variance got driven to a hard zero
  # boundary in that trial (docs/revision_plan.md Section 4E, 23 Sep
  # correction). mbw is the raw component trait feeding that ratio and
  # has a real, non-collapsed CONVERGED univariate ide(ANI_ID) estimate
  # (1.91896, results/univariate_summary.csv) -- if this pair also
  # fails to converge under the same stage_660 residual structure, that
  # points at the residual-heterogeneity parameterisation itself being
  # too rich for the data rather than something specific to ch4mbw's PE
  # fragility.
  gen_bivariate_stage_het_trial("methane", "mbw")
  cat("  wrote bi_methane_mbw_stage_het_trial.as (discovery-only)\n")
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "bi_stage_het_scale_trial") {
  cat("Generating 'bi_stage_het_scale_trial' set: 2 bivariate discovery models\n")
  gen_bivariate_stage_het_scale_trial("methane", "ch4mbw")
  cat("  wrote bi_methane_ch4mbw_stage_het_scale_trial.as (discovery-only)\n")
  gen_bivariate_stage_het_scale_trial("methane", "mbw")
  cat("  wrote bi_methane_mbw_stage_het_scale_trial.as (discovery-only)\n")
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "bi_stage_split") {
  cat("Generating 'bi_stage_split' set: 2 bivariate models (young/mature)\n")
  cat("NOTE: requires data/phenotype_asreml_young.csv and _mature.csv --\n")
  cat("      run scripts/06_prepare_stage_split_phenotype.R first if missing.\n")
  gen_bivariate_stage_split("methane", "ch4mbw", "young")
  cat("  wrote bi_methane_ch4mbw_young.as\n")
  gen_bivariate_stage_split("methane", "ch4mbw", "mature")
  cat("  wrote bi_methane_ch4mbw_mature.as\n")
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "key_bivariates") {
  pairs <- c(cfg$key_bivariates_alt_vs_ch4, cfg$component_set$bivariate,
             cfg$key_bivariates_ratio_vs_denominator)
  if (length(pairs) == 0) {
    stop("config/models.yaml has no key_bivariates_alt_vs_ch4/ratio_vs_denominator lists.")
  }
  cat(sprintf("Generating 'key_bivariates' set: %d bivariate models (independent PE)\n",
              length(pairs)))
  for (pair in pairs) {
    t1 <- trait_by_code[[pair[[1]]]]
    t2 <- trait_by_code[[pair[[2]]]]
    if (is.null(t1) || is.null(t2)) stop("Unknown trait code in pair: ", paste(pair, collapse = ","))
    pe <- choose_pe_term(t1, t2)
    gen_bivariate(t1, t2, pe_term = pe$term, discovery_only = pe$independent,
                  filename_suffix = "", note = pe$note)
    cat("  wrote bi_", t1$code, "_", t2$code, ".as",
        if (pe$independent) " (independent PE, discovery-only)" else " (shared PE, fallback -- see NOTE in file)",
        "\n", sep = "")
  }
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "key_bivariates_final") {
  # Writes ONLY .pin files (not .as) -- all 23 key_bivariates pairs
  # already CONVERGED under discovery-only VPREDICT (2026-09-20), so
  # only .pin post-processing against each pair's existing .rsv is
  # needed, not a fresh fit. Run `asreml -P<jobname> <jobname>.pin`
  # directly per job on HPC (NOT slurm/submit_batch.sh -- its skip
  # logic sees the already-CONVERGED .asr and won't reprocess), then
  # rerun 03_parse_results.R.
  pairs <- c(cfg$key_bivariates_alt_vs_ch4, cfg$component_set$bivariate,
             cfg$key_bivariates_ratio_vs_denominator)
  if (length(pairs) == 0) {
    stop("config/models.yaml has no key_bivariates_alt_vs_ch4/ratio_vs_denominator lists.")
  }
  cat(sprintf("Generating 'key_bivariates_final' set: %d .pin files\n", length(pairs)))
  for (pair in pairs) {
    code_pair <- sprintf("%s_%s", pair[[1]], pair[[2]])
    gen_key_bivariates_final(code_pair)
  }
  cat("\nDone.\n")
  quit(save = "no", status = 0)
}

if (set_arg == "bi_cg_het_scale_trial") {
  cat("Generating 'bi_cg_het_scale_trial' set: 1 bivariate discovery model\n")
  gen_bivariate_cg_het_scale_trial()
  cat("  wrote bi_methane_ch4mbw_cg_het_scale_trial.as (discovery-only)\n")
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "key_bivariates_cg_het_scale") {
  pairs <- cfg$key_bivariates_cg_het_scale
  if (is.null(pairs) || length(pairs) == 0) {
    stop("config/models.yaml has no key_bivariates_cg_het_scale list.")
  }
  cat(sprintf("Generating 'key_bivariates_cg_het_scale' set: %d bivariate models\n", length(pairs)))
  cat("NOTE: generation only -- do not submit to HPC before bi_methane_ch4mbw_cg_het_scale_trial\n")
  cat("      (--set=bi_cg_het_scale_trial) has CONVERGED and been checked for a stable fit.\n")
  for (pair in pairs) {
    gen_bivariate_cg_het_scale(pair[[1]], pair[[2]])
    cat("  wrote bi_", pair[[1]], "_", pair[[2]], "_cg_het_scale.as (discovery-only)\n", sep = "")
  }
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "key_bivariates_cg_het") {
  pairs <- cfg$key_bivariates_cg_het
  if (is.null(pairs) || length(pairs) == 0) {
    stop("config/models.yaml has no key_bivariates_cg_het list.")
  }
  cat(sprintf("Generating 'key_bivariates_cg_het' set: %d bivariate models\n", length(pairs)))
  cat("NOTE: generation only -- do not submit to HPC before bi_methane_ch4mbw_cg_het_trial\n")
  cat("      (--set=bi_cg_het_trial) has CONVERGED and been checked for a stable fit.\n")
  for (pair in pairs) {
    gen_bivariate_cg_het(pair[[1]], pair[[2]])
    cat("  wrote bi_", pair[[1]], "_", pair[[2]], "_cg_het.as (discovery-only)\n", sep = "")
  }
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "young_old") {
  cat("Generating 'young_old' set: 1 bivariate model\n")
  gen_bivariate_young_old()
  cat("  wrote bi_young_old.as (discovery-only)\n")
  cat("\nDone. Models written to:", models_dir, "\n")
  quit(save = "no", status = 0)
}

if (set_arg == "young_old_final") {
  # Writes ONLY the .pin (not .as) -- bi_young_old.as already CONVERGED
  # (2026-09-18), so only .pin post-processing is needed, not a fresh fit.
  gen_young_old_final()
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
  } else if (set_arg %in% c("full", "components", "components_trial", "mol_ratio")) {
    # 2026-09-18: independent (trait-specific) PE where possible, per
    # choose_pe_term()'s header comment -- generalizes the 2026-09-17
    # PE-sensitivity pilot (methane_weight/methane_co2 only) to every pair
    # in these sets, closing the "open question" left in
    # docs/revision_plan.md's 2026-09-17 decision log for the other pairs.
    # mol_ratio's ch4ratio_ch4ratiomol pair falls back to shared PE for
    # now (ch4ratiomol has no CONVERGED univariate estimate yet), same
    # discipline as any other pair without one.
    pe <- choose_pe_term(t1, t2)
    gen_bivariate(t1, t2, pe_term = pe$term, discovery_only = pe$independent,
                  filename_suffix = "", note = pe$note)
    cat("  wrote bi_", t1$code, "_", t2$code, ".as",
        if (pe$independent) " (independent PE, discovery-only)" else " (shared PE, fallback -- see NOTE in file)",
        "\n", sep = "")
  } else {
    gen_bivariate(t1, t2)
    cat("  wrote bi_", t1$code, "_", t2$code, ".as\n", sep = "")
  }
}

cat("\nDone. Models written to:", models_dir, "\n")
cat("These reference the phenotype/pedigree files by bare filename only --\n")
cat("run scripts/02_stage_run_dir.sh on whichever platform will execute them\n")
cat("to populate run/ before submitting.\n")

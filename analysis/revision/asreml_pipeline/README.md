# ASReml automated pipeline (revision)

Replaces the legacy manually-edited `.as` file collection
(`analysis/legacy/asreml_scripts/`) with a config-driven, reproducible
system for generating, running, and parsing the submitted-style
univariate/bivariate ASReml sweep. This does **not** implement the
"component-trait redesign" discussed for later revision -- it reproduces
the existing model structure and trait definitions (including the
existing residual-methane construction) so they can be regenerated and
rerun reliably, with two deliberate, explicitly-instructed departures from
the legacy-faithful spec: independent (trait-specific) permanent-
environment variances in bivariate models where possible, and two new
model families (stage-heterogeneous residual variance, and a young-vs-
mature bivariate genetic correlation) -- see the 2026-09-18 update below.
See `docs/asreml_legacy_map.md` for the reconstruction this pipeline is
built from, and `docs/revision_plan.md` for where it sits in the overall
revision.

## Status (2026-09-15)

Validation set generated and checked against the real legacy results by
replaying legacy `.asr`/`.pvc` files through `03_parse_results.R`'s
parser (ASReml itself is not installed on the VM -- see "Where things
run" below) -- **not yet run on HPC**. Results matched the manuscript
and the independent within-parser cross-check exactly:

| | manuscript | reproduced |
|---|---|---|
| CH4 h2 | 0.17 | 0.1697 |
| CH4 t | 0.31 | 0.3063 |
| CH4 ratio h2 | 0.08 | 0.0806 |
| CH4 ratio t | 0.09 | 0.0940 |
| CH4-CH4ratio rg | 0.73 (0.05) | 0.7297 (0.0454) |
| CH4-CH4ratio rp | 0.46 | 0.4606 |

**Update, same day: first real HPC trial run.** Submitting all 3
validation-set jobs at once (sharing a single `run/` directory, the
original design) produced two Fortran runtime crashes
(`forrtl: severe (28): CLOSE error, unit 7`) within seconds, and one
clean success -- the job that happened to run without any concurrent
sibling converged normally (`a_uni_ch4ratio`, 3 attempts, `LogL
Converged`). This confirms ASReml is not safe to run multiple
concurrent jobs from a shared working directory (it writes some files
under fixed, non-job-prefixed names -- `ainverse.bin`/`asrdata.bin` are
documented examples in the manual -- so concurrent jobs race on them),
consistent with every legacy Slurm script only ever running ASReml jobs
sequentially. **Fixed**: `02_stage_run_dir.R` now gives every job its
own isolated directory (`run/<jobname>/`), so jobs are safe to run
fully in parallel again. See that script's header comment for the full
explanation.

The one model that did run for real (`a_uni_ch4ratio`, on the new
36,449-animal pedigree, not the manuscript's 330,812) gave h2 ~ 0.10 vs.
the manuscript's 0.08 -- a reasonable difference given the much smaller
pedigree, not a red flag. Next step is rerunning the validation set with
the per-job-directory fix in place; once all 3 converge cleanly and
`03_parse_results.R`'s cross-check columns agree, `--set=full` can be
generated and run.

**Update, later same day: `--set=full` ran successfully on HPC.**

**Update, later still: component-trait ratio derivation added
(docs/revision_plan.md Section 5 step 7).** `--set=components` generates
six new bivariate CH4 x <raw denominator> models (`co2`, `mbw`, `adg`,
`muscle`, `rumen`, `weight` -- the actual measured variables behind each
ratio trait, not the pre-computed ratio columns), reusing legacy starting
values automatically for the three pairs with a real legacy counterpart
(`bi_ch4_mbw.as`, `bi_ch4_muscle.as`, `bi_ch4_weight.as`); `co2`/`adg`/
`rumen` have no legacy bivariate pair with CH4 and fall back to ASReml
auto-initialisation. `04_derive_ratio_from_components.R` then derives
each ratio trait's h2 and its rg with CH4 from these bivariate (co)variances
via first-order Taylor linearisation of the ratio -- the same delta-method
gradient already used for real in the upstream selection-index repo
(commit `fb1f0a2`), not a new derivation, extended from "selection
response" to "heritability/genetic correlation." Verified against two
analytic edge cases (denominator with zero genetic variance reduces
exactly to the CH4-alone h2 and rg=1; the CH4+CO2 sum case for `ch4_ratio`
correctly reduces to the nonlinear Mobius-function derivative) -- **not
yet run on HPC**.

**Update, later still: scope correction (via the user, 2026-09-15).** An
initial redesign attempted a complete 7x7 G/P covariance matrix (all
`choose(7,2)=21` pairs) so every pairwise correlation among the nine
derived traits (Table 3) could also be derived. The user narrowed this:
**this stage is heritabilities only**, not a selection index or a
complete covariance structure -- so only the bivariate pairs a given
composite trait actually needs are fit, nothing more:

| Composite trait | Components needed |
|---|---|
| MI (CH4/MBW), RMTMBW | CH4, MBW |
| CH4 ratio | CH4, CO2 |
| CH4/ADG, RMTADG | CH4, ADG |
| CH4/MM | CH4, muscle |
| CH4/rumen | CH4, rumen |
| CH4/LW | CH4, liveweight |
| RMTMBW+CO2 | CH4, MBW, CO2 (needs CH4-MBW, CH4-CO2, **and** MBW-CO2) |

That's **7 univariate + 7 bivariate models** (the 6 "CH4 vs X" pairs plus
`mbw-co2`, the one pair not involving CH4, needed solely for RMTMBW+CO2's
3-component block) -- down from the 21-pair design. Of these 7 bivariate
pairs, 2 have real legacy ASReml starting values (`methane-mbw`,
`methane-muscle`); the other 5 (`methane-co2`, `methane-adg`,
`methane-rumen`, `methane-weight` has one too, `mbw-co2`) mostly rely on
auto-initialisation.

- `--set=components_trial`: 7 univariate + 3 representative pairs
  (`methane-mbw`: legacy-backed; `mbw-co2`: the one genuinely new pair
  this design needed, no legacy counterpart; `methane-rumen`: no legacy,
  and rumen has only 780 records at 3.2% repeat rate -- tests whether the
  shared PE term is identifiable for a near-single-record trait). Run
  this first.
- `--set=components`: the full 7 univariate + 7 bivariate set above.
- `04_derive_ratio_from_components.R` rewritten to the narrower scope:
  for each composite trait, builds only the small (2x2, or 3x3 for
  RMTMBW+CO2) G/P block it needs from the relevant univariate (diagonal)
  and bivariate (off-diagonal) results, applies the exact linear-
  combination formula (residual traits) or first-order Taylor gradient
  (ratio traits, `CH4/(CH4+CO2)` via the direct two-variable gradient wrt
  CH4 and CO2), and reports h2 **alongside every component parameter used
  to calculate it** (VA/VP of CH4 and each component, their covariances)
  for full traceability. No cross-derived-trait correlation matrix and no
  multivariate model in this pass -- explicitly deferred to a later, separate
  task, per the user. Residual coefficients (b) recalculated from this
  pipeline's own cleaned dataset AND independently cross-checked against
  the original manuscript-scale dataset
  (`~/PAC_data_pipeline/data/external/paper3/P3_co2_data.csv`, 15,869
  records) -- agree to 4 decimal places, no discrepancy to resolve.
  Smoke-tested end-to-end against fabricated (co)variance data (sensible
  h2s, correct component-parameter traceability) -- **not yet run against
  real HPC output**.
- SE/uncertainty propagation is explicitly deferred until these point
  estimates are confirmed, per the user's instruction.

**Update, 2026-09-18 (per user instruction): three new/changed model sets,
closing scope questions left open above.**

1. **Independent (trait-specific) PE for every bivariate model, where
   possible.** The 2026-09-17 PE-sensitivity finding below (shared
   `ide(ANI_ID)` inflating genetic variance for `methane_weight`/
   `methane_co2` specifically) was deliberately scoped to just those 2
   pairs, leaving "this remains an open question" for the rest
   (`docs/revision_plan.md`'s 2026-09-17 decision log). That question is
   now closed: `--set=full`, `--set=components` and `--set=components_trial`
   all default to `diag(Trait !INIT <ide1> <ide2>).ide(ANI_ID)` per pair,
   seeded from each trait's own CONVERGED univariate `ide(ANI_ID)`
   estimate in `results/univariate_summary.csv`. "Where possible" -- a
   pair falls back to the original shared `ide(ANI_ID)` term, with a
   `# NOTE:` comment in the generated `.as` file explaining why, only
   when one of its two traits has no CONVERGED univariate estimate on
   file to seed a starting value with (in practice this never triggers
   for the current 10 Table-2 + 7 component traits, all CONVERGED, but
   the mechanism exists for any future trait added before its univariate
   model has run). Every pair using the new structure is generated
   **discovery-only** (blank `VPREDICT !DEFINE`) -- changing the PE
   structure changes ASReml's parameter print order, and that order is
   only actually confirmed from real `.pvc` output for the 2 pilot pairs'
   specific structure, not assumed to generalize without checking, per
   this pipeline's own stated discipline (see the file-header VPREDICT
   comment in `01_generate_models.R`). **Consequence: `results/
   bivariate_summary.csv`'s existing 52-row `--set=full` sweep (29
   CONVERGED) was fit under the OLD shared-PE model spec and no longer
   matches the regenerated `models/bi_*.as` files** -- it is a valid
   historical record of that prior spec, not stale/wrong, but it must
   not be read as validating the new independent-PE models until they
   are actually rerun on HPC and reparsed. The `_petrait`-suffixed pilot
   files (`bi_methane_weight_petrait.as`, `bi_methane_co2_petrait.as`)
   and their already-confirmed `pe_sensitivity_final` indices are
   untouched and remain the one place real confirmed diag(Trait) index
   numbering exists so far.
2. **`--set=stage_het`** (Reviewer 1's contemporary-group/scale-
   heterogeneity concern): generalizes the single-trait pilot in
   `analysis/diagnostics/reviewer_a2_a3/a_ch4_stage_het_residual.as`
   (CONVERGED on HPC 2026-09-17, found a real ~2.4x residual-variance
   difference between stages for CH4) from CH4 alone to all 9 Table 2
   traits, refitting each with `residual sat(stage_660).idv(units)`
   instead of one pooled residual variance. Uses a *different* stage
   cutoff than that pilot: the manuscript's own official growing/mature
   split (`age_at_treatment < 660` days, the same cutoff already used for
   ADG/CH4-ADG/CH4-MM/CH4-rumen/RMTADG -- `docs/manuscript_context.md`
   Section 5) rather than the pilot's ad hoc `age_in_years < 2`
   (~730 days). Discovery-only, same reasoning as above.
3. **`--set=young_old`**: a young(<660 days)-vs-mature bivariate genetic
   correlation for CH4 itself (`ch4_young`/`ch4_old`, two age-class
   pseudo-traits derived in `scripts/00_prepare_asreml_phenotype.R`),
   answering the scope decision explicitly left open in
   `analysis/diagnostics/reviewer_a2_a3/README.md`'s A3 section ("a
   young-vs-mature bivariate genetic analysis"). Uses independent PE too
   (no shared-PE fallback attempted here -- forcing identical PE
   magnitude across two stages already shown to differ ~2.4x in residual
   variance alone would be a strange choice for this specific model), via
   functional `diag(Trait).ide(ANI_ID)` with no `!INIT` (no prior
   univariate fit of either pseudo-trait exists to seed one from --
   ASReml's improved auto-initialisation for functional-syntax terms
   applies regardless, Functional-Specification.pdf Section 7.7.5).
   Discovery-only.

None of these three have been run on HPC yet -- they are VM-side
generation + structural review only. See "Workflow" below for the
`--set=stage_het` / `--set=young_old` commands (same VM-generate ->
HPC-run pattern as every other set).

## Directory layout

```
config/      paths.yaml (VM/HPC path sets), models.yaml (traits, fixed
             effects, field-definition list, validation/full-sweep sets)
templates/   (not currently used -- generation is done directly in R;
             kept as a placeholder if string templates prove clearer
             later)
scripts/     00_prepare_asreml_phenotype.R  -- derive the curated,
                 ASReml-ready phenotype file (residual traits, age
                 bins, etc.) from this repo's canonical PAC pipeline
                 output. Platform-aware (--platform=vm|hpc).
             01_generate_models.R  -- config -> .as/.pin files in models/.
                 --set=validation | --set=full | --set=components_trial |
                 --set=components
             02_stage_run_dir.R  -- populate run/ with phenotype +
                 pedigree + generated models under the bare filenames
                 the .as files reference. --platform=vm|hpc
             03_parse_results.R  -- run/*.asr(+.pvc) -> results/*.csv,
                 with independent cross-checks (see below).
             04_derive_ratio_from_components.R  -- for each composite
                 methane trait, builds just the small G/P block it needs
                 from results/univariate_summary.csv + bivariate_summary.csv
                 and derives its h2 (linear-combination formula for
                 residual traits, Taylor/delta-method for ratio traits),
                 reporting every component parameter used alongside the
                 result -- instead of fitting each constructed phenotype
                 directly. Heritabilities only in this pass; cross-derived-
                 trait correlations and any multivariate work are deferred.
                 docs/revision_plan.md Section 5 step 7; see the script's
                 own header for the method (Julius van der Werf's
                 framework, via the user) and its upstream provenance.
             lib_classify_convergence.R  -- shared convergence-status
                 classifier (used by both the Slurm retry loop and the
                 result parser), using ASReml's own documented message
                 strings, not inferred wording.
models/      generated .as/.pin files -- git-tracked, small, deterministic,
             fully regenerable from config/ + scripts/01.
slurm/       submit_batch.sh, asreml_job.slurm, run_one_model.sh --
             HPC-side submission + per-model convergence retry loop.
results/     parsed summary tables -- git-tracked.
run/         gitignored execution directory: phenotype/pedigree copies
             and ALL raw ASReml output for every model. This is the
             literal, complete "retain all raw outputs" record, just
             not committed to git (per-run binaries like .veo/.yht can
             be large and are, by definition, regenerable from the .as
             files in models/).
```

## Workflow (as specified)

```
VM: generate + inspect models  -->  git commit/push
                                          |
                                          v
HPC: git pull  -->  stage run/  -->  trial batch (validation set)
                                          |
                              (compare against legacy/manuscript --
                               see docs/asreml_legacy_map.md)
                                          |
                                          v
                          generate + run full sweep
                                          |
                                          v
VM: git pull results/  -->  03_parse_results.R already ran on HPC,
                             but can be rerun on the VM against a
                             synced-down run/ for review/re-parsing
```

Concretely:

```bash
# On the VM
Rscript scripts/00_prepare_asreml_phenotype.R --platform=vm
Rscript scripts/01_generate_models.R --set=validation
# inspect models/*.as, git commit, git push

# On HPC (after git pull)
Rscript scripts/00_prepare_asreml_phenotype.R --platform=hpc   # or stage phenotype/pedigree via the GCS bucket handoff used elsewhere on this VM, matching config/paths.yaml's hpc.raw_phenotype_file/pedigree_file
Rscript scripts/02_stage_run_dir.R --platform=hpc
slurm/submit_batch.sh                     # trial batch = whatever's in models/ (validation set)
# ... wait for jobs to finish ...
Rscript scripts/03_parse_results.R
git add results/ && git commit && git push

# Once validated: full sweep
Rscript scripts/01_generate_models.R --set=full
Rscript scripts/02_stage_run_dir.R --platform=hpc
slurm/submit_batch.sh                     # submits ONE array job, throttled -- see "License concurrency" below
Rscript scripts/03_parse_results.R

# Component-trait analysis (docs/revision_plan.md Section 5 step 7) --
# small trial first
Rscript scripts/01_generate_models.R --set=components_trial
Rscript scripts/02_stage_run_dir.R --platform=hpc
slurm/submit_batch.sh
Rscript scripts/03_parse_results.R   # inspect convergence + results/*_summary.csv

# Once the trial's 3 bivariate pairs converge cleanly: full 7-pair set
Rscript scripts/01_generate_models.R --set=components
Rscript scripts/02_stage_run_dir.R --platform=hpc
slurm/submit_batch.sh
Rscript scripts/03_parse_results.R
Rscript scripts/04_derive_ratio_from_components.R
# -> results/derived_h2.csv (h2 per composite trait, plus every component
#    parameter used to calculate it)

# Reviewer 1 CG-heteroscedasticity: heterogeneous residual variance by the
# manuscript's own growing(<660d)/mature split, one univariate model per
# Table 2 trait
Rscript scripts/01_generate_models.R --set=stage_het
Rscript scripts/02_stage_run_dir.R --platform=hpc
slurm/submit_batch.sh
Rscript scripts/03_parse_results.R   # discovery-only -- read real .pvc
                                      # parameter numbering off each .asr
                                      # before writing any h2/repeatability-
                                      # by-stage VPREDICT block

# Young(<660d)-vs-mature CH4 bivariate genetic correlation
Rscript scripts/01_generate_models.R --set=young_old
Rscript scripts/02_stage_run_dir.R --platform=hpc
slurm/submit_batch.sh
Rscript scripts/03_parse_results.R   # discovery-only, same as above


# Bounded Reviewer-1 bivariate heterogeneity follow-up:
# ONE CH4 x CH4/MBW discovery prototype, not a full sweep.
Rscript scripts/01_generate_models.R --set=bi_cg_het_trial
Rscript scripts/02_stage_run_dir.R --platform=hpc
ASREML_MAIL_USER= slurm/submit_batch.sh bi_methane_ch4mbw_cg_het_trial
# Compare the resulting rg/genetic variances with bi_methane_ch4mbw.
# The prototype fits sat(cg_mean_cl).us(Trait).units (~30 class-specific
# 2x2 residual US matrices). If it is unstable, move to a more
# parsimonious heterogeneity model rather than forcing convergence.

# 2026-09-20 user scope decision (docs/revision_plan.md Section 4B):
# curated 23-pair bivariate matrix, replaces --set=full as the target.
Rscript scripts/01_generate_models.R --set=key_bivariates
Rscript scripts/02_stage_run_dir.R --platform=hpc
slurm/submit_batch.sh
Rscript scripts/03_parse_results.R

# CG-heterogeneous variant of the 18 key_bivariates pairs involving a
# trait where cg_het mattered. GENERATION ONLY -- do not submit any of
# these until bi_methane_ch4mbw_cg_het_trial above has itself converged
# and been checked for a sensible fit (same "one prototype first"
# discipline, just at curated-set scale).
Rscript scripts/01_generate_models.R --set=key_bivariates_cg_het
# (staging/submission intentionally not shown here yet -- see gate above)
```

## License concurrency

ASReml on this account is licensed for a limited number of concurrent
sessions (observed 2026-09-15: "14 sessions available, with 8 currently
in use" -- a pool shared with whatever else is running on the account,
not reserved for this pipeline). `slurm/submit_batch.sh` therefore
submits every job as **one Slurm job array** with a concurrency
throttle (`--array=1-N%CONCURRENCY`) rather than N independent jobs --
Slurm queues everything but only ever runs `CONCURRENCY` tasks at once.
Default is 3 (`ASREML_CONCURRENCY=5 slurm/submit_batch.sh` to override).
Each array task resolves its own `JOBNAME` at runtime from a
timestamped job-list file (`run/state/job_list_<timestamp>.txt`) via
its `SLURM_ARRAY_TASK_ID`, since Slurm doesn't know per-task job names
up front for an array -- check `slurm/slurm_logs/array-<jobid>_<task>.out`'s
first line for which model a given task actually ran.

## Convergence and `!CONTINUE`

Every generated `.as` file includes `!CONTINUE` on its top job-control
line unconditionally (matching legacy convention). Per the ASReml
manual, this is a safe no-op on a first run (no `.rsv` file exists yet)
and automatically resumes from the previous run's `.rsv` on any
subsequent run of the same `.as` file -- so `slurm/run_one_model.sh`'s
retry loop is simply "run the same command again up to N times",
classifying `.asr` after each attempt via
`lib_classify_convergence.R` (status strings taken directly from
`reference/ASReml-4.2-Functional-Specification.pdf` Section 15.5, not
guessed):

- `CONVERGED` -> stop, run the `.pin` post-processing step (see below), done.
- `NOT_CONVERGED` / `CONVERGED_PARAMS_UNSTABLE` -> loop again (recoverable).
- `CONVERGENCE_FAILED` -> stop immediately, flagged for manual review.
  Per the manual this means the REML likelihood is oscillating and
  needs a model/starting-value change, not more iterations -- retrying
  would waste the attempt budget on something `!CONTINUE` cannot fix.
- `MISSING` / `UNKNOWN` -> stop immediately, flagged for manual review.

Default `MAX_ATTEMPTS` is 5 (`slurm/run_one_model.sh <jobname>
[max_attempts]`, or set `ASREML_MAX_ATTEMPTS` in the environment before
calling `submit_batch.sh`).

**`.pin` post-processing is not optional.** The legacy dump shows this
step (`asreml -P<jobname> <jobname>.pin`, which turns a converged run's
VPREDICT block into a `.pvc` file) was run for every bivariate job but
for *no* univariate job (no `a_uni_*.pvc` exists anywhere in the legacy
dump) -- meaning the legacy heritabilities in Table 2 were evidently
computed by hand from the `.asr` Model_Term Gamma column rather than
read off a `.pvc`. `run_one_model.sh` always runs this step after
`CONVERGED`, so every model gets both.

## Where things run

**ASReml is not installed on the VM by design** (see this repo's
`CLAUDE.md`/`docs/revision_plan.md`): models are generated and
statically checked here, then actually run on HPC. Because of this, the
validation above could only be done by feeding real legacy `.asr`/`.pvc`
files through `03_parse_results.R`'s parsing logic -- it confirms the
*parser* and the *VPREDICT index assumption* (see next section) are
correct, but not yet that the newly-*generated* `.as` files run cleanly
end-to-end in real ASReml. That is the first thing to check on HPC.

## Important things flagged for review

- **VPREDICT index provenance (bivariate models).** The numeric indices
  in every bivariate model's `VPREDICT !DEFINE` block were decoded by
  hand from one real, converged legacy result
  (`bi_ch4_ch4ratio.asr`) and are assumed to hold for every other pair
  because every pair shares the identical declaration order and
  G-structure. This is a structural inference from one worked example,
  not verified against every pair (no ASReml on the VM to check). The
  parser does not rely on this assumption alone -- it independently
  recomputes h2/rg/re/rp from the named `Model_Term` rows and flags any
  disagreement (`check_agree_rg`/`check_agree_rp` columns in
  `results/bivariate_summary.csv`). **Watch this column on the first
  HPC run of the validation set.**
- **Bivariate starting values.** Legacy tuned per-pair starting values
  (the `Trait 0 US ... !GP` block) by hand. For pairs that already exist
  in `analysis/legacy/asreml_scripts/`, the generator reuses that exact
  block verbatim. For any pair with no legacy counterpart (relevant once
  `--set=full` generates new combinations not in the original 25
  Mar-29 Apr sweep, per `docs/asreml_legacy_map.md`), no starting values
  are supplied and the generated `.as` file carries a comment saying so
  -- ASReml will auto-initialize, which may just mean more iterations,
  but has not been tested. If convergence is poor for these pairs, the
  manual's suggested fix (Section 5.8) is to bootstrap starting values
  with `!MAXIT 0` and edit the resulting `.tsv` file; this is not yet
  automated.
- **Two real, pre-existing discrepancies inherited from the legacy
  analysis, not introduced here** (both already documented in
  `docs/asreml_legacy_map.md` Section 8): the CH4/rumen heritability
  (manuscript 0.29 vs. 0.37 univariate/0.26 bivariate-diagonal in the
  legacy files) and a CT-record-count mismatch (766 in the manuscript vs.
  780 in the legacy `ct_muscle_kg` model). Both will resurface once
  `--set=full` reaches those models; they are open items to resolve, not
  bugs in this pipeline.
- **Fixed-effects list corrections vs. legacy.** The legacy
  `bi_ch4_ch4ratio.as` has `Tr.het` listed twice and
  `Tr.dam_parity_group_num` out of the position used everywhere else
  (hand-editing artefacts). This pipeline uses one canonical
  `fixed_effects` list (`config/models.yaml`) for every model, so
  neither artefact is reproduced -- flagged in case the resulting Wald F
  table row count/order looks different from a legacy `.asr` for the
  same pair.
- **Field-definition list gaps in some legacy `.as` files.** Comparing
  generated `a_uni_methane.as`/`bi_methane_ch4ratio.as` against their
  legacy counterparts shows the legacy files omit 3-4 mid-file phenotype
  columns (`methane_per_lw`, `ch4_adj_MBW_co2`, `adg_g`, and for the
  bivariate case also `ct_muscle_kg`) from their field-definition block,
  even though ASReml's field definitions must be given in file order
  (Section 5.4) -- either those columns did not exist in whatever exact
  version of `P3_data.csv` those particular legacy jobs actually read,
  or there is a latent positional bug in those legacy `.as` files. Not
  resolved here; this pipeline's generator validates its own
  field-definition list against the real phenotype file header at
  generation time specifically to avoid this class of error (see
  `01_generate_models.R`'s validation step).
- **CH4/LW (`ch4lw`) is generated but is not a Table 2 trait** -- it is
  included because it exists in the legacy dump and is believed (not
  confirmed) to feed the selection-index work in the separate
  `Methane_Selection_Index_Analysis` repository instead
  (`docs/asreml_legacy_map.md` Section 1).
- **HPC path placeholders.** `config/paths.yaml`'s `hpc:` block uses
  placeholder paths following this account's usual convention
  (`Dermot_analysis/Phd/methane_selection_revision/...`) -- confirm or
  correct these before the first HPC run; nothing else in the pipeline
  needs to change if they're wrong, since every other script reads paths
  from this one file.
- **`results/derived_h2.csv` and `results/composite_h2_se.csv` are
  likely stale (flagged 2026-09-20).** Both were finalized in commit
  `df51adf` (17 Sep), which predates the 18 Sep shared->independent-PE
  fix to `--set=components`'s own bivariate pairs. They most likely
  still reflect the OLD shared-PE component models -- treat as
  provisional until `--set=components` is rerun on HPC and
  `04_derive_ratio_from_components.R` is rerun against the fresh
  results.

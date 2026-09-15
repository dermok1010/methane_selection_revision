# ASReml automated pipeline (revision)

Replaces the legacy manually-edited `.as` file collection
(`analysis/legacy/asreml_scripts/`) with a config-driven, reproducible
system for generating, running, and parsing the submitted-style
univariate/bivariate ASReml sweep. This does **not** implement the
"component-trait redesign" discussed for later revision -- it reproduces
the existing model structure and trait definitions (including the
existing residual-methane construction) so they can be regenerated and
rerun reliably. See `docs/asreml_legacy_map.md` for the reconstruction
this pipeline is built from, and `docs/revision_plan.md` for where it
sits in the overall revision.

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

Next step is an actual HPC trial-batch run of this same validation set
(see "Workflow" below) to confirm the *generated* `.as` files -- not
just the parser -- behave as expected once real ASReml is involved
(workspace sizing, `!CONTINUE` behaviour, the `.pin` post-processing
step, actual convergence). Only after that should `--set=full` be
generated and run.

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
                 --set=validation | --set=full
             02_stage_run_dir.R  -- populate run/ with phenotype +
                 pedigree + generated models under the bare filenames
                 the .as files reference. --platform=vm|hpc
             03_parse_results.R  -- run/*.asr(+.pvc) -> results/*.csv,
                 with independent cross-checks (see below).
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
slurm/submit_batch.sh
Rscript scripts/03_parse_results.R
```

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

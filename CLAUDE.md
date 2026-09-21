# methane_selection_revision

Peer-review revision workflow for the manuscript "Genetic Parameters and
Selection Responses for Alternative Methane Trait Definitions in
Pasture-Based Sheep". This repository manages tracing reported results back
to source analysis, addressing reviewer comments, any additional revision
analyses, and producing a revised manuscript.

See also `~/.claude/CLAUDE.md` for VM-wide conventions (this repo is
listed in that file's project table). GitHub: `dermok1010/methane_selection_revision`
(private, created 2026-09-15).

## Working principles

- **The submitted manuscript is an immutable baseline.** Everything under
  `manuscript/submitted/` is frozen exactly as received. Never edit, rename,
  or overwrite it. All manuscript revisions go in `manuscript/revised/` as
  new, clearly-versioned files.
- **Never silently alter scientific results.** If a number, figure, or
  claim changes, the change and its justification must be explicit and
  traceable -- not a quiet edit.
- **Distinguish original analysis from revision analysis.** Code/material
  from the original submission belongs in `analysis/legacy/` and should be
  preserved, not destructively rewritten. New analysis performed to address
  reviewer comments belongs in `analysis/revision/`. Work that audits or
  traces legacy results (without changing them) belongs in
  `analysis/diagnostics/`.
- **Maintain reproducibility.** Any analysis added or rerun should be
  runnable from documented inputs to documented outputs. Record software
  versions and random seeds where relevant (this manuscript's selection-index
  work uses Monte Carlo uncertainty propagation, which is seed-sensitive).
- **Document analytical changes.** When a legacy analysis is corrected,
  extended, or reinterpreted, record what changed, why, and what the
  numerical consequence was.
- **Do not invent missing methodological details.** If the manuscript or
  legacy code is ambiguous or silent on a method, say so explicitly rather
  than filling the gap with a plausible-sounding assumption.
- **Trace manuscript values back to source analysis where possible.** Every
  reported number, table, or figure should eventually be traceable to the
  code and data that produced it. Where that trace can't yet be made,
  record it as an open question rather than leaving it implicit.
- **Preserve old code rather than destructively rewriting it.** Legacy
  analysis code is evidence of what actually produced the submitted
  results. Fix forward with new, separately-versioned code rather than
  editing legacy scripts in place, unless explicitly instructed otherwise.
- **Do not modify the upstream selection-index repository**
  (`dermok1010/Methane_Selection_Index_Analysis`) unless explicitly
  instructed. Treat it as a read-only reference. Keep it as a separate
  sibling checkout (`~/Methane_Selection_Index_Analysis`), not copied or
  nested inside this repository's `.git` history.
- **Record commit SHAs when external repositories are used.** Any time the
  upstream selection-index repository (or any other external resource) is
  used to produce or check a result, record the exact commit SHA in use so
  the revision stays reproducible even if that repository changes later.
- **Use version control throughout.** Commit meaningful, documented steps
  rather than large undocumented batches of change.
- **Prioritise scientific correctness over simply satisfying a reviewer.**
  If addressing a reviewer comment surfaces a real problem, fix the
  problem -- don't just produce a response that superficially answers the
  comment.
- **Flag uncertainty explicitly.** Distinguish clearly between what a
  source (manuscript, legacy code, reviewer comment) actually states, what
  is reasonably inferred from it, and what remains genuinely unknown or
  unverified.
- **Distinguish reviewer-driven analyses from original-submission
  analyses.** Never let the two become ambiguous in the repository's
  history or documentation -- a reader should always be able to tell which
  analyses were part of the original submitted study and which were added
  during revision.

## Upstream reference repository

- `dermok1010/Methane_Selection_Index_Analysis`
  (https://github.com/dermok1010/Methane_Selection_Index_Analysis) --
  the selection-index analysis (Smith-Hazel index construction, G/P matrix
  handling, ratio/residual/linear-index trait comparison, response-frontier
  convex-hull analysis, Monte Carlo uncertainty propagation) associated
  with the submitted manuscript. Read-only reference; not vendored into
  this repository. See `docs/manuscript_context.md` for what's currently
  known about its relationship to specific manuscript results, and record
  the commit SHA in use whenever it's consulted analytically.

## Current stage

Rebuilding the submitted analysis on HPC via a new config-driven ASReml
pipeline (`analysis/revision/asreml_pipeline/`), checkpointed against the
submitted manuscript at each stage. The PAC phenotype pipeline and a new
validated pedigree are done. All 16 univariate genetic-parameter models
have converged with clean independent cross-checks. The narrowed
component-trait analysis (revision plan Section 5 step 7 -- heritabilities
for the 9 composite/ratio traits, derived from their underlying components'
(co)variances) has real HPC-derived results in
`analysis/revision/asreml_pipeline/results/derived_h2.csv`.

**2026-09-18**: bivariate models now default to independent (trait-
specific) permanent-environment variances where possible (generalizing a
2026-09-17 fix from a 2-pair pilot to every pair), and two new model
families were added: `--set=stage_het` (heterogeneous residual variance
by the manuscript's own growing/mature <660-day split, all 9 Table 2
traits -- Reviewer 1's contemporary-group-heteroscedasticity concern) and
`--set=young_old` (a young-vs-mature CH4 bivariate genetic correlation).
**This means the existing `results/bivariate_summary.csv` `--set=full`
sweep (29/52 pairs CONVERGED) reflects the OLD shared-PE model spec and
is now a historical record, not a result for the current `models/bi_*.as`
files** -- none of the three changes have been run on HPC yet. See
`docs/revision_plan.md`'s decision log for the detailed, dated history and
open items -- it is the authoritative current-status record, kept more
up to date than this section.


**2026-09-18 later -- Reviewer 1 variance-heterogeneity follow-up.**
The univariate `cg_het` and `stage_het` sweeps have now been run on
HPC. The same five full-information methane definitions converged under
both structures (`methane`, `ch4mbw`, `ch4ratio`, `ch4rmtmbw`,
`ch4rmtmbwco2`); the ADG-derived and 780-record CT traits
(`ch4adg`, `ch4rmtadg`, `ch4muscle`, `ch4rumen`) aborted at
iteration 1 with an AI-matrix singularity. For the stage models the
singularity is specifically the second stage residual variance (ASReml
Code S: no information), consistent with those sparse traits being
restricted to one physiological stage rather than evidence that the
heterogeneity idea itself is invalid. The CH4 CG-heterogeneous model
converged and materially changed variance partitioning relative to the
homogeneous model, so this cannot be answered by the young-vs-mature
rg alone.

Do **not** launch a heterogeneous version of the full bivariate sweep.
A single discovery prototype has been added:
`--set=bi_cg_het_trial` -> `bi_methane_ch4mbw_cg_het_trial.as`.
It fits independent PE, a freely estimated genetic US matrix, and
`residual sat(cg_mean_cl).us(Trait).units`, i.e. one 2x2 residual US
matrix per source-within-CG-mean class. This is intentionally a
parameter-rich stress test (~90 residual parameters for ~30 classes),
not yet the intended final model. Its purpose is to see whether the
headline CH4 x CH4/MBW genetic correlation is materially altered when
the observed residual heterogeneity is carried into a bivariate model.
If the trial is unstable/non-estimable, do not force convergence; move
to a more parsimonious heterogeneous-scale/common-correlation structure
instead. Keep the run discovery-only until the real ASReml parameter
numbering is read from `.pvc/.asr`.

HPC resume commands after pulling main:
`Rscript analysis/revision/asreml_pipeline/scripts/01_generate_models.R --set=bi_cg_het_trial`;
`Rscript analysis/revision/asreml_pipeline/scripts/02_stage_run_dir.R --platform=hpc`;
then submit only the new trial model (or use the normal batch script after
confirming the staged model list). Commit/push the raw-result summary and
the comparison with the homogeneous rg before expanding scope.

**2026-09-20 -- scope decision, closes the bivariate-sweep question
above (full detail: `docs/revision_plan.md` Section 4B).** User
instruction, four points: (1) keep all 9 methane definitions, their
univariate genetic parameters are now final (all CONVERGED already --
no new work needed); (2) residual heterogeneity decided qualitatively
per trait by comparing homogeneous vs `--set=cg_het` (the primary
heterogeneity treatment; `young_old`'s rg=0.9908 is supporting evidence
for reviewers, not the primary one) -- **not yet finished**: the 5
CONVERGED `cg_het` traits' VPREDICT blocks are still discovery-only
placeholders, and the raw `.pvc`/`.asr` needed to finish them no longer
exists locally (gitignored by design); (3) `--set=full`'s 52-pair sweep
is superseded (kept, not deleted) by a new curated 23-pair
`--set=key_bivariates` (each alt. definition vs CH4; CH4 vs its
biologically relevant components; each ratio/residual trait vs its own
denominator) -- generated 2026-09-20, not yet run on HPC; (4) an 18-pair
CG-heterogeneous variant, `--set=key_bivariates_cg_het`, is generated
but explicitly gated on the `bi_cg_het_trial` prototype above actually
converging first -- do not submit it before that. Also flagged while
implementing this: `results/derived_h2.csv`/`composite_h2_se.csv` were
finalized before the 18 Sep independent-PE fix and are likely stale.

**2026-09-20, later -- bivariate CG-heterogeneous residual abandoned
(full detail: `docs/revision_plan.md` Section 4C).** Two structurally
different attempts (`sat(cg_mean_cl).us(Trait).units`, then a more
parsimonious `idh(cg_mean_cl).us(Trait).units` retry) both failed on
HPC for real structural reasons (`cg_mean_cl`'s classes are too small
and unbalanced for either form), not lack of signal. User decision:
stop here -- rely on the univariate `cg_het` results (real, large
variance-partitioning shifts for `methane`/`ch4mbw`/`ch4rmtmbw`/
`ch4rmtmbwco2`) and the `young_old` bivariate check as the available
evidence, and report the bivariate attempt as a transparent limitation
in the revised paper rather than force a third guess at the syntax.
`key_bivariates_cg_het`/`key_bivariates_cg_het_scale` stay generated
for reference but should not be submitted without new information.

**2026-09-21 -- CH4 ratio on a molar basis, per user request (full
detail: `docs/revision_plan.md` Section 4D).** New derived trait
`ch4_ratio_mol` (mol CH4/(mol CH4+mol CO2)) recovered exactly from the
existing `ch4_l_day_1v3`/`co2_l_day_1v3` volumetric columns via the
ideal gas law -- mole ratio equals volume ratio for two gases at the
same pressure/temperature, no molar-mass conversion needed. Checks
whether the manuscript's mass-basis `ch4_ratio` heritability (h2=0.08,
the reviewers' headline discrepancy vs. Jonker et al.) is sensitive to
the unit basis Reviewer 1 flags as never stated. New `--set=mol_ratio`
generates its own univariate model plus a bivariate against `ch4_ratio`
(genetic correlation between the two bases). Generated VM-side only --
not yet run on HPC.

**2026-09-21, later.** `a_uni_ch4ratiomol` CONVERGED on HPC: h2=0.1261
(SE 0.0141), t=0.1389 (SE 0.0091) -- higher than mass-basis `ch4ratio`'s
0.1016 (SE 0.0125)/0.1023 (SE 0.0079), a real but modest sensitivity to
unit basis, not a resolution of the Jonker et al. discrepancy on its
own. `bi_ch4ratio_ch4ratiomol` failed on HPC (`PROGRAM failed in
AIDGGI`) under the old shared-PE spec -- same root cause as the
2026-09-17 `methane_weight`/`methane_co2` PE-collapse issue, now fixed
the same way (independent PE, picked up automatically now that
`ch4ratiomol` has a real CONVERGED row in `results/univariate_summary.csv`).
Regenerated discovery-only; not yet run on HPC. Full detail:
`docs/revision_plan.md` Section 4D.

# Reviewer action plan A2 (model documentation/diagnostics) and A3
# (physiological-stage heterogeneity sensitivity)

Audits the frozen revision pedigree/phenotype data and the already-run
component-trait models. Changes no scientific result; produces
supplementary-material inputs only. See `docs/revision_plan.md`'s
decision log for the dated narrative.

## A2: model specification

Confirmed directly from `analysis/revision/asreml_pipeline/config/models.yaml`
(itself decoded from the legacy `.as` files, `docs/asreml_legacy_map.md`
Section 1): **every component trait shares the identical fixed-effects
formula** -- this answers plan A2's "ensure the same model specification
is used consistently" bullet as an existing fact, not new work.

- Fixed: `mu + SEX + TX+BR+SU+CL+CV+LY+UN (breed proportions,
  Texel/Belclare/Suffolk/Charollais/Cheviot/Lleyn/"unknown-other") + het
  (heterosis) + rec (recombination loss) + REARING_RANK + BIRTH_RANK +
  ewe_birth_rank + ewe_rearing_rank + age_in_weeks +
  dam_parity_group_num + ch4_GroupNumber (PAC contemporary group,
  fitted as fixed)`
- Random: `ped(ANI_ID)` (additive genetic, numerator relationship
  matrix) + `ide(ANI_ID)` (permanent environment, shared scalar across
  traits in bivariate models -- see decision log's PE-sensitivity
  finding) + residual (added automatically by ASReml).
- `UN` is an undocumented "unknown/other" breed-proportion term present
  in every legacy model but not named among the manuscript's stated six
  breeds -- flagged for the revised Methods text, not a data problem.

## A2: pedigree completeness / sire counts / connectedness / confounding

Computed by `01_pedigree_connectedness.R` from the frozen revision
pedigree (`analysis/revision/pedigree/data/pedigree_full_2026-09-15.csv`,
36,449 animals) and phenotype file (8,185 animals, 15,869 records). Full
output in `pedigree_connectedness_stage_summary.txt`; headline numbers:

- **Completeness**: 100% of phenotyped animals are in the pedigree;
  88.5% have both parents known, 5.3% have neither known.
- **Sire/dam counts**: 1,025 unique sires directly above phenotyped
  animals (8,757 across the full traced pedigree); 5,216 unique dams
  directly above phenotyped animals (21,637 across the full pedigree).
- **Pedigree depth**: mean 17.6, median 19, max 34 traceable generations
  back (simple max-lineage-depth count, not the more elaborate
  equivalent-complete-generations metric).
- **Connectedness**: of 1,025 sires with progeny records, 73.1% link 2+
  PAC contemporary groups (43.8% link 5+); only 26.9% are confined to a
  single group. One sire links as many as 205 groups. Overall the data
  are reasonably well genetically connected across contemporary groups.
- **Confounding -- real finding, worth flagging in the revised text**:
  breed-proportion within-contemporary-group variance as a fraction of
  total variance (1.0 = no confounding with `ch4_GroupNumber`, near 0 =
  breed proportion is almost fully determined by which group an animal
  is in) is **0.043 for Cheviot (CV) and 0.152 for Lleyn (LY)** --
  these two breeds' proportions are close to fully nested within
  contemporary group, so their fixed-effect estimates are not cleanly
  separable from contemporary-group effects. Texel/Suffolk (0.64-0.68)
  and Belclare (0.40) are reasonably well separated; Charollais (0.21)
  and the "unknown/other" term (0.28) sit in between.
- SEX is not confounded with contemporary group overall (both sexes
  appear across many groups), but 82.1% of individual groups are
  single-sex -- expected given male ram lambs are almost all <1yr and
  rarely co-measured with mature ewes.

### Fixed-effect Wald F significance (all 7 component-trait univariate models)

Parsed directly from each model's own `.asr` Wald F table by
`03_wald_fixed_effects.R`; full F-inc/df/p-values in
`wald_fixed_effects.csv`. `ch4_GroupNumber` (1435 levels) is excluded --
ASReml itself drops it from the Wald table by default given that many
levels ("Use !DENSE 1455 to force ... into Wald F table"); testing it
formally would need a separate, much more expensive rerun, not
attempted here.

| term | methane | co2 | mbw | adg | muscle | rumen | weight |
|---|---|---|---|---|---|---|---|
| SEX | | *** | *** | | *** | * | *** |
| TX | * | *** | *** | | *** | | *** |
| BR | | | | | *** | *** | |
| SU | * | | *** | | *** | *** | *** |
| CL | *** | | *** | ** | *** | *** | *** |
| CV | | ** | | | | | * |
| LY | | | | | | | |
| UN | *** | *** | *** | *** | *** | *** | *** |
| het | * | | | *** | *** | | |
| rec | | *** | | ** | *** | | *** |
| REARING_RANK | *** | *** | *** | | *** | | *** |
| BIRTH_RANK | *** | | *** | * | | | *** |
| ewe_birth_rank | *** | *** | *** | n/a | n/a | n/a | *** |
| ewe_rearing_rank | ** | | *** | n/a | n/a | n/a | *** |
| age_in_weeks | * | ** | *** | *** | *** | *** | *** |
| dam_parity_group_num | | | | * | | | ** |

(`*` p<0.05, `**` p<0.01, `***` p<0.001, blank = not significant,
n/a = term not in that model's Wald table as reported by ASReml.)

**Notable**: the undocumented `UN` breed-proportion term (see model
specification above) is significant at p<0.001 for **every single
trait** -- it is not a minor/spurious covariate and needs proper
description in the revised Methods, not just a passing mention. LY
(Lleyn) is never significant for any trait -- consistent with its very
low within/contemporary-group variance ratio (0.152) found above,
i.e. there may simply not be enough independent information on Lleyn
proportion once contemporary group is accounted for.

### Model-diagnostics table (records, animals, convergence, variance components)

| trait | n records | resid. df | VA (ped) | PE (ide) | residual | h2 | h2 SE |
|---|---|---|---|---|---|---|---|
| methane | 15,869 | 14,418 | 3.920 | 1.186 | 10.735 | 0.247 | 0.021 |
| co2 | 15,869 | 14,418 | 19164.6 | 17141.0 | 31226.5 | 0.284 | 0.023 |
| mbw | 15,869 | 14,418 | 2.191 | 1.919 | 0.958 | 0.432 | 0.026 |
| adg | 4,437 | 3,941 | 0.00059 | 0.00172 | 0.00013 | 0.241 | 0.056 |
| muscle | 780 | 693 | 0.396 | 0.277 | 0.578 | 0.317 | 0.115 |
| rumen | 780 | 693 | 0.167 | 0.109 | 0.766 | 0.160 | 0.096 |
| weight | 15,869 | 14,418 | 30.467 | 28.081 | 14.308 | 0.418 | 0.026 |

All 7 CONVERGED with clean independent cross-checks (see
`results/univariate_summary.csv`). muscle/rumen's small sample (~712
records, CT-derived traits) drives their much larger h2 SEs (0.10-0.12
vs. 0.02-0.06 for the others) -- worth stating explicitly alongside
those two heritabilities rather than leaving the precision difference
implicit.

## A3: physiological-stage heterogeneity

Pre-specified rule (age-based, not sex-based, since sex-splitting would
conflate two different questions): **young = age_in_years < 2
(lambs/hoggets, essentially all male ram lambs by construction since
males are ~100% <1yr in this dataset); mature = age_in_years >= 2**
(this group is >99.8% female -- effectively "mature ewes" as the
reviewer comment names it, even though the split rule itself is age-,
not sex-based).

| stage | n records | n animals | mean CH4 (g/day) | SD | CV |
|---|---|---|---|---|---|
| young | 7,600 | 4,231 | 14.43 | 5.62 | 39.0% |
| mature | 8,269 | 4,403 | 21.10 | 7.70 | 36.5% |

449 animals have records in both stages. Mature animals have ~46%
higher mean CH4 and higher absolute SD but slightly lower CV than young
animals -- consistent with the reviewers' concern that pooling groups
of very different absolute scale is worth checking formally, not just
noting descriptively.

**Sensitivity model result -- CONVERGED, and the difference is real,
not "materially unchanged."** `a_ch4_stage_het_residual.as`
refits the pooled CH4 model (identical fixed/random-effects
specification to `a_uni_methane.as`) with
`residual sat(stage).idv(units)` instead of a single homogeneous
residual variance -- the minimal change requested by the plan (residual
heterogeneity only, not also PE, "do not complicate the model
unnecessarily"). Generated as a discovery-only VPREDICT run (same
discipline as the PE-sensitivity variants in
`analysis/revision/asreml_pipeline/`) since `sat(stage).idv(units)` is a
new residual structure for this pipeline and its parameter print order
isn't assumed. CONVERGED on HPC 2026-09-17.

Real parameter numbering (read off the `.pvc`, not assumed): 1=`ped`
(VA), 2=`ide` (PE), 3=`sat(stage,1).idv(units)` (residual for the
8,269-record group = mature), 4=`sat(stage,2).idv(units)` (residual for
the 7,600-record group = young).

| | VA | PE | Residual | VP | h2 | repeatability |
|---|---|---|---|---|---|---|
| pooled (`a_uni_methane`) | 3.920 | 1.186 | 10.735 | 15.840 | 0.247 | 0.322 |
| stage-het: mature | 4.157 | 1.269 | **14.905** | 20.331 | **0.205** | 0.267 |
| stage-het: young | 4.157 | 1.269 | **6.165** | 11.591 | **0.359** | 0.468 |

VA and PE both increase modestly (~6-7%) once residual heterogeneity is
allowed, but the residual variance itself differs by **2.4x** between
stages (mature 14.91 vs. young 6.17) -- consistent with the raw
descriptive stats (mature CH4 mean 21.1 vs. young 14.4 g/day, higher
absolute SD). Because the derived h2/repeatability divide by a residual
that differs this much by stage, the **stage-specific heritabilities
differ by ~75% relative to each other** (0.21 mature vs. 0.36 young),
straddling the pooled model's single estimate (0.25) from both sides.

**This crosses the plan's own escalation threshold** ("if estimates are
materially unchanged, stop there... only escalate if the simple
heterogeneity check reveals a biologically important change") -- this
is not a materially-unchanged result. It directly substantiates
Reviewer 1's contemporary-group/scale-heterogeneity concern and
Reviewer 2's stage-splitting question with a real number, not just a
descriptive caveat. Whether to escalate further (stage-specific
univariate reruns of other component traits, or a young-vs-mature
bivariate genetic analysis) is a scope decision for the user, not made
here -- flagged in `docs/revision_plan.md`'s decision log.

## Status

All of A2 and A3's descriptive/diagnostic deliverables are done (model
specification, pedigree completeness, connectedness, confounding, Wald
F-significance, model-diagnostics table, CH4-by-stage descriptives and
sensitivity model). The one open item is a scope decision, not more
data work: whether to escalate the stage-heterogeneity finding beyond
this single CH4 sensitivity check (see above), which the plan
deliberately leaves to the user's judgement rather than an automatic
next step.

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

**Not yet done**: the formal fixed-effect Wald F-significance table and
a compact convergence/variance-component diagnostics table both need
the models' `.asr` files (Wald F statistics print there) -- these
already exist on HPC from the earlier CONVERGED runs, just not pulled
back to the VM yet.

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

## Next steps (need HPC)

1. Pull back the already-CONVERGED univariate `.asr` files (no new
   computation) to build the Wald F-significance table -- requested but
   not yet landed.

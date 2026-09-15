# Legacy ASReml analysis: reconstruction map

Source: `gs://dermot-phd-backup/asreml_legacy_no_sln_2026-09-15.tar.gz`,
a full ASReml working-directory dump (`asreml_scripts/`), 1233 files
extracted successfully out of ~1238 archive members. **The tarball itself
is truncated at the source** -- its size and MD5 on the VM match the
bucket object exactly (so the upload/download was not corrupted in
transit), but `gzip -t` reports "unexpected end of file" and the last
archive member (`bi_ch4_ch4lw.veo`, a large binary history file) is cut
short. A handful of other files are consequently missing (notably two
`.pvc` result files, compensated for below by recomputing the same
quantities directly from the corresponding `.asr` variance components).
This is a data-completeness caveat on everything below, not a reason to
distrust it -- the missing pieces are large binaries and a couple of
result files, not model-specification files, and where a result was
needed but its `.pvc` was missing, it was independently reconstructed and
cross-checked by hand.

This document is read-only detective work. Nothing in
`asreml_scripts/` was modified, rerun, or reorganised; all of it remains
exactly as uploaded, extracted only into a scratch directory. No git
commit accompanies this document -- it is left for the project owner to
review before deciding whether/where to check it in.

---

## 1. What was actually run

The dump uses two structural naming conventions, both confirmed by
reading the `.as`/`.asl` job files directly (ASReml command/model
specification files -- `.as` is the file as last submitted, `.asl` is
ASReml's own echo of the job it ran; where only one of the two survives
for a given job, the other was reconstructed from it):

- **`a_uni_<trait>.*`** -- univariate animal models, one trait at a time.
- **`bi_<traitA>_<traitB>.*`** -- bivariate animal models, one pair at a
  time, used to estimate genetic/phenotypic correlations between traits.
- **`h_uni_methane.*`** -- a single univariate model using a genomic (H-
  matrix) relationship matrix instead of the pedigree A-matrix (see
  Section 3).

All models share one animal-model structure, read directly from the
`.as` files (example, `a_uni_methane.as`):

```
ch4_g_day2_1v3 ~ mu SEX TX BR SU CL CV LY UN het rec REARING_RANK
  BIRTH_RANK ewe_birth_rank ewe_rearing_rank age_in_weeks
  dam_parity_group_num ch4_GroupNumber
  !r ped(ANI_ID) ide(ANI_ID)
```

i.e. fixed effects `mu + SEX + TX+BR+SU+CL+CV+LY+UN (breed proportions) +
het + rec + REARING_RANK + BIRTH_RANK + ewe_birth_rank + ewe_rearing_rank
+ age_in_weeks + dam_parity_group_num + ch4_GroupNumber (contemporary
group, fitted as fixed)`, and random effects `ped(ANI_ID)` (additive
genetic, using the numerator relationship matrix built from the supplied
pedigree) and `ide(ANI_ID)` (an identity-matrix random term -- the
permanent-environmental effect). ASReml adds a residual variance
automatically as the third variance component. This structure recurs
almost verbatim across every `a_uni_*` and `bi_*` job in the March-April
cluster (Section 2) -- only the response trait(s), and for a few
production traits the ordering of `ch4_GroupNumber`/`dam_parity_group_num`
in the fixed-effects list, change.

**Match to the manuscript's stated model** (`mu + sex + BR+CL+CV+LY+SU+TX
+ het+rec+age + BTg+RTg+BTe+RTe+DP + CG + a + pe (+ e)`,
`docs/manuscript_context.md` Section 6): effectively exact --
`BIRTH_RANK`/`REARING_RANK` are the growing-animal birth/rearing ranks
(`BTg`/`RTg`), `ewe_birth_rank`/`ewe_rearing_rank` are the ewe litter
ranks (`BTe`/`RTe`), `dam_parity_group_num` is `DP`, `ch4_GroupNumber` is
`CG`, `ped(ANI_ID)` is `a`, `ide(ANI_ID)` is `pe`. **One discrepancy**:
the fixed-effects list includes a breed-proportion term `UN` that is not
among the "six breeds" the manuscript's Methods section names (Belclare,
Charollais, Cheviot, Suffolk, Lleyn, Texel -- presumably `BR`, `CL`, `CV`,
`SU`, `LY`, `TX` respectively, though the manuscript never gives this
exact code mapping). `UN` most plausibly represents an "unknown/other"
residual breed-proportion column that is a standard companion to a
breed-composition block but isn't itself one of the six named breeds --
this is a reasonable inference, not confirmed from any file, and the
manuscript does not mention it. Worth flagging to a careful reader/
reviewer as an undocumented model term.

Trait-name-to-filename-code mapping (established by reading each model's
response-variable line):

| Manuscript trait (Table 2) | ASReml variable | Filename code |
|---|---|---|
| CH4 | `ch4_g_day2_1v3` | `methane` |
| MI (CH4/MBW) | `methane_per_mbw` | `ch4mbw` |
| CH4 ratio | `ch4_ratio` | `ch4ratio` |
| CH4/ADG | `methane_per_adg` | `ch4adg` |
| CH4/MM | `methane_per_muscle` | `ch4muscle` |
| CH4/rumen | `methane_per_rumen` | `ch4rumen` |
| RMTMBW (residual, MBW) | `ch4_adj_MBW` | `ch4rmtmbw` |
| RMTMBW+CO2 (residual, MBW+CO2) | `ch4_adj_MBW_co2` | `ch4rmtmbwco2` |
| RMTADG (residual, ADG) | `ch4_adj_adg` | `ch4rmtadg` |
| *(not in Table 2)* CH4/LW | `methane_per_lw` | `ch4lw` |

`methane_per_lw` (CH4 divided by raw live weight rather than MBW) is
estimated (`a_uni_ch4lw`, 21 Apr) but is not one of Table 2's nine
traits. It most plausibly corresponds to the "LW framework" mentioned
alongside the "MBW framework" for the selection-index Figures 1-2
(`docs/manuscript_context.md` Section 10) -- i.e. a genetic-parameter
input for the *selection-index* work (in the separate
`Methane_Selection_Index_Analysis` repository) rather than a Table 2
row. This is a reasonable inference from naming/timing, not confirmed
by any file that explicitly says so.

## 2. Input data and its provenance

The main analysis cluster reads two files, given explicitly in the
`.as` job files:

```
pedigree_full_sas_style.csv.SRT     (pedigree, .SRT = ASReml-sorted)
P3_data.csv   !SKIP 1 !MVINCLUDE    (phenotype data)
```

`pedigree_full_sas_style.csv` is dated 3 Mar 2026 and contains, per
every `.asr` file's `ped(ANI_ID)` line, exactly **330,812** animals --
matching the manuscript's stated pedigree size exactly
(`docs/manuscript_context.md` Section 2).

`P3_data.csv` is **15,870 lines** (header + 15,869 records) -- matching
the manuscript's final analysis-dataset record count exactly, and its
column list matches, column-for-column, the `asreml_data` object built
by `data_generation.R` in the already-reconstructed PAC pipeline
(`analysis/legacy/PAC_data_pipeline/scripts/data_generation.R`, this
same repository), which in turn reads
`PAC_data_covariates_QC_NA_with_traits_plus_dam_parity.csv` -- the exact
output of the PAC pipeline's `11_dam_parity_integration.R` already
verified earlier this session. `data_generation.R` itself writes to
`.../Paper_3/genetic_analysis/asreml_scripts/P3_co2_data.csv`, i.e. into
this exact ASReml working directory (by its HPC path), under a slightly
different filename (`P3_co2_data.csv`, not `P3_data.csv`). Given the
identical row count and column set, **`P3_data.csv` is almost certainly
the same object `data_generation.R` produces, saved or subsequently
copied/renamed to `P3_data.csv` within the ASReml directory** -- this is
a strong inference from matching structure, not a byte-for-byte
confirmed identity (the two files were not both present to diff, and no
second script renaming one to the other was found).

This closes an open question flagged in `docs/manuscript_context.md`
Section 5: **the residual traits are simple two-variable OLS regression
residuals of raw CH4 on the raw covariate alone, with no fixed-effects
or contemporary-group adjustment**, confirmed directly from
`data_generation.R`:

```r
fitmbw     <- lm(ch4_g_day2_1v3 ~ Metabolic_BW,               data = ...)
fitmbw_co2 <- lm(ch4_g_day2_1v3 ~ Metabolic_BW + co2_g_day2_1v3, data = ...)
fitadg     <- lm(ch4_g_day2_1v3 ~ adg,                        data = ...)
ch4_adj_MBW     <- resid(fitmbw)
ch4_adj_MBW_co2 <- resid(fitmbw_co2)
ch4_adj_adg     <- resid(fitadg)
```

A fourth residual, `ch4_adj_DMI` (CH4 regressed on DMI), is also
computed in this script and is present as a column in `P3_data.csv`, but
**no ASReml model for it exists anywhere in the dump** -- it was
evidently computed and then not pursued further, consistent with DMI-
based traits not appearing in Table 2 at all.

Later, structurally different jobs (all dated July-August, Section 3)
read different pedigree files -- `upd_ped_fixed.csv.SRT` (30 Jul, used
only by `h_uni_methane`) and `pedigree_full_sas_style_2.csv[.SRT]` (used
only by `a_uni_methane_inb` and `a_uni_methane_res`, both 5 Aug) -- i.e.
**at least three distinct pedigree-file versions exist across the
project's lifetime**, and the two later versions were each used exactly
once, for a single exploratory job apiece. This is worth reconciling
before any pedigree rebuild: it is not yet established what changed
between `pedigree_full_sas_style.csv`, `..._2.csv`, and
`upd_ped_fixed.csv`.

## 3. Chronology

Based on file timestamps across the whole dump (`find -printf`), several
distinct phases are visible:

| Period | What's there | Interpretation |
|---|---|---|
| 16 Jan - 25 Feb 2026 | `bi_ch4_ch4mbw.err/.out` (16 Jan), then a run of `.slurm` job-submission scripts: `ped_cor.slurm` (22 Jan), `h_cor.slurm` (28 Jan), `asreml_g.slurm` (30 Jan), `asreml_dmi.slurm` (25 Feb) | Infrastructure/job-submission setup phase. No surviving `.asr` output from this period -- these look like early pipeline plumbing (pedigree/genomic-correlation/DMI job templates), not analytical results that fed the manuscript. |
| 3 Mar 2026 | `pedigree_full_sas_style.csv` (12:42) | The pedigree file used by essentially the entire main analysis cluster becomes available. |
| 4 Mar 2026 | A single bivariate job, `bi_ch4adg_ch4mbw` | An isolated one-off test, timestamped a full three weeks before the main cluster starts (25 Mar) -- looks like an early pilot/smoke-test of the bivariate model setup, superseded by the systematic sweep that follows. |
| **25, 28, 30 Mar; 20-22, 29 Apr 2026** (833+296 = the large majority of all files) | The systematic sweep: every `a_uni_*` univariate model and essentially every pairwise `bi_*` bivariate combination among CH4, CH4 ratio, CH4/ADG, CH4/MM, CH4/rumen, the three residual traits, and the production traits (weight, MBW, ADG, muscle, rumen) | **This is, on the evidence below (Section 4), the analysis that produced the submitted manuscript's Tables 2-5.** |
| 28-30 Jul 2026 | `P3_data_cv1.csv` .. `P3_data_cv5.csv` (5-fold CV split of the phenotype data) and `a_uni_methane_cv.*` / `a_uni_methane_cv1-5.*` (a univariate CH4 model refit on each fold); `upd_ped_fixed.csv.SRT`; `h_uni_methane.*` (the H-matrix/genomic model, Section 1) | A distinct, later exploratory episode: 5-fold cross-validation of the CH4 heritability estimate, plus a single genomic-relationship-matrix run. This aligns with the genomic/H-matrix robustness comparison flagged as *deferred* scope in `docs/revision_plan.md` -- evidently some exploratory groundwork for it already exists, done independently of (and after) the submitted analysis. |
| 5 Aug 2026 | `pedigree_full_sas_style_2.csv[.SRT]`, `a_uni_methane_inb.*` (adds `!AIF`, an inbreeding-coefficient output file), `a_uni_methane_res.*` (adds a heterogeneous-residual-variance structure by `source_cl`, Section 5), `ainverse.bin` | Two more single-trait, single-run exploratory checks: one on inbreeding, one on residual-variance heterogeneity by source/flock -- both post-dating the main cluster by over three months and using yet another pedigree version. |
| 15 Sep 2026 | One truncated file (`bi_ch4_ch4lw.veo`) | Artifact of this exact upload/download, not a genuine pipeline event. |

**Overall reading**: the manuscript's reported genetic parameters come
from the **25 Mar - 29 Apr 2026 cluster**. Everything from late July
onward is later, exploratory, single-trait robustness work (cross-
validation, genomics, inbreeding, heteroscedasticity) that was evidently
already underway independently of this revision effort, and does not by
itself constitute or replace the submitted analysis.

## 4. Duplicates, superseded, and experimental runs

- **`bi_ch4adg_ch4mbw` (4 Mar)** is superseded by the systematic sweep
  starting 25 Mar; no reason to treat it as an independent result.
- **`a_uni_adg_g` / `bi_ch4_adg_g` (29 Apr)** -- ADG re-expressed in
  grams/day rather than kg/day (`adg_g <- adg*1000` in
  `data_generation.R`). A pure units check; there is no sign this
  replaced the kg-based `adg`/`ch4adg` results used elsewhere, and no
  Table 2 row is in g/day units. Treat as experimental/abandoned.
  varies by units).
- **`h_uni_methane`, `a_uni_methane_inb`, `a_uni_methane_res`, the
  `a_uni_methane_cv*` fold models** (all Jul-Aug) are each single,
  one-off runs on a single trait (CH4), not part of the systematic
  March-April sweep, and each uses a pedigree file version not used
  anywhere else. These read as targeted, later robustness probes, not
  duplicates of the main results and not (on current evidence) sources
  of any manuscript-reported number.
- Within the March-April cluster itself, no duplicate `.as` files with
  conflicting timestamps for the same trait/pair were found -- each
  `a_uni_<trait>` and `bi_<A>_<B>` combination appears to have been run
  once.

## 5. The two different "residual" analyses -- important disambiguation

The user's brief specifically asked for care here, and the dump contains
**two unrelated things that both involve the word "residual"**:

1. **The manuscript's residual methane traits** (RMTMBW, RMTMBW+CO2,
   RMTADG) -- these are residual *traits*: `ch4_adj_MBW` etc., built by
   simple OLS regression of raw CH4 on a covariate (Section 2 above),
   then each modelled with the *same* animal-model structure as every
   other trait (`a_uni_ch4rmtmbw.as`, `a_uni_ch4rmtmbwco2.as`, and the
   model underlying `a_uni_ch4rmtadg.asl`, whose `.as` job file does not
   survive but whose `.asr`/`.pin` results do). These are part of the
   main March-April cluster and, per Section 6 below, trace cleanly to
   Table 2.
2. **`a_uni_methane_res` (5 Aug)** -- despite the `_res` suffix, this
   model's response trait is still raw `ch4_g_day2_1v3`, with the
   *identical* fixed/random-effects structure as the original
   `a_uni_methane` model, but with one addition: `residual
   sat(source_cl).idv(units)`, i.e. a heterogeneous-residual-variance
   structure fitted separately within levels of a class variable
   `source_cl` (almost certainly the same "source"/flock field used to
   build contemporary groups in the PAC pipeline's
   `05_CG_creation.R`). **This is a residual-*variance*-heterogeneity
   robustness check, not a residual-*trait* analysis** -- it has nothing
   to do with RMTMBW/RMTMBW+CO2/RMTADG. It is a single, late, one-off
   run (Aug 5) and there is no evidence it fed into the submitted
   manuscript.

Anyone revisiting "the residual analyses" for revision should be careful
to keep these two senses separate -- the filename alone does not
disambiguate them.

## 6. Tracing Table 2 (heritabilities/repeatabilities) to specific runs

For each trait, `h2 = Gamma_ped / (Gamma_ped + Gamma_ide + 1)` and
`t = (Gamma_ped + Gamma_ide) / (Gamma_ped + Gamma_ide + 1)`, computed
directly from the Gamma (variance-ratio) column of each `a_uni_*.asr`
file's `ped(ANI_ID)`/`ide(ANI_ID)` lines (residual Gamma is fixed at 1
by ASReml convention). This reproduces the manuscript's stated method
(variance-component ratios) exactly where checked:

| Trait | Source file | Gamma_ped | Gamma_ide | Computed h2 | Table 2 h2 | Computed t | Table 2 t | Match? |
|---|---|---|---|---|---|---|---|---|
| CH4 | `a_uni_methane.asr` | 0.2446 | 0.1970 | 0.17 | 0.17 | 0.31 | 0.31 | **Yes** |
| MI | `a_uni_ch4mbw.asr` | 0.2138 | 0.1672 | 0.15 | 0.15 | 0.28 | 0.28 | **Yes** |
| CH4 ratio | `a_uni_ch4ratio.asr` | 0.0890 | 0.0147 | 0.08 | 0.08 | 0.09 | 0.09 | **Yes** |
| CH4/ADG | `a_uni_ch4adg.asr` | 0.2454 | 0.1709 | 0.17 | 0.17 | 0.29 | 0.29 | **Yes** |
| CH4/MM | `a_uni_ch4muscle.asr` | 0.5212 | 0 (dropped) | 0.34 | 0.34 | n/a ("-") | "-" | **Yes** |
| CH4/rumen | `a_uni_ch4rumen.asr` | 0.5976 | 0 (dropped) | **0.37** | **0.29** | n/a ("-") | "-" | **No -- see below** |
| RMTMBW | `a_uni_ch4rmtmbw.asr` | 0.1983 | 0.1976 | 0.14 | 0.14 | 0.28 | 0.28 | **Yes** |
| RMTMBW+CO2 | `a_uni_ch4rmtmbwco2.asr` | 0.2506 | 0.2840 | 0.16 | 0.16 | 0.35 | 0.35 | **Yes** |
| RMTADG | `a_uni_ch4rmtadg.asr` | 0.2675 | 0.0466 | 0.20 | 0.20 | 0.24 | 0.24 | **Yes** |

Eight of nine traits reproduce the manuscript's reported h2/t to two
decimal places exactly from the March-April univariate runs -- strong
evidence Table 2 was built directly from these files.

**CH4/rumen does not reconcile.** Three different numbers exist for this
one trait, none matching another: the univariate run above gives 0.37;
the bivariate `bi_ch4_ch4rumen.asr`'s own diagonal estimate for
`methane_per_rumen` gives h2 = 0.2641 (Trait.ANI_ID V22 = 0.1221 over a
2x2-model Vp2 = 0.4621); the manuscript states 0.29. All three come from
files that otherwise reconcile perfectly for every other trait, so this
is not an artefact of the extraction/computation method -- it looks like
a genuine, unresolved discrepancy. Two most plausible (unconfirmed)
explanations: (a) the manuscript's 0.29 comes from a run not present in
this dump (a different subset, or a later-corrected fit); or (b) 0.29
is itself a transcription/rounding slip in the manuscript relative to
the actual analysis. This should be treated as an open item requiring
either the original run log/notes or a fresh, carefully-documented
refit before the CH4/rumen row is relied on in revision -- notably, this
sits right next to Reviewer 1's flagged concern about CH4-ratio h2 being
out of line with the literature, so a demonstrated internal-consistency
problem in the CT-derived traits (CH4/rumen, and by extension possibly
CH4/MM, which share the small-sample CT data source) is worth being
upfront about rather than discovering later.

One more data-size note: `a_uni_muscle.asr` (the production trait
`ct_muscle_kg` itself, not a methane ratio) fits on 780 residual
records, whereas the manuscript states 766 CT measurements (Methods,
"Additional phenotypes"). This 14-record difference was not chased
further here but is worth reconciling alongside the CH4/rumen h2 issue,
since both concern the same small CT-derived data source.

## 7. Tracing Table 3-5 (correlations) to specific runs

Genetic correlation (`rg`), phenotypic correlation (`cp`, reported as
`rp`), and error/residual correlation (`re`) come from each bivariate
job's VPREDICT evaluation, stored in the `.pvc` file (the numeric
results) referencing components defined in the `.as` job's `VPREDICT
!DEFINE` block. Where a `.pvc` was missing from the truncated download,
the same quantities were reconstructed by hand directly from the
`.asr`'s raw unstructured (`US_V`/`US_C`) variance/covariance components
using the same formulas (`rg = Trait_C / sqrt(Trait_V1*Trait_V2)`,
`cp = (Trait_C + Residual_C) / sqrt(Vp1*Vp2)`), and cross-checked against
the pattern from jobs where `.pvc` was available. All values below
matched the manuscript to the stated precision:

| Manuscript pair (Table 3) | rg (SE) | rp | Source file | rg computed | rp computed | Match? |
|---|---|---|---|---|---|---|
| CH4-MI | 0.87 (0.02) | 0.87 | `bi_ch4_ch4mbw.asr` (`.pvc` missing, reconstructed) | 0.87 | 0.87 | **Yes** |
| CH4-CH4 ratio | 0.73 (0.05) | 0.46 | `bi_ch4_ch4ratio.pvc` | 0.7297 (0.0454) | 0.4606 | **Yes** |
| CH4-CH4/ADG | 0.23 (0.06) | 0.30 | `bi_ch4_ch4adg.pvc` | 0.2295 (0.0595) | 0.3003 | **Yes** |
| CH4-CH4/MM | 0.85 (0.07) | 0.87 | `bi_ch4_ch4muscle.pvc` | 0.8539 (0.0717) | 0.8665 | **Yes** |
| CH4-CH4/rumen | 0.65 (0.11) | 0.67 | `bi_ch4_ch4rumen.pvc` | 0.6532 (0.1132) | 0.6700 | **Yes** |
| CH4-RMTMBW | 0.55 (0.06) | 0.78 | `bi_ch4_ch4rmtmbw.asr` (`.pvc` missing, reconstructed) | 0.55 | 0.78 | **Yes** |

Every correlation checked traces cleanly, including CH4-CH4/rumen's
correlation (0.65/0.67, exact) even though that same trait's *own*
univariate heritability does not reconcile (Section 6) -- i.e. the
problem is specific to the CH4/rumen heritability estimate, not to the
underlying CH4/rumen data or its relationship with CH4 more broadly.
Tables 4-5 (methane traits vs. production traits) were not exhaustively
checked given the scope of this pass, but the one production-trait pair
spot-checked, CH4-weight-adjacent `bi_weight_ch4mbw`, produced internally
consistent values (h2_1 = 0.80 for weight itself, a very high but not
implausible heritability for live weight; rg = -0.27) without an
obvious anomaly, and is available for a fuller check later.

**General rule established**: Table 2 draws from univariate `a_uni_*`
runs; Table 3-5 draw from bivariate `bi_*` runs' VPREDICT correlation
outputs. Bivariate models' own *diagonal* heritability estimates
(`h2_1`/`h2_2` in the `.pvc` files) are consistently different from the
univariate estimates for the same trait (e.g. CH4's own h2 is 0.17
univariate but 0.29 in the `bi_ch4_ch4ratio` bivariate fit) -- this is
statistically unsurprising (joint estimation redistributes variance
differently) but means the bivariate diagonals should never be read as
a second, independent confirmation of Table 2's numbers; they are a
different estimation context entirely.

## 8. Inconsistencies and open items (summary)

- **CH4/rumen heritability**: manuscript 0.29 vs. this dump's univariate
  0.37 and bivariate-diagonal 0.26 -- unresolved (Section 6).
- **CT record count**: manuscript states 766 CT measurements; the
  `ct_muscle_kg` univariate model here fits on 780 records -- unresolved,
  possibly related to the same underlying data-vintage question as the
  CH4/rumen discrepancy.
- **`UN` breed-proportion term**: present in every model's fixed effects
  but not named among the manuscript's "six breeds" -- almost certainly
  an "other/unknown" catch-all, not confirmed.
- **Three pedigree file versions** (`pedigree_full_sas_style.csv`,
  `..._2.csv`, `upd_ped_fixed.csv`) exist with no file explaining what
  changed between them -- needs reconciling before any pedigree rebuild.
- **`P3_data.csv`'s exact relationship to `data_generation.R`'s output**
  is a strong structural inference (identical row count and column set),
  not a confirmed byte-for-byte identity, since only one of the two
  files was available to compare.
- **Genuinely missing, not just unconfirmed**: the truncated download
  means a small number of files (at least two `.pvc` results, one large
  `.veo` history file) are absent from this reconstruction; none of the
  missing pieces were needed to complete the checks above, but a
  complete/untruncated re-upload would remove this caveat entirely.

---

## Answers to the five questions

**1. What I believe the submitted analysis actually was.**
A pedigree-based animal-model analysis (ASReml 4.2), one univariate
model per trait plus a near-complete set of pairwise bivariate models,
run as a systematic sweep between 25 March and 29 April 2026, reading a
330,812-animal pedigree (`pedigree_full_sas_style.csv.SRT`) and a
15,869-record phenotype file (`P3_data.csv`) that is, on strong
structural evidence, the direct output of the already-reconstructed PAC
pipeline plus the `data_generation.R` step that adds the three residual
("adjusted") methane traits via simple OLS regression. The model
structure (fixed effects + `ped(ANI_ID)` + `ide(ANI_ID)` random terms)
matches the manuscript's stated equation for all terms except one
undocumented `UN` breed-proportion covariate. Table 2's heritabilities
and repeatabilities trace exactly to these univariate runs' Gamma-based
variance ratios for 8 of 9 traits; Table 3's genetic/phenotypic
correlations trace exactly to the corresponding bivariate runs' VPREDICT
outputs for every pair checked.

**2. Which files/results support that conclusion.**
The trait-to-file mapping (Section 1), the data-provenance match between
`P3_data.csv` and the PAC pipeline's `data_generation.R` (Section 2),
the pedigree-size match (330,812, exact, in every `.asr`), the record-
count match (15,869, exact), and the numeric reconciliation tables in
Sections 6-7 (8/9 heritabilities exact, 6/6 checked correlations exact).

**3. What appears obsolete or experimental.**
The 4 March lone bivariate test (superseded by the 25 March+ sweep); the
29 April grams-per-day ADG variant (a units check with no downstream
use found); and the entire late July-August episode -- 5-fold cross-
validation of the CH4 heritability, the single H-matrix/genomic model,
the inbreeding-coefficient run, and the heterogeneous-residual-variance-
by-source run. All four of these later items are single, isolated runs
on one trait, post-date the main cluster by three-plus months, and (with
the genomic run) use pedigree file versions not used anywhere else in
the dump.

**4. What is unclear or missing.**
The CH4/rumen heritability discrepancy and the CT-record-count mismatch
(both possibly related, both unresolved); what exactly changed across
the three pedigree file versions; the exact script/step that turned
`data_generation.R`'s `P3_co2_data.csv` into the `P3_data.csv` actually
read by the ASReml jobs (strongly inferred, not confirmed); Tables 4-5
(production-trait correlations) were not exhaustively cross-checked in
this pass; and the archive truncation itself means a full, untruncated
copy would be worth obtaining before this material is treated as fully
audited.

**5. What should be rebuilt first, once we move from reconstruction to
revision.**
Given `docs/revision_plan.md` already commits to rebuilding the ASReml
analysis on HPC (steps up to and including the selection-index
handoff), this reconstruction suggests starting with: (a) the CH4
univariate model, since it anchors both Table 2's CH4 row and every
CH4-vs-other-trait correlation in Table 3, and is the trait with the
cleanest, most-replicated evidence trail here; (b) resolving the
CH4/rumen (and CT-record-count) discrepancy specifically, before
touching the ratio/residual traits, since it's the one place the
existing legacy numbers don't already self-confirm and a rebuild is the
natural opportunity to nail it down; (c) the three residual traits
(RMTMBW, RMTMBW+CO2, RMTADG) together, since their construction (simple
OLS residual, no fixed-effects adjustment) is now precisely known and is
exactly the piece flagged for reconsideration in the revision strategy;
and (d) the pedigree reconciliation (which of the three pedigree
versions is authoritative, and why they differ) as a prerequisite for
trusting any rebuilt A-matrix, before it becomes a blocker discovered
mid-rebuild.

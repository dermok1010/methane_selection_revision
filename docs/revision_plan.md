# Revision strategy: "Genetic Parameters and Selection Responses for
# Alternative Methane Trait Definitions in Pasture-Based Sheep" (GSEV-D-26-00126)

This is a living document recording the revision strategy as currently
agreed, not a fixed spec. It should be updated as the rebuild proceeds and
decisions firm up or change. See `docs/manuscript_context.md` for the
detailed read of the submitted manuscript itself, and
`reviews/GSEV-D-26-00126_reviewer_comments.txt` for the reviewer comments
verbatim.

Status as of this document's creation: reviewer comments read; no
manuscript editing, no data received, no analysis started.

## Decision log

- **2026-09-15**: User confirmed agreement with Sections 1-5 as written,
  including the pushback in Section 4. On the scope/sequencing question
  specifically: **committed scope for now is steps 1-9 of Section 5**
  (PAC pipeline through the reduced selection-index demonstration). The
  H-matrix/genomic robustness comparison (step 10) stays explicitly
  deferred -- whether to attempt it, and whether it goes in the paper at
  all, will be decided only once steps 1-9 are solid, not before.
- **2026-09-15 (later same day)**: PAC_data_pipeline ingested and
  partially sanity-checked. `08_outlier_removal.R` and
  `09_trait_derivation.R` reran byte-identical to their previously
  captured outputs; 08's QC numbers exactly match the manuscript's
  Methods (511 removed, 3.09%; 15,869 records / 8,185 animals). Scripts
  01-07, 10, 11, and `data_generation.R` need external raw inputs not yet
  provided (full list in `docs/manuscript_context.md`). Confirmed this
  pipeline's `PAC_data_covariates_QC_NA_with_traits.csv` is the exact file
  already used as `birth_year_source` in the mix99 genomic-evaluation
  work; `..._plus_dam_parity.csv` is very likely (not yet confirmed) the
  ancestor of that work's `phenotype_source`. GitHub
  (`dermok1010/PAC_data_pipeline`) brought up to date with the HPC
  working-tree state (pushed `8cb842d`), per explicit authorization, after
  the above sanity check.
- **2026-09-15 (later still)**: full PAC pipeline (scripts 01-11) run
  end-to-end after the 9 missing external raw files were supplied;
  reproduces the manuscript's QC numbers exactly and matches the legacy
  captured outputs cell-for-cell bar two documented, non-impacting
  findings (see `docs/manuscript_context.md`). Promoted to canonical on
  the VM and GitHub (`dermok1010/PAC_data_pipeline@3832743`), HPC
  original left untouched, per explicit instruction. Legacy ASReml
  material (`gs://dermot-phd-backup/asreml_legacy_no_sln_2026-09-15.tar.gz`)
  reconstructed read-only into `docs/asreml_legacy_map.md`: identifies
  the 25 Mar-29 Apr 2026 run cluster as the source of the submitted
  Tables 2-5 (8/9 heritabilities and 6/6 spot-checked correlations
  reproduce exactly), resolves the residual-trait construction question
  (simple OLS residual, no fixed-effects adjustment), and flags one
  unresolved discrepancy (CH4/rumen heritability) plus several open
  items. A new validated pedigree (`analysis/revision/pedigree/`,
  36,449 animals, deliberately smaller than the manuscript's 330,812
  since reconciling the three legacy pedigree versions was explicitly
  out of scope for now) and a config-driven ASReml automation pipeline
  (`analysis/revision/asreml_pipeline/`) were then built to replace the
  legacy hand-edited `.as` files -- generator, Slurm batch runner with
  convergence detection/`!CONTINUE` retries, and a results parser that
  independently cross-checks VPREDICT output rather than trusting it
  alone. The small representative validation set (CH4, CH4 ratio, their
  pair) was checked by replaying real legacy ASReml output through the
  new parser and reproduces the manuscript exactly; **not yet run on
  HPC with real ASReml** -- that is the next step before generating the
  full submitted-style sweep. Full detail and flagged items in
  `analysis/revision/asreml_pipeline/README.md`.
- **2026-09-15 (later still)**: `--set=full` ran successfully on HPC
  (results not yet pulled/parsed back to the VM). Started step 7 (ratio
  traits derived from component-trait (co)variances): added
  `--set=components` to `01_generate_models.R`, generating six new
  bivariate CH4 x raw-denominator models (CO2, MBW, ADG, muscle, rumen,
  liveweight -- the actual measured variables behind each ratio trait,
  reusing legacy ASReml starting values automatically wherever a real
  legacy pair exists), and a new `04_derive_ratio_from_components.R` that
  derives each ratio trait's h2 and rg-with-CH4 via first-order Taylor
  linearisation of the ratio -- the identical delta-method gradient
  already used for real in the upstream `Methane_Selection_Index_Analysis`
  repo (commit `fb1f0a2`), not a new derivation. Verified against analytic
  edge cases; not yet run on HPC. See
  `analysis/revision/asreml_pipeline/README.md` for full detail.
- **2026-09-15 (later still)**: Redesigned the component-trait analysis
  per Julius van der Werf's framework (via the user): the initial
  "CH4 vs each ratio's own denominator" design (6 pairs) can't reproduce
  Table 3's cross-pairs among all nine derived traits (e.g. RMTMBW-RMTADG,
  CH4/MM-RMTADG), which need cross-component covariances a star design
  lacks. Now fits the 7 underlying component traits (CH4, MBW, liveweight,
  ADG, CO2, muscle, rumen) and their full 21-pair (co)variance structure,
  deriving every ratio/residual trait's h2 and every pairwise correlation
  from one assembled 7x7 G/P by matrix algebra (linear traits: exact
  c'Gc; ratio traits: first-order Taylor gradient; any two derived
  traits: c1'Gc2). A genuine 7-trait multivariate model is confirmed
  syntactically supported by ASReml 4.2 and preferred if it converges,
  but deferred until the 21-pair bivariate results exist to derive its
  starting values from -- the manual itself flags multivariate starting
  values as a known difficulty. Trial (7 uni + 3 representative pairs)
  ready to run on HPC; not yet run. Full detail in
  `analysis/revision/asreml_pipeline/README.md`.
- **2026-09-15 (later still)**: User narrowed the scope again: this stage
  is heritabilities only, not a selection index or complete covariance
  structure -- so only the bivariate pairs each composite trait actually
  needs are fit (7, not 21): the 6 "CH4 vs X" pairs plus `mbw-co2` (needed
  solely for RMTMBW+CO2's 3-component block, since that's the one
  composite trait built from three components rather than two).
  `04_derive_ratio_from_components.R` rewritten accordingly: per composite
  trait, builds just the small 2x2 (or 3x3) G/P block it needs and reports
  h2 alongside every component parameter used, rather than assembling a
  full 7x7 or any cross-derived-trait correlation matrix. Pairwise
  correlations among the derived traits and any multivariate/selection-
  index work are explicitly deferred to a later, separate task. Trial (7
  uni + 3 pairs: methane-mbw, mbw-co2, methane-rumen) ready to run; not
  yet run on HPC.
- **2026-09-15/16**: the narrowed component-trial set (7 univariate + 7
  bivariate pairs) actually run on HPC. All 16 univariate models
  CONVERGED with clean cross-checks. Four of the bivariate pairs --
  `bi_methane_co2`, `bi_methane_adg`, `bi_methane_rumen`,
  `bi_mbw_co2` -- failed across 3 submission attempts with "Iteration
  aborted because of singularities in AI matrix" and implausible
  boundary h2 estimates; these are exactly the four pairs with no legacy
  bivariate starting values (relying on ASReml's classic-syntax
  auto-init). Separately, a resubmission-safety gap was caught and
  cancelled on this same first real HPC attempt: `run/` accumulates
  staged jobs from every `--set=` ever generated, so a no-argument
  `submit_batch.sh` resubmitted the already-completed 55-model
  `--set=full` sweep alongside the new component-trial jobs on the
  capacity-shared ASReml license. Fixed by having `submit_batch.sh` skip
  any candidate job already classified CONVERGED by default
  (`ASREML_FORCE_RERUN=1` to opt back into the old behaviour).
- **2026-09-17**: root cause of the 4 AI-matrix-singularity failures
  diagnosed against the ASReml 4.2 functional specification (Section
  7.7.5): Release 4's improved phenotypic-variance-based
  auto-initialisation applies only to functional-syntax (`us()`/`idv()`)
  terms, not the classic `Trait.ped(ANI_ID)` term this pipeline
  otherwise uses for consistency with the legacy `.as` files -- and
  CO2's genetic variance is ~1000-19000x the other traits' on this raw
  scale, a poor-scaling combination the classic auto-init can't handle.
  Fixed for these 4 pairs only by switching to
  `us(Trait !INIT v11 0 v22 !GP).ped(ANI_ID)`, with `v11`/`v22` taken
  from each trait's own converged univariate `ped(ANI_ID)` Sigma (not
  invented values) -- the same diagonal-from-univariate-analyses
  strategy the manual's own worked multivariate example uses (Section
  16.11). Resubmitted and converged cleanly on HPC. This then exposed a
  parser blind spot: functional-syntax output prints the genetic term's
  data rows as bare `Trait US_V/C ...` with the `ANI_ID` identity only
  on one preceding "N effects" header row, unlike classic syntax (which
  repeats `Trait.ANI_ID` on every data row) -- so `get_sigma`'s
  name-based match silently returned `NA` for these 4 pairs' independent
  Model_Term cross-check (`results/bivariate_summary.csv` showed
  `check_agree_rg`/`check_agree_rp` as `NA`, not a real disagreement).
  Hand-verified all 4 pairs' h2s against their raw `.asr` Model_Term
  tables first (matched the VPREDICT-derived numbers exactly), then
  fixed the actual bug in `03_parse_results.R` (track which "N effects"
  block header a data row falls under, match against that too), verified
  against a real functional-syntax fixture and an existing classic-syntax
  legacy `.asr` (no regression). `results/` re-parsed with the fix:
  `results/derived_h2.csv` now reports real, HPC-derived heritabilities
  for all 9 composite traits (revision plan step 7), not trial values.
  **Two things intentionally left open rather than folded into this
  entry:** (1) the full `--set=full` sweep (step 3) currently shows 29/52
  bivariate models CONVERGED and 23 still `UNKNOWN` -- not yet triaged
  as "not run" vs. "ran and failed," and needed before Tables 2-5 can be
  called reproduced; (2) the rebuilt univariate CH4-ratio h2 (0.1016,
  SE 0.0125) is closer to the manuscript's submitted 0.08(0.02) than to
  Jonker et al.'s 0.17-0.25, so the rebuild does not on its own resolve
  Reviewer 1's headline discrepancy -- the dedicated CH4-ratio scrutiny
  this plan's step 3 calls for has not yet been done.
- **2026-09-17 (later still)**: user supplied a detailed, workstream-by-
  workstream action plan (`reviewer_revision_detailed_action_plan.docx`,
  converted to text for review) covering all non-selection-index reviewer
  comments. Reviewed against the pipeline's actual state: the plan's
  explicit correctness requirement for the CH4-ratio derivative ("do not
  treat CH4+CO2 as an independent denominator") was already satisfied --
  `04_derive_ratio_from_components.R`'s `ratio2_result_ch4ratio()` uses
  the direct two-variable gradient wrt (CH4,CO2), not a naive one-variable
  ratio. Confirmed with the user: the existing 36,449-animal pedigree
  (phenotyped animals + recursively traced ancestors) is frozen as final
  for the plan's step 1 -- no further reconciliation against the
  manuscript's 330,812-animal pedigree. Real gaps identified: no SEs on
  any component-derived h2 (the plan's A1 requires delta-method SEs); no
  CH4-MBW-CO2 trivariate model attempted; A2 diagnostics bundle,
  A3 stage-heterogeneity sensitivity, and the literature-comparison table
  not started; CH4/rumen's historical discrepancy still unresolved; the
  comparison table can't be built until the direct-fit `--set=full` sweep
  is triaged (still 29/52 CONVERGED).
- **2026-09-17 (later still)**: implemented delta-method SEs for the 6 of
  7 component-set bivariate pairs that involve exactly two traits (every
  "methane, X" pair) -- `01_generate_models.R` now appends extra VPREDICT
  lines to each of those pairs' `.as`/`.pin` files, computing each
  composite trait's VA/VP as a chain of single-coefficient `P` scalings
  (`P name idx * coefficient`) plus addition of already-named components
  -- the two VPREDICT grammar forms directly confirmed in
  `reference/ASReml-4.2-Functional-Specification.pdf` Section 13.2.1, not
  its more compact (but not fully confirmed for this pipeline's purposes)
  multi-coefficient-per-line form. This lets ASReml itself compute the
  composite h2's SE from that bivariate model's own sampling covariance
  matrix (`.vvp`), rather than approximating it in R across two separate
  model fits. Coefficients (a1^2, 2*a1*a2, a2^2 for ratio traits; 1, -2b,
  b^2 for linear/residual traits) are precomputed in R using the
  identical formulas already in `04_derive_ratio_from_components.R`, so
  ASReml's point estimate should match `derived_h2.csv` exactly -- a
  built-in cross-check. Regenerated and locally sanity-checked (no
  scientific notation left in any coefficient, given ASReml's
  fixed-format Fortran-style parser; max generated line length 92 chars).
  **RMTMBW+CO2 is explicitly NOT covered** -- it needs all three of
  (CH4,MBW), (CH4,CO2) and (MBW,CO2) simultaneously, and a single
  bivariate model's `.vvp` can't give a joint SE across three separate
  fits; its SE stays deferred until a CH4-MBW-CO2 trivariate model is
  fit, per the user's own plan ("if feasible and stable"). **Not yet run
  on HPC** -- since the 6 underlying bivariate models already CONVERGED
  (2026-09-17, see above), this only needs the cheap `.pin`
  post-processing step (`asreml -P<jobname> <jobname>.pin`, reprocessing
  the existing `.rsv`) rather than a fresh REML run, but per this VM's
  standing rule HPC submission still needs explicit user confirmation of
  the batch before dispatch.

---

## 1. Reviewers' main substantive concerns (interpretation)

### Reviewer 1 -- three stated reasons for major revision

**(a) A genetic parameter estimate that conflicts with prior literature,
uncommented.** CH4 ratio: h²=0.08(0.02), t=0.09(0.01) in this manuscript,
vs. Jonker et al. (2018) reporting h²=0.17-0.25 and t=0.27-0.43 across
three lamb/ewe x respiration-chamber/PAC combinations. This is Reviewer
1's headline concern and the one they explicitly say "made me suspect
there is some underlying issue with the analysis itself." They back this
suspicion with a list of secondary observations that read as symptoms of
insufficient rigor rather than independent complaints:
  - `CH4/MBW` is defined once then silently renamed `MI` for the rest of
    the paper.
  - Units for `CH4 ratio` (and CO2 generally) are never stated, and no
    table of means/units exists for CO2 at all -- with values this small,
    a rounding/unit error is plausible.
  - No formal tabulation of fixed-effect/covariate significance or
    variance explained (e.g. how much variance breed proportion
    accounts for).
  - No reported genetic connectedness/confounding diagnostics.
  - The model equation as printed is missing "+ e" even though the text
    describes a residual term -- **this exact discrepancy was
    independently found during the initial manuscript read** (see
    `docs/manuscript_context.md` §6) via a second-pass extraction that
    recovered the embedded equation object directly; it is very likely a
    write-up/typesetting slip rather than evidence the model was actually
    misspecified, but it is real and needs fixing regardless.
  - PAC contemporary groups pooled animals of very different ages/sizes
    (and therefore very different absolute liveweight and gas-production
    scale) with no discussion of variance-scaling/normalisation across
    groups.
  - Overall ask: re-examine the analysis, and add literature comparison
    plus supplementary diagnostic detail.

**(b) Trait/index justification vs. a real farm economic model.**
Ratio/residual methane traits are, in Reviewer 1's reading, implicitly
acting as proxies for feed intake (which was never measured). The
economically relevant question is methane and production *per unit feed
intake*. More importantly: **~70% of a ewe flock's feed goes to ewe
maintenance and reproduction, only ~30% to lamb carcass production** --
so fecundity, ewe longevity, and lamb survival plausibly matter more to
a real bio-economic outcome than liveweight or ADG, and none of that is
in the paper's trait set.

**(c) Smith-Hazel/selection-index oversimplification.** "Progress per
generation" language is used throughout but is actually response at
selection intensity i=1 -- reviewer wants this made explicit everywhere,
not just derivable from one line. Real sheep breeding operates at
i approx 1.7, generation interval approx 2.8 years, with partial trait
measurement, sex differences, and variable genomic/EBV accuracy across
animals -- none of which is acknowledged, even as a caveat. Smith-Hazel
theory itself is a first-order approximation whose limitations under
selection (changing genetic (co)variances over generations) are
increasingly well documented -- reviewer explicitly requests a citation
to Cuyabano et al. (2025, bioRxiv, "Trajectories of Genetic Correlations
in Populations under Selection") and an acknowledgement of this
limitation.

### Reviewer 2 -- more general, plus a minor-comments list

- Wants deeper **biological interpretation** of the range of methane
  phenotypes, not just statistical description.
- Asks **why CO2** was chosen as a covariate for `RMTMBW+CO2`
  specifically, and suggests analysing CO2 **as its own trait** given it
  was already measured -- for insight into energy balance/physiology.
- PAC method: pros/cons for this specific study, whether it captures
  "real" emissions, and how the generally low number of repeated records
  per animal was handled.
- Wants the Discussion to compare findings against other studies more
  directly (similar? surprising?) and to address **transferability**
  beyond an Irish grass-based system.
- Asks whether **splitting by physiological stage** (growing vs. adult)
  was considered, given known physiological differences in methane
  between stages.
- Minor comments include several genuinely substantive points despite
  being filed as "minor": pedigree completeness/sire count not reported;
  the permanent environmental effect is fit despite only ~25% of animals
  having repeats, with no discussion of alternatives; heritability/
  repeatability calculation formulas not given in Methods; and -- **line
  499**: explicitly notes that a *phenotypic* residual (CH4 regressed on
  weight) does not make the resulting trait *genetically* independent of
  weight. This is the same point already identified independently in
  `docs/manuscript_context.md` and in the user's own framing of the
  residual-trait reinterpretation below -- reviewer and author have
  converged on the same concern from different directions.

### Where the two reviewers overlap
Both raise: comparison against prior literature (R1 as a suspected-error
flag, R2 as a general Discussion request -- these are really the *same*
underlying ask at different levels of urgency); physiological-stage
handling (R1 via the heteroscedasticity/contemporary-group-scaling angle,
R2 via a direct stage-stratification question); and the
genetic-independence-of-residuals point (R2 line 499, and independently
the author's own strategy note below).

---

## 2. Does the proposed strategy address these concerns?

**Mostly yes, with real gaps.** Point-by-point against Section 1:

| Reviewer concern | Addressed by current strategy? |
|---|---|
| (a) CH4-ratio vs. Jonker et al. discrepancy | **Not explicitly.** The PAC-pipeline rebuild will reproduce the numbers, but nothing in the stated plan singles out CH4 ratio for special scrutiny or commits to a systematic literature-comparison table. This is the reviewers' most serious "is this actually wrong" concern and needs to be a named checkpoint, not something expected to fall out incidentally. |
| MI/CH4-MBW naming, missing "+e", units | Naturally fixed by careful manuscript rewriting once the pipeline is documented; low risk, just needs to not be forgotten. |
| Fixed-effect significance/variance-explained tabulation | **Not currently planned.** Needs to be an explicit diagnostic deliverable. |
| Connectedness/confounding | **Not currently planned.** Same -- needs to be explicit. |
| CG heteroscedasticity across ages/sizes | **Not currently planned as a first-class item** -- "physiological-stage differences" is on the tracked-issues list, but this is really the same concern as R2's stage-stratification question and deserves elevation, not just tracking. |
| (b) Feed-intake proxy / ewe-maintenance-cost critique | **Indirectly, by scope reduction.** Narrowing the selection-index section to a small, explicitly-limited demonstration largely defuses the "you're missing 70% of the economics" critique, because the paper would no longer claim to represent a real breeding objective. This needs to be stated explicitly and early in the paper, not just reflected in a smaller results section, or it will read as dodging the point rather than addressing it. |
| (c) i=1 clarity, real intensity/generation interval, partial measurement/genomics caveats, Cuyabano et al. citation | **Not yet in the stated plan.** These are cheap (a paragraph + a citation) and should be added regardless of how much the index section itself shrinks. |
| Biological interpretation depth (R2) | Not yet planned as a discrete task -- reasonable to leave until final rebuilt numbers exist, but should not be forgotten. |
| Why CO2 as covariate / CO2 as its own trait (R2) | **Not currently planned.** Cheap to add given CO2 is already QC'd in the existing pipeline; directly answers R2. |
| PAC pros/cons, sparse repeats (R2) | Partly a Discussion-writing task; partly connects to the RMTADG permanent-environmental-variance precision concern already flagged in `docs/manuscript_context.md` (sigma_pe = 0.54, SE 0.50) -- worth handling together. |
| Literature comparison / transferability (R2) | Same as (a) above -- should be unified into one systematic comparison, not two separate small fixes. |
| Stage-splitting (R2) | See CG heteroscedasticity above -- same underlying issue from two reviewers. |
| Pedigree completeness (R2 minor) | Directly served by the planned pedigree-pipeline rebuild -- just needs to be reported in the revised text. |
| PE effect with sparse repeats (R2 minor) | Not currently planned as an explicit check; connects to the RMTADG precision concern. |
| Residual != genetically independent (R2 line 499) | **Yes, directly.** This is exactly the point in the user's own residual-trait reinterpretation. |
| Ratio/residual reinterpretation, residual transparency argument | **Yes**, this is the strategy's most developed piece and is scientifically sound (see caveat in Section 4). |
| Smith-Hazel-is-an-approximation critique | Addressed by scope reduction, but the specific citation/caveat request is not yet explicitly slotted in. |

---

## 3. What the user's framing may be overlooking

1. **The CH4-ratio discrepancy needs to be a named, early rebuild
   checkpoint**, not an incidental output of reproducing everything else.
   If the rebuild reproduces the same low h²/t, that's a genuinely useful
   result (rules out a code bug, and motivates a real biological/
   measurement-based explanation for the Discussion -- e.g. this ratio's
   very small genetic SD, CVa=0.24%, the lowest of any trait examined, is
   itself informative). If it doesn't reproduce, that is exactly the kind
   of silently-wrong result this project's own working principles
   (`CLAUDE.md`) are designed to catch early rather than late.
2. **Connectedness/confounding diagnostics and formal fixed-effect
   variance-explained reporting** are explicit, specific reviewer
   requests with no current home in the plan. These belong in
   `analysis/diagnostics/` alongside the reproduction work, not treated
   as an afterthought for the response letter.
3. **Contemporary-group heteroscedasticity across physiological stages**
   (R1) and **stage-stratification** (R2) are the same underlying
   question asked two different ways, and it is a real statistical
   question, not just a writing gap: if lambs, hoggets, and mature ewes
   differ substantially in absolute methane/liveweight scale, pooling
   them under a single residual/genetic variance structure with only a
   fixed contemporary-group mean adjustment could distort heritability
   estimates. This deserves an explicit sensitivity analysis (e.g. a
   heterogeneous-residual-variance model, or stage-stratified univariate
   reruns) during the rebuild, not just a Discussion caveat.
4. **A systematic literature-comparison table** (this study's h²/t/rg
   against Jonker et al. and the other cited sheep/beef/dairy methane
   genetics literature) would answer R1's most serious concern and R2's
   general comparison request with one deliverable. Worth planning as a
   concrete table, not just narrative text.
5. **CO2 as its own analysed trait** is a cheap, direct answer to R2 that
   isn't in the current plan, and the phenotype pipeline already
   QC-screens CO2 (per the submitted Methods), so the marginal cost of
   adding it is low.
6. **The selection-index scope reduction needs to be framed explicitly
   and early in the paper** (e.g. in the Introduction/Discussion, not
   just reflected by a smaller Results section), or Reviewer 1's "this
   doesn't represent a real breeding objective" critique will look
   dodged rather than answered. Explicitly naming the omission (ewe
   maintenance cost, fecundity/longevity/survival) even while declining
   to model it is likely to land better with a reviewer who raised it
   specifically.
7. **Practical caveats for the selection-index section are cheap and
   currently unplanned**: stating the real i approx 1.7 / generation
   interval approx 2.8 years, acknowledging partial measurement and
   variable genomic/EBV accuracy in practice, and citing Cuyabano et al.
   (2025) on Smith-Hazel's limitations under selection. None of this
   requires new analysis, just text -- but it directly answers a named
   reviewer request and should not be left implicit.

---

## 4. What I'd push back on or refine in the proposed strategy

1. **The residual/weight algebraic equivalence is correct, but should be
   framed carefully to avoid overclaiming novelty.** Given
   `R = CH4 - beta*W` with `beta` fixed, `R` is by construction a linear
   function of `CH4` and `W`. Any two linear combinations of `{CH4, W}`
   span the same two-dimensional space, so it is close to a direct
   consequence of Smith-Hazel index theory being invariant under linear
   reparameterisation of the goal-trait basis, rather than a new
   mathematical result. That does not make it a weak point for the
   paper -- **the actual contribution is diagnosing that the resulting
   nominal index weights on `(R, W)` are less transparent/interpretable
   than on `(CH4, W)`**, which is a genuinely useful, underappreciated
   point. The revision should frame it that way explicitly (clarifying
   an underappreciated consequence of standard theory) rather than as a
   novel derivation, so a sharp reviewer or editor doesn't dismiss it
   with "well, of course -- R is linear in CH4 and W."
2. **beta itself is estimated, not fixed, and this has knock-on
   consequences worth flagging (not necessarily resolving) during the
   rebuild.** `R`'s own variance components are computed from data that
   already embeds the estimated `beta`, so `R`'s heritability/genetic
   correlations are not independent of `beta`'s sampling error. If Monte
   Carlo uncertainty propagation resamples variance components/
   correlations for `R` and separately for `beta`-dependent quantities
   without accounting for that shared dependence, the uncertainty
   intervals could be mis-stated. Worth a specific check during the
   diagnostics stage, not something to assume is fine or broken either
   way right now.
3. **Ratios correctly excluded from the same equivalence argument** --
   agreed, forcing a symmetric "ratio equivalence" analysis would be
   artificial given the linearisation depends on population means (not a
   fixed linear transform of the same two variables), and the strategy
   is right not to force it.
4. **The genomic/H-matrix comparison should stay explicitly secondary
   and possibly deferred**, for the same reason the selection-index
   section is being narrowed: the reviewers did not ask for it, and this
   revision's job is to defensibly answer what reviewers *did* ask,
   cleanly, rather than to grow scope. Treat it as an optional robustness
   analysis to attempt only once the pedigree rebuild, ratio/residual
   work, and selection-index reduction are solid -- and include it in the
   revised paper only if it strengthens the response without diluting
   focus. This mirrors the discipline the user is already applying to the
   selection-index section; worth applying consistently.
5. **"Rebuild from the beginning" is the right instinct given a suspected
   analysis discrepancy, but should be explicitly checkpointed against
   the submitted numbers at each stage** (phenotype construction -> Table
   1 descriptive stats; pedigree -> stated pedigree/animal counts;
   variance components -> Table 2; correlations -> Tables 3-5), not just
   run end-to-end and compared only at the final output. Catching a
   divergence early (e.g. at the phenotype-construction stage) is far
   cheaper to diagnose than after a full ASReml re-run.

---

## 5. Proposed order for introducing pipelines and rebuilding

This follows the user's own instinct (PAC pipeline first, then genetics,
then selection index, genomics last/optional) but makes the diagnostic
checkpoints explicit and inserts the cheap wins (CO2-as-trait, literature
comparison, caveat text) where they naturally fall out of other work
rather than being bolted on at the end.

1. **PAC raw-data -> QC/editing -> phenotype-construction pipeline**
   (as specified first). Reproduce exactly as submitted; check against
   Table 1's n/mean/SD/range for every trait as the validation target.
   Document in `analysis/legacy/` (as received) and, once understood,
   note any proposed changes separately rather than editing in place.
2. **Rebuilt pedigree pipeline.** Needed before any ASReml rerun; also
   directly produces the pedigree-completeness/sire-count reporting R2
   asked for.
3. **Reproduce the submitted ASReml genetic-parameter analyses on the
   rebuilt phenotype + pedigree pipeline** (Tables 1-5), checkpointed
   trait-by-trait against the submitted values. **CH4 ratio gets
   dedicated, explicit scrutiny at this stage** -- units, construction,
   outlier handling, and model fit specifically -- given it's the
   reviewers' headline concern.
4. **Diagnostics bundle**, run alongside step 3 since it shares the same
   rebuilt model: connectedness/confounding metrics, formal fixed-effect
   significance/variance-explained tabulation, and a contemporary-group
   heteroscedasticity / physiological-stage-stratified sensitivity check
   (answering R1's scaling concern and R2's stage-splitting question
   together).
5. **Systematic literature-comparison table** (this study vs. Jonker et
   al. and other cited methane-genetics literature), built once step 3's
   numbers are final.
6. **CO2 as its own analysed trait** -- cheap extension once the
   phenotype pipeline (which already QC-screens CO2) and base ASReml
   reproduction are working.
7. **Ratio-trait component-based (mean/variance/covariance-derived)
   analysis**, compared against the direct-fit reproduction from step 3,
   per the user's plan.
8. **Residual-methane reinterpretation**: the CH4+weight <-> residual+
   weight equivalence demonstration, framed per Section 4 point 1 above,
   including a check of point 2 above (beta's estimation uncertainty).
9. **Selection-index section reduced to a small demonstration**,
   incorporating the transparency/equivalence point from steps 7-8, the
   explicit-scope-limitation framing (Section 3 point 6), and the cheap
   caveat text (i approx 1.7, generation interval, partial measurement/
   genomics, Cuyabano et al. citation).
10. **(Optional, deferred) H-matrix/genomic robustness comparison** --
    attempted only after 1-9 are solid; included in the paper only if it
    clearly strengthens the response without diluting focus.
11. **Manuscript rewrite**: integrate all of the above, plus the
    editorial/terminology punch-list (Section 6 below), plus the
    biological-interpretation, literature-comparison, and transferability
    Discussion improvements, plus the point-by-point response-to-reviewers
    document.

---

## 6. Editorial / low-risk punch-list (track, don't lose)

- `CH4/MBW` defined once, then called `MI` throughout -- pick one name
  and use it consistently.
- Model equation missing "+ e" as printed (embedded-equation-object issue
  confirmed independently, see `docs/manuscript_context.md` §6).
- State units for CH4 ratio and CO2 explicitly; add a means/SD/units
  table entry for CO2.
- "Charollais" (as printed) vs. "Charolais" (correct spelling, per
  Reviewer 2) -- note the manuscript is internally consistent in using
  the double-l spelling throughout, so this is a single global fix, not
  scattered typos.
- "alternative" -> "different" (or similar) per Reviewer 2's stylistic
  preference, throughout.
- Introduce heritability/repeatability calculation formulas explicitly in
  Methods.
- Introduce the CH4/CO2-related ratio trait properly in Methods if not
  already fully specified there (Reviewer 2, line 297) -- verify against
  the rebuilt Section 5 trait definitions once code is available.
- Check "why two numbers for CH4 ratio" (Reviewer 2, line 304) against
  the actual submitted table/text at that location -- not yet diagnosed.
- Italicise model term symbols consistently (Reviewer 2, line 202).

---

## 7. Open questions for the user (not urgent, for when convenient)

- Should the literature-comparison table live in the main text or
  supplementary material?
- For the CG heteroscedasticity / stage-stratification check: full
  heterogeneous-residual-variance model, or simpler stage-stratified
  univariate reruns as a sensitivity check?
- Preferred venue/format for the H-matrix comparison if it does end up
  included (main text table, supplementary, or just narrative mention)?

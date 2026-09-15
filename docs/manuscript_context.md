# Manuscript context: "Genetic Parameters and Selection Responses for
# Alternative Methane Trait Definitions in Pasture-Based Sheep"

Source: `manuscript/submitted/Methane_Genetic_Selection_Response_DK_Fnl.docx`
(submitted manuscript, treated as immutable). Authors: Dermot J. Kelly
(corresponding; Teagasc AGRIC Fermoy & Munster Technological University),
Fiona McGovern, Deirdre Purfield, Patrick McCarron, Eoin Dunne, Thierry
Pabiou (Sheep Ireland), Nóirín McHugh.

Extraction note: the manuscript's `.docx` embeds 39 formulas as native Word
equation objects (OMML `<m:oMath>`), which a naive text extraction misses
entirely (they don't live in `<w:t>` runs). A second extraction pass
recovered the equation text (`<m:t>`) specifically; the formulas quoted
below come from that pass, not from memory or inference. Two tables in the
manuscript (Tables 1-5, five total) were also extracted and cross-checked
against the inline paragraph text -- they agree. This document is a
detailed technical reference, not a summary; where a figure/table/section
is the source of a number, it is cited so results can be traced back to
the manuscript directly.

---

## 1. Study objectives

Genetic selection is framed as a promising route to persistent, cumulative
methane reduction, but methane production is positively correlated with
body size and growth, so direct selection against absolute methane risks
constraining performance. Alternative trait definitions (intensity/ratio,
residual) have been proposed to decouple methane from production, but per
Lassen and Difford [16] (cited explicitly as the motivating gap), whether
these alternative definitions produce *meaningfully different* selection
outcomes had not been empirically evaluated. The stated objectives:
estimate genetic parameters for a range of methane trait definitions in
sheep, and determine their consequences for selection response via a
selection-index framework (Background, final paragraph).

## 2. Dataset and population

- **Raw data**: 16,535 methane (CH4) records from 8,354 sheep, 132
  research and commercial Irish flocks, 2019-2025 (Methods, "Gaseous
  emissions data").
- **QC / outlier removal**: CH4 and CO2 screened separately by 1.5x IQR;
  511 records removed (3.09%). Records assigned to contemporary groups of
  date x flock x PAC measurement group (i.e. the same 12 animals measured
  together); only CGs with >=5 animals retained. **Final analysis dataset:
  15,869 records from 8,185 animals** -- this is the n reported for CH4,
  CH4 ratio, and (implicitly) the denominator population for MBW-based
  traits in Table 1.
- **Physiological stages** (Methods, paragraph 3): lambs (both sexes,
  63-365 days; 5,564 records / 3,034 animals), hoggets (nulliparous
  females, 365-600 days; 1,812 records / 1,271 animals), mature ewes
  (recorded lambing event, 431 days-10.5 years; 7,828 records / 4,327
  animals). 25.40% of animals had multiple records within or across
  stages -- i.e. repeated measures are common, motivating the permanent
  environmental effect in the animal model.
- **Pedigree**: 330,812 animals in the numerator relationship matrix (A).
- **Ethics**: Teagasc Animal Ethics Committee (TAEC2020-252, TAEC2020-258,
  TAEC0323-374) and Health Protection Regulatory Authority
  (AE19132/P112, AE19132/P114, AE19132/P181).
- **Data availability**: raw data NOT public (commercially sensitive,
  farmer/private-enterprise data). Full variance components, complete
  correlation matrices, selection-response outputs across the response
  surface, and Monte Carlo simulation distributions are stated to be
  released via **Zenodo** (DOI "to be added upon acceptance") --
  i.e. the full numeric detail behind Tables 1-5 and Figures 1-2 is not
  entirely in the manuscript body; some of it will only exist in
  supplementary material not yet available.

## 3. Methane measurement

Portable accumulation chambers (PACs), protocol per O'Connor et al. [9]:
animals off feed >=1 hour before measurement; randomly assigned to 1 of 12
PAC units; gas concentration measured at chamber sealing and again after a
50-minute accumulation period; RKI Eagle 2 gas monitor (Weatherall
Equipment and Instruments Ltd., UK); concentration changes for CH4 and CO2
converted to daily output (g/day) via **chamber-specific** calibration
equations (the calibration equations themselves are not given in the
manuscript body).

## 4. Additional phenotypes

- **Live weight (LW)**: Prattley electronic scale, immediately pre-PAC;
  1.5x IQR outlier removal; **metabolic body weight (MBW) = LW^0.75**
  derived per animal. 15,638 records / 8,002 animals.
- **Average daily gain (ADG)**: growing animals only (<660 days at
  measurement). LW records pulled from the Sheep Ireland national
  database within +-120 days of the PAC date; ADG = slope of a linear
  regression of LW on age (days), fit per methane-measurement event (kg
  day^-1). 4,316 ADG estimates / 2,658 animals after 1.5x IQR outlier
  removal.
- **Rumen volume and muscle mass**: CT scans within +-3 days of PAC
  measurement, tissue classified by X-ray pixel density per Clelland et
  al. [17]. After 1.5x IQR outlier removal: **766 CT measurements** for
  both traits, but **746 animals** for rumen volume and **751 animals**
  for muscle mass -- the record count exceeding animal count for both
  implies some animals were CT-scanned more than once; this discrepancy
  is not explicitly explained in the text.
- **Covariates / auxiliary data**: age at measurement (weeks); breed
  proportion for the six breeds with the most methane phenotypes
  (Belclare, Charollais, Cheviot, Suffolk, **Lleyn** [note: spelled
  "Llyen" once in the prose (Methods, "Additional data" paragraph) vs.
  "Lleyn" everywhere else, including the model definition -- almost
  certainly a typo in the submitted text, not a methodological
  difference]; Texel); heterosis and recombination-loss coefficients
  (formulas below); birth/rearing litter size of the growing animal
  itself (birth: single/twin/triplet/quadruplet; rearing: single/twin/
  triplet); dam parity for growing animals (1,2,3,4,5,6,>=7); and, for
  ewes, the birth/rearing type of the litter *born to the ewe* in the
  year of measurement.

**Heterosis and recombination-loss formulas** (exact, recovered from the
embedded equation objects; VanRaden [18] and VanRaden & Sanders [19]
respectively):

```
het = 1 - sum_i( sire_i * dam_i )
rec = 1 - sum_i( (sire_i^2 + dam_i^2) / 2 )
```

where `sire_i` and `dam_i` are the proportion of breed `i` in the sire and
dam respectively.

## 5. Methane trait definitions

Table 1 groups nine trait definitions into three families. Exact
construction formulas (recovered from embedded equations, Methods,
"Methane Trait Definitions"):

**Absolute**
- `CH4` (g/day) -- total PAC-measured methane output. Directly measured,
  not derived.

**Ratio-based** (all computed for *all* animals unless noted):
- `MI` (methane intensity) = `CH4 / metabolic body weight`
- `CH4 ratio` = `CH4 / (CH4 + CO2)`
- *Growing animals only* (<660 days):
  - `CH4/ADG` = `CH4 / average daily gain`
  - `CH4/MM` = `CH4 / muscle mass`
  - `CH4/rumen` = `CH4 / rumen volume`

**Residual** (regression residuals; "generated by regressing daily
methane production (g/day) on the production trait of interest... The
residuals from each regression were extracted and used as the phenotype"
-- Methods, "Residual Methane Traits". **The manuscript's wording does not
specify whether this regression included any fixed effects/contemporary
group adjustment, or was a bivariate phenotypic regression of raw CH4 on
the raw covariate alone** -- flagged in Section 14 below as something to
verify against code once available.):
- `RMTMBW` = residual of CH4 regressed on MBW
- `RMTMBW+CO2` = residual of CH4 regressed on MBW **and** CO2 (two
  covariates)
- `RMTADG` = residual of CH4 regressed on ADG (growing animals only)

**Descriptive statistics** (Table 1; production-trait means from Results
opening paragraph): MBW 22.10 (SD 4.92) kg; LW 62.72 (SD 18.18) kg; ADG
0.18 (SD 0.10) kg/day; muscle mass 11.7 (SD 3.24) kg; rumen volume 6.16
(SD 1.49) L.

| Trait | n records | n animals | mean (SD) | range |
|---|---|---|---|---|
| CH4 (g/day) | 15,869 | 8,185 | 17.90 (7.56) | 4.01-40.31 |
| MI (g/kg^0.75/day) | 15,638 | 8,002 | 0.81 (0.29) | 0.14-2.38 |
| CH4 ratio | 15,869 | 8,185 | 0.02 (0.01) | 0.00-0.19 |
| CH4/ADG | 4,316 | 2,658 | 137.89 (189.27) | 12.03-2058.33 |
| CH4/MM | 766 | 751 | 1.44 (0.48) | 0.33-3.08 |
| CH4/rumen | 766 | 746 | 2.69 (0.88) | 0.65-5.73 |
| RMTMBW | 15,638 | 8,002 | 0.00 (6.53) | -20.48-21.33 |
| RMTMBW+CO2 | 15,638 | 8,002 | 0.00 (5.32) | -23.38-24.15 |
| RMTADG | 4,316 | 2,658 | 0.00 (4.75) | -10.23-25.82 |

CH4/ADG's SD (189.27) vastly exceeds its mean (137.89) -- the authors
themselves attribute this to "the small denominator in this ratio trait"
(Results, opening paragraph). Residual traits are centred at zero by
construction (regression residuals).

## 6. Genetic models

**Software**: ASReml [20] (pedigree-based animal models). R 4.2.3 [24]
with Matrix 1.5.3 [25], dplyr 1.1.1 [26], tidyr 1.3.0 [27] for the
downstream (selection-index) computation -- ASReml itself is presumably
run separately/externally, not from within this R stack.

**Animal model** (exact, recovered from embedded equation; Methods,
"Genetic analysis" -- stated to be used for *all* methane traits, both
univariate and bivariate):

```
y = mu + sex + BR + CL + CV + LY + SU + TX + het + rec + age
    + BTg + RTg + BTe + RTe + DP + CG + a + pe   (+ e, residual)

a  ~ N(0, A * sigma_a^2)      additive genetic
pe ~ N(0, I * sigma_pe^2)     permanent environmental
e  ~ N(0, I * sigma_e^2)      residual
```
**Note**: the "+ e" is added here for clarity but is genuinely absent from
the equation as embedded in the submitted `.docx` -- confirmed
independently by Reviewer 1 (see `docs/revision_plan.md`), who flagged
the identical discrepancy. The text narrative describes a residual term,
so this is very likely a write-up/typesetting slip rather than evidence
the fitted model omitted a residual -- but it needs an explicit fix in
the revision regardless.
A = numerator relationship matrix; I = identity.

Fixed effects: sex (class); breed-proportion covariates BR/CL/CV/LY/SU/TX;
het, rec (covariates, formulas above); age in weeks (covariate); BTg/RTg
(birth/rearing litter size of the growing animal itself, class); BTe/RTe
(birth/rearing litter size of the litter born to the ewe in the
measurement year, class); DP (dam parity, growing animals, class); CG
(contemporary group = flock-date-lot, class).

**Open structural question** (not resolved by the text, flagged for
later verification, not assumed either way): BTg/RTg/DP are described as
applying to "growing animals" and BTe/RTe to "ewes" -- the single model
equation given nominally includes all of these terms together, but it is
not stated in the Methods whether the model is literally fit once with
all terms always present (with the "wrong" subset's terms presumably
inapplicable/zero for a given animal), or whether growing-animal and ewe
records are actually modelled with different effective fixed-effect sets.
This matters for reproducing the variance components exactly.

**Permanent environmental effect omitted** for CH4/MM and CH4/rumen
models "due to small numbers of repeated records" (Methods) -- consistent
with Table 2 showing "-" for sigma_pe and repeatability for those two
traits.

**Bivariate models** used to estimate genetic and phenotypic correlations:
(i) among methane trait definitions (Table 3), and (ii) between methane
traits and production traits -- MBW, LW, ADG, muscle mass, rumen volume
(Tables 4-5).

## 7. Variance components and genetic parameters

Full table (Table 2; sigma_a/sigma_pe = genetic/permanent-environmental
standard deviation in the trait's own units, SE in parentheses; h2 =
heritability; t = repeatability; CVa = genetic coefficient of variation):

| Trait | sigma_a (SE) | sigma_pe (SE) | h2 (SE) | t (SE) | CVa |
|---|---|---|---|---|---|
| CH4 | 1.62 (0.13) | 1.46 (0.14) | 0.17 (0.03) | 0.31 (0.01) | 9.05% |
| MI | 0.06 (0.01) | 0.06 (0.01) | 0.15 (0.02) | 0.28 (0.01) | 7.41% |
| CH4 ratio | 1.24e-3 (1.23e-4) | 5.05e-4 (2.90e-4) | 0.08 (0.02) | 0.09 (0.01) | 0.24% |
| CH4/ADG | 43.50 (7.81) | 36.30 (9.08) | 0.17 (0.05) | 0.29 (0.02) | 31.55% |
| CH4/MM | 0.17 (0.03) | - | 0.34 (0.12) | - | 11.81% |
| CH4/rumen | 0.38 (0.07) | - | 0.29 (0.13) | - | 11.52% |
| RMTMBW | 1.40 (0.12) | 1.40 (0.13) | 0.14 (0.02) | 0.28 (0.01) | - |
| RMTMBW+CO2 | 1.55 (0.12) | 1.65 (0.12) | 0.16 (0.03) | 0.35 (0.01) | - |
| RMTADG | 1.30 (0.21) | 0.54 (0.50) | 0.20 (0.07) | 0.24 (0.03) | - |

Range: h2 0.08 (CH4 ratio, lowest) to 0.34 (CH4/MM, highest, but with a
large SE); repeatability 0.09 (CH4 ratio) to 0.35 (RMTMBW+CO2).

**Notable numerical flag**: RMTADG's sigma_pe = 0.54 with SE 0.50 -- the
standard error is nearly as large as the estimate itself. This is not
specifically discussed in the text; it suggests a weakly identified
permanent-environmental component for this trait/subset, plausibly a
smaller-sample-size and single-record-per-animal-stage effect (ADG-based
traits are growing-animal-only, n=4,316/2,658 vs. 15,638-15,869 for the
MBW-based traits).

## 8. Correlation analyses

**Among methane trait definitions** (Table 3; genetic correlations above
diagonal, phenotypic below; footnote states phenotypic-correlation SEs are
all <=0.07, no per-cell phenotypic SE given). Selected values (SE in
parentheses where genetic):

- CH4-MI: rg 0.87 (0.02); rp 0.87
- CH4-CH4 ratio: rg 0.73 (0.05); rp 0.46
- CH4-CH4/ADG: rg 0.23 (0.06) [weakest of CH4's genetic correlations to
  another methane definition]; rp 0.30
- CH4-CH4/MM: rg 0.85 (0.07); rp 0.87
- CH4-CH4/rumen: rg 0.65 (0.11); rp 0.67
- CH4-RMTMBW: rg 0.55 (0.06); rp 0.78
- CH4-RMTMBW+CO2: rg 0.40 (0.07); rp 0.66
- **CH4-RMTADG: rg 0.26 (0.48)** [SE nearly double the point estimate --
  numerically the least-certain correlation in the whole table; not
  specifically flagged in the Discussion, see Section 14]
- MI-CH4/MM: rg 0.86 (0.04)
- RMTMBW-RMTADG: rg 0.77 (0.03)
- RMTMBW+CO2-RMTADG: rg 0.55 (0.07)
- **CH4/MM-RMTADG: rg 0.99 (0.08)** -- the maximum genetic correlation
  reported anywhere in the manuscript, matching the Abstract's stated
  range "rg = 0.23-0.99".

Several cells are blank ("-") in Table 3 (e.g. CH4 ratio vs. CH4/rumen
genetically, CH4 ratio vs. RMTMBW+CO2 genetically) -- presumably
non-convergence or an unfitted bivariate pair; not explained in text.

**Between methane traits and production traits** (Tables 4 phenotypic, 5
genetic; both vs. MBW, LW, ADG, muscle mass, rumen volume). Selected
values:

- CH4-MBW: rp 0.08 (0.02); **rg -0.03 (0.08)** [near zero genetically,
  despite a small positive phenotypic correlation]
- CH4-LW: rp 0.26 (0.02); rg 0.50 (0.03)
- CH4-ADG: rp 0.19 (0.02); rg 0.41 (0.05)
- CH4-rumen volume: rp 0.20 (0.05); rg 0.68 (0.29) [large SE]
- CH4-muscle mass: rp 0.07 (0.05); rg not reported ("-")
- MI-MBW: rp -0.10 (0.01); rg -0.27 (0.04)
- RMTMBW-MBW: rp -0.24 (0.01); rg -0.69 (0.06) [strong negative, expected
  by construction -- MBW was regressed out]
- RMTMBW-ADG: rg 0.01 (0.05) [near zero]
- RMTADG-MBW: rp +0.17 (0.03); **rg +0.31 (0.11)** [positive -- opposite
  sign to RMTMBW's relationship with MBW, despite both being "residual
  methane" traits]
- **RMTADG-LW: rg 0.94 (0.07)** [very strong; notable, not extensively
  discussed]

## 9. Selection-index methodology

**Framework**: Smith-Hazel linear selection index [21] (Hazel 1943). Two
parallel frameworks:
1. **MBW framework**: goal traits CH4 and MBW; used to evaluate CH4/MBW
   (ratio) and residual-methane-adjusted-for-MBW.
2. **LW framework**: goal traits CH4 and LW; used to evaluate CH4/LW
   (ratio) and residual-methane-adjusted-for-LW.

In both frameworks, **ADG is included as a correlated trait with zero
economic weight** -- i.e. ADG responses are *predicted consequences*, not
something directly selected on. This is a deliberate design choice that
shapes every "favourable/unfavourable ADG response" claim in the Results
and Discussion.

**Important gap**: CH4/LW and residual-methane-adjusted-for-LW are used
as breeding objectives in the LW framework (Figure 2), but neither they
nor LW's own variance components (sigma_a, sigma_p, LW-ADG correlations)
appear as rows in Tables 1-5, which are built around the nine methane
trait definitions from Section 5 plus their correlations with production
traits. CH4-LW's genetic correlation (0.50, Table 5) is reported, but not
LW's own heritability or the LW-ADG correlation needed to fully
reconstruct the {CH4, LW, ADG} G and P matrices used in Figure 2. These
inputs are presumably in the not-yet-available Zenodo supplementary
material. **This is a concrete, specific item to check once code/
supplementary data are available** -- flagged, not resolved.

**G/P matrix construction**: "Additive genetic (G) and phenotypic (P)
variance-covariance matrices for CH4, the relevant weight trait and ADG
were constructed from variance components and correlations estimated in
the animal models described above. Within each framework, G and P
remained fixed throughout the analysis." (Methods)

**Breeding-goal grid**: weightings on CH4 and the relevant weight trait
varied from -10 to +10 in increments of 0.5, "producing 1,680 alternative
breeding goal vectors." **Arithmetic note**: a full 41x41 grid (41 values
from -10 to 10 in steps of 0.5) is 1,681 combinations, not 1,680 -- a
one-vector discrepancy (plausibly the degenerate (0,0) vector, which would
give an undefined/zero index, being excluded; not stated in text). Minor,
but a concrete thing to verify against code rather than assume.

**Index weights** (exact formula, recovered): `b = P^-1 * G * a`, standard
Smith-Hazel index-weight equation, where `a` is the breeding-goal vector.

**Predicted genetic response**, scaled to unit selection intensity (i=1)
(exact formula, recovered): `Delta_G = G * b / sqrt(b' * P * b)`. Text
notes i=1 "acts only as a scalar multiplier... and therefore does not
affect the relative trade-offs among traits" -- true for direction, worth
separately confirming (once code is available) that absolute response
*magnitudes* across very different weighting vectors are being compared
on a consistent basis given `b'Pb` (index variance) differs by weighting.

**Ratio-trait linearisation**: first-order Taylor expansion of the ratio
around observed trait means, "approximating the nonlinear ratio as an
equivalent linear combination of CH4 and the relevant weight trait" [22,
Lin 1980].

**Residual-trait objective**: `CH4 - beta * weight`, with
`beta = Cov(CH4, weight) / Var(weight)` (phenotypic covariance structure,
analogous to residual feed intake [23, Koch et al. 1963]). Selecting to
*decrease* residual methane corresponds to a breeding-goal vector
proportional to `(-1, beta)`.

**Monte Carlo uncertainty propagation**: 1,000 draws; variance components
and genetic correlations resampled from approximate sampling distributions
based on ASReml-reported SEs; **log-normal draws for variances, Fisher-z-
transformed draws for correlations**; uncertainty reported as the Monte
Carlo SD and a 95% uncertainty interval (note: the manuscript reports
point estimate +- SD throughout Results/Figures, e.g. "-0.56 +- 0.07 g
day-1" -- worth checking during reconciliation whether the reported
"+-" figures are the MC SD specifically, or a 95% UI half-width, since
both are described as outputs).

## 10. Main results

All responses are **per generation**, at unit selection intensity (i=1).
ADG responses are reported in g/day (not kg/day) "for ease of
interpretation" (Results, "Selection Index").

**MBW framework (Figure 1)**:
- CH4/MBW (ratio) objective ["triangle" marker]: Delta_CH4 = -0.56 +-
  0.07 g/day; Delta_MBW = +0.48 +- 0.08 kg; Delta_ADG = +4.96 +- 1.60
  g/day. Implicit index weighting: 55.1% CH4 / 44.9% MBW.
- Residual (CH4 - beta*MBW) objective ["square" marker]: Delta_CH4 =
  **-0.68 +- 0.06** g/day (larger reduction than the ratio objective);
  Delta_MBW = +0.19 +- 0.08 kg (smaller than the ratio objective);
  Delta_ADG = **-2.65 +- 1.26 g/day (unfavourable -- the only reported
  primary-objective point with a negative ADG response)**. Implicit
  weighting: 87.55% CH4 / 12.45% MBW.
- "Neutral-ADG" alternative linear-index point (chosen post hoc from the
  grid, not a named objective): Delta_CH4 = -0.66 +- 0.06 g/day
  (comparable to the residual objective's reduction), Delta_MBW = +0.31
  +- 0.05 kg (more favourable than the residual objective), Delta_ADG
  approx 0. Weighting approx 75% CH4 / 25% MBW.
- Across the "biologically favourable quadrant" (Delta_MBW > 0, Delta_CH4
  < 0) of the full grid, Delta_ADG ranged from -6.87 to +15.05 g/day.

**LW framework (Figure 2)**:
- CH4/LW (ratio) objective ["triangle"]: **Delta_CH4 = +0.45 +- 0.05
  g/day -- an INCREASE in absolute methane**, despite this being a
  methane "efficiency" trait; Delta_LW = +6.21 +- 0.21 kg; Delta_ADG =
  +33.37 +- 2.28 g/day. Weighting: 77.79% CH4 / 22.21% LW.
- Residual (CH4 - beta*LW) objective ["square"]: Delta_CH4 = -0.29 +-
  0.11 g/day; Delta_LW = +1.67 +- 0.48 kg; Delta_ADG = +8.96 +- 2.88
  g/day. Weighting: 89.35% CH4 / 10.65% LW.
- Alternative weighting example (90.48% CH4 / 9.52% LW, chosen post hoc):
  Delta_CH4 = -0.43 +- 0.08 g/day; Delta_LW = +0.43 +- 0.25 kg; Delta_ADG
  = +2.25 +- 1.39 g/day -- all three favourable simultaneously, better on
  every trait than the ratio objective in this framework.

**Headline qualitative result**: under the LW framework, selecting
directly on the *ratio* trait CH4/LW is predicted to *increase* absolute
methane output. The authors attribute this to the combination of a
fairly strong positive rg(CH4, LW) = 0.50 with LW's larger scale/
variability relative to MBW (Discussion) -- i.e. "improvement in a ratio
phenotype does not necessarily imply direct methane reduction."

## 11. Main interpretation (Discussion)

- Genetic parameter magnitudes are comparable to traits already
  successfully used in breeding programmes (example given: somatic cell
  count in dairy cattle [31, 32]) -- used to argue methane mitigation is
  a *feasible* multi-trait breeding target, not just a statistically
  detectable one.
- Trait definitions capture "overlapping but not interchangeable" genetic
  signal -- strong correlations among several definitions imply shared
  genetic architecture, but weaker ones (CH4-CH4/ADG rg=0.23+-0.06;
  CH4-RMTMBW rg=0.55+-0.06, quoted by the authors themselves as the
  weaker-correlation example even though CH4-RMTADG's rg=0.26+-0.48 is
  numerically similar in magnitude but far less precisely estimated --
  see Section 14) indicate ratio-scaling and residualisation genuinely
  alter the variance-covariance structure, not just rescale it [33].
- Ratio and residual definitions do not *remove* genetic correlation with
  production traits, they *reshape* it (often reversing its sign relative
  to absolute CH4) -- consistent with Kronmal [34] on the statistical
  limitations of ratio variables generally, and with Crowley et al. in
  beef cattle [29].
- Selection-index results: methane *can* be reduced without penalising
  production, but the outcome depends strongly on trait-definition
  choice. Ratio and residual definitions each correspond to a single,
  fixed point on the achievable CH4-weight trade-off frontier -- an
  *implicit* weighting the breeder does not directly control -- whereas a
  flexible linear index can reach strictly better combinations (e.g.
  matching the residual trait's methane reduction while achieving neutral
  ADG, in the MBW framework).
- Because methane's economic value is unstable (policy/carbon-pricing/
  market-dependent [39, 40]), the Discussion argues a **desired-gains
  framework** [41, Pesek & Baker 1969] -- specifying a target Delta_CH4
  while holding other traits favourable -- may be more practical than
  committing to a fixed Smith-Hazel economic weighting.
- Positioned as extending/complementing theoretical work on ratio-trait
  and residual-trait selection properties (Sutherland 1965 [37]; Kennedy,
  van der Werf & Meuwissen 1993 on RFI [33]; Zetouni et al. 2017 [36];
  Aggrey & Rekaya 2013 [38]) with an explicit empirical sheep-methane
  case.

## 12. Main conclusions

Stated as the first study to characterise genetic parameters across a
comprehensive suite of alternative methane trait definitions *and*
evaluate their selection-index implications, in a pasture-based sheep
population. Core claims: methane shows weak-to-moderate additive genetic
variation across all definitions; scaling/residualising changes variance
structure but does not remove heritable signal; methane can be reduced
without unfavourable body-size/growth responses, but only if the
breeding-objective definition is chosen deliberately; ratio- and
residual-based definitions impose implicit, fixed weightings that can
produce unintended productivity penalties; trait-definition choice is
framed as "a fundamental breeding decision," not a minor implementation
detail.

## 13. Important assumptions

- **Pedigree-based (not genomic) relationship matrix.** The A-matrix uses
  330,812 pedigreed animals; there is no mention of SNP/genomic
  information anywhere in this manuscript. This is a materially different
  (and, on this evidence, entirely separate) piece of work from the
  genomic/single-step (ssSNPBLUP) methane evaluation being carried out
  elsewhere on this VM (`sheep-methane-genomics-microbiome` /
  `forward_genomics_sssnpblup_v3`) -- **the two should not be conflated**.
  They share an author, a phenotyping programme (PAC-based methane in
  Irish sheep), and a trait, but this manuscript's genetic-parameter and
  selection-index work is pedigree-only.
- Standard linear mixed animal model assumptions throughout (Gaussian
  variance components, A-matrix additive relationships).
- Residual traits constructed by regressing raw(?) CH4 on a single
  covariate (or two, for RMTMBW+CO2) *before* the animal model is fit --
  exact adjustment status of that regression (raw phenotypes vs.
  fixed-effect-adjusted) is not stated (Section 5 above, flagged again in
  Section 14).
- Ratio traits are linearised via first-order Taylor approximation for
  index purposes -- notable because the manuscript's own Discussion
  critiques ratio traits generally (via Kronmal [34]) while also relying
  on a linear approximation of a ratio to demonstrate that critique
  quantitatively; not a contradiction, but a modelling choice whose
  sensitivity is not explored in the text.
- Monte Carlo uncertainty propagation assumes log-normal sampling
  distributions for variances and Fisher-z for correlations, centred on
  ASReml point estimates using ASReml-reported (asymptotic) SEs -- a
  standard approach, but one that may understate uncertainty for the
  parameters with the largest relative SEs (e.g. RMTADG's sigma_pe,
  CH4-RMTADG's rg).
- Selection intensity fixed at i=1 throughout; the manuscript does not
  report what selection intensity is actually practised (or planned) in
  Irish sheep breeding programmes, so the absolute response magnitudes
  reported should be read as "per unit of index selection differential,"
  not as literal expected per-generation gains at realistic selection
  intensities.
- ADG is fixed at zero economic weight in both selection-index frameworks
  (a design choice, not an estimated/data-derived value) -- this
  determines that ADG only ever appears as a *correlated* response in
  Results/Discussion, never as a direct selection target.

## 14. Potential analytical vulnerabilities or questions worth checking later

(Not yet investigated or resolved -- recorded here as things to check
once diagnostics/legacy code are in scope, per the project's working
principles of flagging uncertainty rather than resolving it prematurely.)

1. **RMTADG's sigma_pe = 0.54 (SE 0.50)** -- SE nearly equal to the
   estimate. Not discussed in text. Worth checking model
   convergence/identifiability for this specific trait.
2. **CH4-RMTADG genetic correlation = 0.26 (SE 0.48)** -- the least
   precisely estimated correlation in Table 3, numerically similar in
   magnitude to CH4-RMTMBW (0.55+-0.06, which the Discussion quotes as an
   example of a "weaker" correlation) but with roughly 8x the SE. The
   Discussion's narrative about which correlations are "weak" vs. "strong"
   does not explicitly account for this precision gap.
3. **Multiple blank cells in Tables 3 and 5** (e.g. CH4-muscle mass
   genetic correlation; CH4 ratio vs. several traits) -- not explained in
   text (non-convergence? insufficient data overlap? deliberately
   omitted?).
4. **Very uneven sample sizes across trait definitions** -- from n=15,869
   (CH4, CH4 ratio) down to n=766 (CH4/MM, CH4/rumen), an ~20-fold range
   -- feeding into correlation tables that present all pairs with
   superficially similar formatting/precision-looking output. Not
   explicitly caveated when comparing across trait families in the
   Discussion.
5. **Residual-trait regression order-of-operations** (Section 5, 13
   above) -- whether CH4 was regressed on the covariate before or in
   combination with the full fixed-effects animal model is not stated,
   and matters methodologically (a residual computed from raw phenotypes
   still contains contemporary-group and other fixed-effect variation
   that then gets re-adjusted for in the subsequent animal model on the
   residual itself -- an order-of-operations question with real
   consequences for what the resulting heritability actually measures).
6. **CH4/LW and residual-methane-adjusted-for-LW's own variance
   components are not tabulated** anywhere in the visible manuscript
   (Section 9 above) despite being used as breeding objectives in Figure
   2 -- their G/P inputs must come from data not shown in Tables 1-5.
7. **Grid-size arithmetic**: 1,680 reported vs. 1,681 expected from a
   literal 41x41 grid over [-10, 10] step 0.5 (Section 9 above). Minor,
   but worth a direct check against code.
8. **CH4/LW ratio objective increasing absolute methane** (Section 10)
   is the manuscript's own headline counter-intuitive finding, not a
   vulnerability per se, but a result that reviewers are highly likely to
   scrutinise closely -- the explanation given (rg(CH4,LW)=0.50 combined
   with LW's scale/variability) should be traceable precisely to the
   selection-index code once available.
9. **"Llyen" vs. "Lleyn"** breed-name spelling inconsistency (Section 4)
   -- cosmetic, but worth a proofing pass.
10. **Reference-list author-initial inconsistency**: refs [7] and [29]
    (Ryan et al.; Crowley et al., both beef-cattle papers on enteric
    methane) list a co-author as "Kelly D.N.", while the current
    manuscript's corresponding author is "Kelly D.J." -- unclear whether
    this is the same person with an initial recorded inconsistently
    across their own publications, or a different individual; not
    something to resolve now, just noted.
11. **Authors' Contributions section appears empty** in the extracted
    text (the heading is immediately followed by "Acknowledgements" with
    no content between them) -- this is very plausibly an artefact of the
    automated `.docx` text extraction (e.g. content held in a table,
    text box, or tracked-change state that didn't extract as a plain
    paragraph) rather than a genuine gap in the submitted manuscript. Not
    yet confirmed by direct visual inspection of the original file.

## 15. Key numbers and results that will likely need to be traced back to code

- **Table 1** (n/mean/SD/range per trait): traceable to the phenotype
  construction / QC pipeline (raw PAC + LW + ADG + CT data -> outlier
  removal -> derived-trait calculation). Source location: not yet known
  -- not obviously part of the `Methane_Selection_Index_Analysis` repo
  (see Section 16), so a separate, not-yet-located phenotype-preparation
  pipeline is implied.
- **Table 2** (sigma_a, sigma_pe, h2, t, CVa per trait) and **Tables 3-5**
  (genetic/phenotypic correlation matrices): traceable to ASReml animal-
  model runs (one per trait, plus bivariate pairs). The
  `Methane_Selection_Index_Analysis` repo explicitly *consumes* ASReml
  `.pvc` output as an input rather than producing it -- so the ASReml
  model-fitting code itself is a **separate, not-yet-located** piece of
  legacy analysis, not (on current evidence) in the named GitHub
  repository.
- **Figures 1 and 2 / all Selection Index numbers** (Section 10 above):
  per the manuscript's own Availability of Data and Materials statement,
  explicitly sourced from `Methane_Selection_Index_Analysis` (see Section
  16) -- this is now confirmed by the manuscript text itself, not just
  inferred from repo contents.
- **The 1,680-vector grid, convex-hull frontier, and Monte Carlo draws**
  underlying Figures 1-2: same source as above.
- Full variance-covariance matrices and complete Monte Carlo distributions
  are stated to be in Zenodo supplementary material not yet available to
  this project.

## 16. External / upstream analysis resources

### `dermok1010/PAC_data_pipeline`

**Update (2026-09-15, after initial ingestion)**: GitHub has been brought
up to date with the HPC working-tree state described below (pushed as
`8cb842d`, consolidating the previously-unpushed `7fbecaf` commit and all
further uncommitted working-tree changes into one commit). The three-way
divergence described below is now historical context for how the current
state was assembled, not a live discrepancy. Also: `08_outlier_removal.R`
and `09_trait_derivation.R` were sanity-checked by rerunning them (patched
working copies in `analysis/diagnostics/pac_pipeline_rerun/`, legacy copies
untouched) against the already-captured intermediate data -- **both
reproduced their previously-captured output files byte-for-byte**, and
`08`'s printed QC diagnostics (511 records removed, 3.09%; 15,869 records
from 8,185 animals remaining) match the submitted manuscript's Methods
exactly. Found and worked around (in the working copy only) one real
latent issue: `08_outlier_removal.R` calls `n_distinct()` (a dplyr
function) before `library(dplyr)` is loaded -- only works if dplyr was
already attached from a prior interactive session, consistent with the
`.ipynb_checkpoints` file found alongside the scripts. Scripts 01-07, 10,
11, and `data_generation.R` remain un-sanity-checked -- they need external
raw inputs not available here (full list below).

- URL: https://github.com/dermok1010/PAC_data_pipeline (public)
- Status: this is the raw-PAC-to-analysis-dataset pipeline referenced in
  the user's revision strategy (`docs/revision_plan.md`) -- taking raw PAC
  records through QC/editing and phenotype construction. Unlike
  `Methane_Selection_Index_Analysis`, this one's *code* has been brought
  into this repository at `analysis/legacy/PAC_data_pipeline/scripts/`
  (per this repo's own structure: `analysis/legacy/` = "material carried
  over from the original submission"), preserved as received, not yet
  read in technical depth or modified. Its **data** was explicitly not
  brought into git anywhere -- copied only to
  `analysis/legacy/PAC_data_pipeline/data/` on the VM filesystem, which
  `.gitignore` blanket-excludes (`**/data/`), consistent with the
  manuscript's own Data Availability statement that the underlying data
  is commercially sensitive and not public.
- **Provenance is a three-way divergence, not a single commit SHA** --
  recorded precisely because silently treating these as equivalent would
  violate this project's own "distinguish what is known from unverified"
  principle:
  1. **GitHub HEAD** (public repo, cloned as a sibling reference checkout
     at `~/PAC_data_pipeline`, not modified): `0bdc041` "fixed CT script".
  2. **HPC-committed but never pushed** (present in the tarball snapshot
     the user provided via `gs://dermot-phd-backup/PAC_data_pipeline_2026-09-15.tar.gz`,
     absent from GitHub): one further commit, `7fbecaf` "added carcass
     and phenotype scripts", adding `10_carcass_data_integration.R` and
     `phenotype_table.R` and extending `08_outlier_removal.R`/
     `09_trait_derivation.R`.
  3. **HPC working tree at the time of the snapshot (uncommitted, most
     current)** -- this is what was actually brought into this
     repository. Relative to commit `7fbecaf`: `git diff --stat` showed
     436 insertions / 537 deletions across
     `01_sheep_ire_merge.R` (297 lines changed -- the largest single
     change), `02_dmi_merge.R`, `03_weight_before_after_merge.R`,
     `04_adg.R`, `05_CG_creation.R`, `06_breed_integration.R`,
     `07_CT_merge.R`, `08_outlier_removal.R` (350 lines changed, mostly
     deletions -- plausibly a substantial simplification, not yet read),
     `09_trait_derivation.R`, and `phenotype_table.R`; plus two entirely
     new, never-committed files: `11_dam_parity_integration.R` and
     `data_generation.R`.
- **Which state actually produced the submitted manuscript's numbers is
  not yet established** -- but the working-tree state is the most
  plausible candidate: the manuscript explicitly uses dam parity as a
  model covariate (Section 6 above), and only `11_dam_parity_integration.R`
  (present solely in the working-tree state) accounts for that. This is
  an inference, not a confirmed fact, and should be verified once the
  pipeline is actually read and run, not assumed.
- **Scripts, in the order implied by their numbering** (01-11, plus two
  unnumbered): `01_sheep_ire_merge.R`, `02_dmi_merge.R`,
  `03_weight_before_after_merge.R`, `04_adg.R`, `05_CG_creation.R`,
  `06_breed_integration.R`, `07_CT_merge.R`, `08_outlier_removal.R`,
  `09_trait_derivation.R`, `10_carcass_data_integration.R`,
  `11_dam_parity_integration.R`, plus `data_generation.R` and
  `phenotype_table.R` (position in the sequence not yet established).
  Scripts 08 and 09 have now been run and checked (see update above); the
  other 11 have not been opened/read in technical depth yet. The numbered
  stages plausibly map onto the manuscript's Methods subsections
  (contemporary-group construction, breed proportion, CT merge, outlier
  removal, trait derivation, dam parity) but this mapping has not yet been
  verified script-by-script beyond 08/09.
- **External raw inputs required but not available in this project** --
  found by grepping all 13 scripts for file paths outside
  `PAC_data_pipeline/data/`. All are absolute HPC paths under
  `/home/dermot.kelly/...`, from *other* HPC project directories (Paper_1,
  Paper_3), not this pipeline's own data folder:
  - `Dermot_primary/Paper_1/data/sheeppedweight.csv` (needed by scripts 01
    and 11)
  - `Phd/Paper_1/Re-run 2024/data/growing_animals_2024_raw.csv` and
    `.../ewes_2024_raw.csv` (script 01 -- note this path uses `Phd/`
    directly under home, not `Dermot_analysis/Phd/` like every other
    reference; unconfirmed whether that's a real, separate path or a typo
    in the script -- not yet resolved)
  - `Dermot_analysis/Phd/Paper_1/Re-run 2024/data/dmi.sas7bdat` (script
    02; a SAS file -- `haven` is already in this project's R environment)
  - `Dermot_analysis/Phd/Paper_1/Phase_2_data/Sheep_weights.csv` (scripts
    03, 04)
  - `Dermot_analysis/Phd/Paper_1/Phase_2_data/master_2024.sas7bdat`
    (script 06; also SAS)
  - `Dermot_analysis/Phd/Paper_1/Re-run 2024/data/CT_data.csv` (script 07)
  - `Dermot_analysis/Phd/Paper_1/Phase_2_data/sheepcarcass.csv` (script 10)
  - `Dermot_analysis/Phd/Paper_3/genetic_analysis/asreml_scripts/P3_co2_data.csv`
    (`data_generation.R`)
  Until these are provided, scripts 01-07, 10, 11, and `data_generation.R`
  cannot be run end-to-end from genuinely raw inputs -- only 08 and 09
  could be sanity-checked, using the already-captured intermediate CSVs
  as their input.
- **Confirmed reuse in the mix99/genomic-evaluation project**: this
  pipeline's output `data/PAC_data_covariates_QC_NA_with_traits.csv` is
  byte-for-byte identical to
  `sheep-methane-genomics-microbiome/mix99_vm_context/input_data/phenotypes/PAC_data_covariates_QC_NA_with_traits.csv`,
  which is the `birth_year_source` for the mix99 forward-genomic-
  evaluation work (see that repo's `analysis_work/forward_genomics_sssnpblup_v3/setup_summary.json`).
  Separately, `data/PAC_data_covariates_QC_NA_with_traits_plus_dam_parity.csv`
  (15,870 lines, same as `phenotype_model.csv`) shares its row count and
  a large overlapping column set (methane traits, breed proportions,
  het/rec, dam_parity_group_num, etc.) with
  `sheep-methane-genomics-microbiome/persistent_cache/phase1/phenotypes/phenotype_model.csv`,
  the actual `phenotype_source` for that same mix99 work -- **this is a
  strong but not yet fully confirmed inference**: `phenotype_model.csv`
  is very plausibly derived from the `_plus_dam_parity` file by column
  selection/renaming in a separate script (e.g.
  `sheep-methane-genomics-microbiome/scripts/rebuild/01_prepare_phenotypes.py`,
  not yet checked), rather than confirmed identical or directly copied.
- The pipeline's own `.gitignore` (copied for reference to
  `analysis/legacy/PAC_data_pipeline/.gitignore.upstream_reference`)
  confirms `data/*` was never tracked in its git history -- consistent
  with the manuscript's data-availability statement.

#### Update (2026-09-15, full end-to-end rerun of scripts 01-11)

The 9 missing external raw-data files were supplied via
`gs://dermot-phd-backup/PAC_external_inputs_2026-09-15.tar.gz` (SHA-256
verified against the accompanying manifest on download), and the user
separately confirmed script 01's `~/Phd/Paper_1/Re-run 2024/...` path was
simply wrong -- the real files live under
`~/Dermot_analysis/Phd/Paper_1/Re-run 2024/...`, as every other script's
path already assumed.

Before running anything, `*.sas7bdat` was added to `.gitignore` (two of
the newly-supplied external files are raw SAS exports and were not
covered by the existing csv/xlsx/rds/parquet blanket excludes).

**What was discovered auditing scripts 01-05 before running them**:
these five scripts do not read/write a shared file between each other --
they pass R objects (`FD`, `final_data`, `full_data2`) in memory, so they
can only be run as one continuous session, never individually via
`Rscript <script>.R` (consistent with the `.ipynb_checkpoints` file found
alongside the scripts -- this looks like a notebook-style workflow that
was only partially, and inconsistently, checkpointed to disk). A single
driver (`analysis/diagnostics/pac_pipeline_rerun/run_01_to_05.R`) sources
01-05 in one session for this reason. Scripts 06 onward each re-read
their input from a file written by the previous script, so they run
standalone.

Also discovered auditing script 01: legacy lines 228-275 (a trailing
block writing `growing_animals_2024_raw.csv` / `ewes_2024_raw.csv`)
reference objects (`ewes_lambing_dates`, `common_animals`,
`ewes_only_subset`) that are never defined anywhere in the script -- this
block cannot have executed as part of a clean top-to-bottom run of the
file as it currently exists. Grepping the whole pipeline confirms those
two output files are never read by any other script, i.e. they are a
dead end, not a required input to anything downstream. The patched
working copy omits this block entirely (documented in the script's own
header) rather than inventing substitute objects to make it run.
Similarly, script 10's output (`PAC_data_before_edits_plus_carcass.csv`)
was confirmed by the same grep to be a dead end -- no other script reads
it either.

**Full chain result (01 through 11, patched working copies in
`analysis/diagnostics/pac_pipeline_rerun/`, legacy originals untouched)**:
ran end-to-end without errors (aside from benign dplyr
"many-to-many relationship" join warnings, which just describe the
expected one-animal-to-many-weighings/CT-scans join shape). Printed QC
diagnostics exactly match the manuscript and the earlier 08/09-only
sanity check: 16,535 raw records -> 511 removed (3.09%) -> 15,869 final
records / 8,185 animals.

Compared cell-by-cell (R `identical()` on shared columns) against the
previously-captured legacy outputs at each stage:

- `PAC_data_all_raw.csv` (01) through `PAC_data_before_edits.csv` (07):
  **identical on all 226 shared columns, all 16,535 rows**, except the
  legacy capture has one extra column, `ewe_age_years`, that no script
  currently in the pipeline (in this repo's copy or the GitHub copy)
  computes. This column is not part of the manuscript's stated model
  covariates (see Section 6/7 above), so its disappearance from the
  current script set doesn't affect any reported result -- but it does
  confirm the scripts as they exist today are not byte-for-byte the same
  version that produced the original captured data, somewhere upstream
  of `ewe_age_years` having been removed (or never migrated) from the
  current working tree.
- `PAC_data_covariates_QC_NA_with_traits.csv` (09): same pattern, still
  missing only `ewe_age_years`; all outlier-removal/trait-derivation
  numbers match exactly.
- `PAC_data_covariates_QC_NA_with_traits_plus_dam_parity.csv` (11): of
  236 shared columns, only one differs in value --
  `ewe_lambing_date`. In the legacy capture, `ewe_lambing_date` is
  identically equal to `pac_date` for every ewe record (e.g. row 1:
  lambing date "2022-06-24" == that row's own PAC test date). In the
  freshly-rerun version, `ewe_lambing_date` instead correctly shows the
  most recent prior lambing date (e.g. "2021-12-29" for that same
  animal/test). This is not a new bug introduced by patching -- script
  01 already carries an inline comment describing exactly this failure
  mode ("After a rolling join, the join column can reflect the PAC
  lookup date, so do not assign ewe_lambing_date from lamb_birthdate
  directly") and a corresponding fix (`actual_lambing_date`). The
  legacy captured file's `ewe_lambing_date` values are consistent with
  the *pre-fix* behaviour the comment warns about, meaning the version
  of script 01 that actually produced the manuscript's captured data
  predates this fix, while the current working-tree script already has
  it applied. **Consequence for the manuscript is believed to be nil**:
  the model's dam-parity covariate (`DP` in the animal-model equation,
  Section 6/7) is built in `11_dam_parity_integration.R` purely from the
  Sheep Ireland pedigree table (`SI`/`dam_parity_table`, matched on
  `ANI_ID_DAM` + the PAC animal's own `animal_birthdate`) and never reads
  the PAC file's own `ewe_lambing_date`/`days_since_lambing` columns at
  all -- and indeed `dam_parity_at_birth`/`dam_parity_group_num` matched
  exactly between the fresh and legacy files. `ewe_lambing_date` and its
  derived `days_since_lambing` appear to be diagnostic/exploratory
  columns carried through the pipeline rather than reported model inputs,
  but this has not been exhaustively re-checked against every table in
  the manuscript -- flagged here as an open item rather than closed.
- Script 10 (`PAC_data_before_edits_plus_carcass.csv`) ran cleanly;
  not compared cell-by-cell since no legacy capture of this exact file
  was available and, per above, nothing downstream reads it anyway.

No further GitHub push was needed for this step -- `dermok1010/PAC_data_pipeline`
was already brought up to date with the current working-tree script
versions at commit `8cb842d` in the prior update, and none of the legacy
scripts were changed during this rerun (only sandboxed patched copies in
this repo's `analysis/diagnostics/`).

### `dermok1010/Methane_Selection_Index_Analysis`

- URL: https://github.com/dermok1010/Methane_Selection_Index_Analysis
- Status: read-only upstream reference. Not modified, not audited line by
  line, not vendored into this repository. Cloned as a sibling checkout at
  `~/Methane_Selection_Index_Analysis` for light inspection only (its own
  README and file listing, not its code).
- Commit SHA at time of this initial light inspection (2026-09-15):
  `fb1f0a2cddb82ba322cfd86b4ad3d99830385a44` ("added simplified script").
  **Record the SHA actually in use at the time of any future analytical
  reconciliation** -- this is only a setup-time snapshot and must not be
  assumed current later.

**Confirmed relationship to the manuscript**: the manuscript's own
Availability of Data and Materials section states explicitly: *"Code used
for the selection index analyses
(https://github.com/dermok1010/Methane_Selection_Index_Analysis)... are
available via Zenodo [DOI to be added upon acceptance]."* This directly
confirms (not merely infers) that this repository is the source of the
**Selection Index methodology and Results (Sections 9-10 above; Figures 1
and 2)**. It is explicitly *not* stated to be the source of the
genetic-parameter/variance-component work (Tables 1-5) -- and the repo's
own README describes it as *consuming* ASReml `.pvc` output as an input,
consistent with that division.

**What the repository contains** (from its own README and file listing --
not yet verified line-by-line against the manuscript, no code opened):

- Four R scripts at the repository root: `MC_3trait_selection_response.R`
  (52KB, likely the main three-trait CH4/MBW/ADG Monte Carlo response
  script), `MC_weight.R` (36KB), `genetic_residual.R` (39KB, likely
  residual-trait construction/analysis), `index_weight_methane.R` (15KB,
  likely the core `b = P^-1 G a` computation).
- `outputs/`: `frontier_adg_v5.png`, `frontier_adg_liveweight.png`
  (plausibly the sources of manuscript Figures 1 and 2 respectively, by
  name -- not yet confirmed by opening them), `land_use.png` (no obvious
  manuscript counterpart yet identified), and `genetics_paper_data_upd.xlsx`
  (119KB -- filename strongly suggests this is the underlying data/
  variance-component spreadsheet for the paper; not yet opened).
- Per its README: workflow is (1) read ASReml `.pvc`-derived variance
  components for CH4/MBW/ADG, (2) compute Smith-Hazel index weights
  `b = P^-1 G a` over a grid of breeding-goal vectors, (3) extract the
  convex-hull response frontier, (4) map the ratio and residual
  objectives onto that frontier via Taylor linearisation and the
  `Cov/Var` beta respectively, (5) propagate uncertainty via 1,000 Monte
  Carlo draws (log-normal for variances, Fisher-z for correlations) --
  this matches the manuscript's Methods description closely (Section 9
  above).
- 9 commits total (`af7cff8` "Initial commit" through `fb1f0a2` "added
  simplified script"); commit messages like "few outputs and updates" and
  "fixed paths" suggest informal, iterative development rather than one
  frozen analysis pass -- **worth establishing which commit actually
  produced the numbers in the submitted manuscript**, which may not be
  the current HEAD.
- The repo's own `.gitignore` excludes `outputs/*.csv` but keeps PNGs --
  so numeric output files (as opposed to figures) may not be tracked in
  git history at all, which could complicate tracing exact reported
  numbers back to a specific run.

This section (and the manuscript-mapping judgement in it) should be
revisited once diagnostic/reconciliation work actually begins -- nothing
above has been verified by reading the repository's code.

---

## Distinguishing what is known, inferred, and unverified

- **What the manuscript states**: everything in Sections 1-13 with a
  cited table/figure/section is a direct read of the manuscript text
  (including formulas recovered from embedded equation objects, not
  paraphrased).
- **What is inferred rather than stated**: the mapping of specific
  manuscript figures to specific upstream-repo output filenames (Section
  16); the likely cause of the CH4/LW ratio result (stated by the authors,
  but not yet independently verified against code); which commit of the
  upstream repo was actually used.
- **What remains genuinely unverified and should be checked against
  code/data once in scope**: every item in Section 14; the exact
  regression order-of-operations for residual traits; the source of
  Tables 1-5 (not yet located); the LW-framework G/P matrix inputs; the
  1,680-vs-1,681 grid-size discrepancy; whether "Authors' Contributions"
  is genuinely empty in the original file or an extraction artefact.

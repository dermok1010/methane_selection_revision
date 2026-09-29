# Selection-index demonstration (revision draft v0.2, 2026-09-29)

Supersedes `selection_index_section_DRAFT_v0.1.md` (kept as a record; its numbers came from a pairwise assembly of
genetic parameters and should not be used). Text below is new revision material, not part of the submitted manuscript;
every paragraph is highlighted for the Word export. Numbers come from
`analysis/revision/selection_index/02_selection_index_trivariate.R` (inputs: the single CH4 x MBW x CO2 trivariate
ASReml fit, `analysis/revision/asreml_pipeline/results/trivariate_summary.csv`; figure from `03_frontier_figure.R`).
Point estimates only: no Monte Carlo. Items marked [VERIFY] are literature claims not yet checked against the source.

<mark>

## Methods: illustrative selection-index analysis

**Purpose and scope.** The index analysis is presented as an illustration of how the choice of methane definition
changes the expected direction of genetic change, not as a bio-economic breeding objective. Feed intake was not
measured; feed cost, ewe maintenance, fecundity, longevity and lamb survival are not modelled (see Limitations).

**Genetic parameters.** Genetic, residual and permanent-environment (co)variances for methane (CH4, g/d), metabolic
body weight (MBW, kg^0.75) and CO2 production (g/d) came from a single three-trait animal model fitted in ASReml to
all 15,869 records (each record has all three traits), with the fixed effects of the bivariate models, an unstructured
3 x 3 additive genetic matrix, trait-specific (independent) permanent-environment variances and an unstructured residual
matrix. The model converged in 13 iterations with no parameter at a boundary. The phenotypic matrix was
P = G + R + diag(permanent environment).

**Indices.** Smith-Hazel indices with CH4 and MBW as information traits, b = P^-1 G a, where a is the vector of
breeding-goal weights. CO2, a candidate proxy for energy expenditure and feed intake [VERIFY], was given zero weight
so that its correlated response could be reported. Objectives were: (1) the ratio CH4/MBW (first-order Taylor
expansion at the trait means); (2) residual methane, CH4 - beta x MBW, with beta the phenotypic regression of CH4 on
MBW (0.64); (3) residual methane with beta the genetic regression (0.83); (4) a CH4 reduction with the MBW response
held at exactly zero (restricted index; Kempthorne and Nordskog); and (5) for reference, a CH4 reduction with no
constraint. A grid search over CH4 and MBW weights (-10 to 10, steps of 0.5) is given as a check on (4). Responses are
**per generation at a selection intensity of i = 1**, which is what "progress per generation" meant throughout the
submitted paper; we also give responses at i = 1.7 and per year for a 2.8-year generation interval, the values
typical for sheep breeding programmes.

**Measurement scenarios.** To show what changes when not all traits are recorded on all candidates, the CH4 reduction
was recomputed with information from CH4 alone, CH4 + MBW, and CH4 + MBW + CO2, with and without holding MBW (and
CO2) constant.

**Genetic independence of the residual trait.** The genetic variance of the phenotypic residual, and its genetic
correlations with MBW, CH4 and CO2, were calculated from G, and the index on (residual, MBW) was compared with the
index on (CH4, MBW) for the equivalent goal.

**Sensitivity.** Because genetic correlations change under selection (Cuyabano et al. 2025 [VERIFY]), the responses
were recomputed for CH4-MBW genetic correlations from -0.03 (the value in the submitted analysis) to 0.80, holding the
variances fixed. Sampling uncertainty of the variance components was not propagated; the standard error of the
CH4-MBW genetic correlation was 0.027.

</mark>

<mark>

## Results (proposed text and tables)

The three-trait model gave heritabilities of 0.27 (CH4), 0.58 (MBW) and 0.41 (CO2) and genetic correlations of 0.69
(CH4-MBW, SE 0.03), 0.57 (CH4-CO2, SE 0.03) and 0.83 (MBW-CO2, SE 0.02). The partial genetic correlation between CH4
and CO2 given MBW was -0.004: CO2 carried no genetic information on methane beyond that in body size.

**Table X. Expected genetic response per generation (i = 1) to indices with CH4 and MBW as information traits.**
r_IH is the correlation between the index and the objective.

| Objective | dCH4 (g/d) | dMBW (kg^0.75) | dCO2 (g/d) | r_IH | dCH4 per year (i = 1.7) |
|---|---|---|---|---|---|
| Ratio CH4/MBW | -0.79 | -0.21 | -16.7 | 0.41 | -0.48 |
| Residual methane, phenotypic beta | -1.10 | -0.64 | -51.2 | 0.45 | -0.67 |
| Residual methane, genetic beta | -0.75 | -0.16 | -12.5 | 0.41 | -0.45 |
| CH4 reduction, MBW response held at 0 | -0.61 | 0.00 | +0.1 | 0.29 | -0.37 |
| CH4 reduction, no constraint (reference) | -1.34 | -1.20 | -96.1 | 0.64 | -0.81 |

At i = 1.7 responses are 1.7 times those shown; per year they are divided by a further 2.8 (last column). A grid
search over CH4 and MBW weights gave -0.61 g/d with an MBW response of +0.003 for the same "no loss in MBW" criterion,
as expected (Figure X).

1. **The growth-neutral conclusion of the submitted analysis does not hold.** With the CH4-MBW genetic correlation of
   0.69 rather than the -0.03 used previously, both the ratio and the residual objectives are expected to reduce MBW
   along with methane, and CO2 falls in proportion (the CO2 response is almost exactly proportional to the MBW response;
   Figure X, right). The earlier index numbers should therefore not be compared with those above. Growth is
   unchanged only if it is explicitly constrained, which retains 46% of the unconstrained CH4 response
   (-0.61 v -1.34 g/d) and 78% of the ratio response (-0.79 g/d).
2. **The ratio is close to growth-neutral only for lower correlations.** Its MBW response changes sign at a genetic
   correlation of about 0.63 (Table Y); the estimate is 0.69 (SE 0.03), so the sign of the ratio's MBW response is
   sensitive to the estimation of one parameter.
3. **The phenotypic residual is not genetically independent of body weight (Reviewer 2, line 499).** Its genetic
   correlation with MBW was 0.22, with CH4 0.85 and with CO2 0.18, and its heritability 0.17. Regressing on the genetic
   rather than the phenotypic coefficient (0.83 v 0.64) removes this by construction and cuts the MBW response from
   -0.64 to -0.16.
4. **The residual and (CH4, MBW) indices are the same index in different coordinates.** For the goal CH4 - beta x MBW
   the index on (residual, MBW) reproduces the (CH4, MBW) responses exactly (maximum difference < 1e-8), but its weights
   differ (-0.17 and -0.11 on residual and MBW, versus -0.17 and -0.002 on CH4 and MBW), so the weights on a residual
   trait cannot be read as an economic weighting of MBW.
5. **CO2 as an information trait adds almost nothing.** Adding CO2 to CH4 + MBW raised r_IH from 0.636 to 0.637
   (unconstrained) and from 0.291 to 0.300 (MBW held constant); also holding CO2 constant cost 3% of the CH4 response
   (-0.631 to -0.610 g/d). Measurement of CH4 alone gave r_IH = 0.52 and -1.10 g/d, with MBW falling by 0.63.

**Table Y. Sensitivity to the CH4-MBW genetic correlation (i = 1, two-trait index).** dMBW for each objective.

| rg (CH4, MBW) | Ratio: dCH4 / dMBW | Residual: dCH4 / dMBW | MBW held constant: dCH4 |
|---|---|---|---|
| -0.03 (submitted) | -0.84 / +1.01 | -1.09 / +0.40 | -1.10 |
| 0.40 | -0.60 / +0.54 | -1.01 / -0.12 | -0.95 |
| 0.60 | -0.66 / +0.11 | -1.04 / -0.45 | -0.74 |
| 0.69 (estimate) | -0.79 / -0.21 | -1.10 / -0.64 | -0.61 |
| 0.80 | -1.08 / -0.72 | -1.24 / -0.92 | -0.43 |

(-0.03 row: trivariate variances with the submitted correlation, so it is not the submitted numbers.)

**Figure X.** Response frontier (`tri_response_frontier.png`): all CH4-MBW weight directions on the grid (grey hull) with
the named objectives; left, CH4 against MBW; right, CO2 against MBW.

</mark>

<mark>

## Limitations (proposed text)

These results illustrate the consequences of the methane definition; they are not a breeding-programme
recommendation. (i) **The objective is not a farm economic model.** It omits feed cost per unit of intake, ewe
maintenance (about 70% of flock feed use), fecundity, longevity and lamb survival, and the relationships of these
with methane are unknown here. (ii) **Selection intensity and generation interval.** Responses are at i = 1 unless
stated; at i = 1.7 and 2.8 years they are scaled as above, which changes size, not direction. (iii) **Measurement and
accuracy.** In practice not all animals are measured for all traits, measurement differs between sexes and progeny,
and genomic information is used partially and with varying accuracy of breeding values; the measurement scenarios
above only show the effect of dropping traits at fixed accuracy, and the results should not be extrapolated directly
to a real flock. (iv) **Smith-Hazel is an approximation** whose validity erodes as selection changes genetic
variances and correlations; Cuyabano et al. (2025) [VERIFY citation details] document this, and the sensitivity to the
CH4-MBW correlation (Table Y) is one illustration. (v) **CO2 as an intake proxy.** Reported genetic correlations of CO2
with dry matter intake are high in beef cattle and Merino sheep but weaker for residual feed intake [VERIFY], mostly
from respiration chambers rather than portable accumulation chambers on pasture lambs. Here CO2 was largely a
body-size proxy (genetic correlation with MBW 0.83, partial correlation with CH4 given MBW about 0), and in the
346-animal subset with individual intake records the raw phenotypic correlation of CO2 with intake was only 0.34
(unadjusted). (vi) **Uncertainty.** Sampling variances of the variance components were not propagated, so the
point estimates carry no interval.

</mark>

<!-- Reviewer map (not for the manuscript).
R1(b) trait/index vs economic model, intake proxy: scope statement (Methods, Limitations i, v); CO2 as intake proxy and
   the 3-information-trait scenario (Results 5).
R1(c) i = 1 made explicit; i = 1.7 and 2.8 y columns; partial measurement / genomic accuracy: Methods, Table X, Limitations
   ii, iii. Cuyabano et al. 2025: Limitations iv + Table Y (citation to be verified).
R2 (CO2 as its own trait): trivariate model, Results first paragraph.
R2 line 499 (phenotypic residual not genetically independent): Results 3, 4.
Open: the submitted paper's second framework (live weight, LW) is not rebuilt (needs weight-CO2 and CH4-LW models).
-->

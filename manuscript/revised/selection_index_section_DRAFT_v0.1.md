# Selection-index demonstration (revision draft v0.1, 2026-09-29)

Text below is new revision material, not part of the submitted manuscript; every paragraph is highlighted
for the Word export. Numbers come from `analysis/revision/selection_index/01_selection_index_co2.R`
(inputs: rebuilt ASReml bivariate fits; seed 20260929; 1,000 Monte Carlo draws).
Items in [VERIFY] are literature claims that have not been checked against the source papers.

<mark>

## Methods: illustrative selection-index analysis

To illustrate how the choice of methane definition changes the expected direction of genetic change, we
constructed Smith-Hazel indices from the rebuilt genetic and phenotypic (co)variance matrices for methane
(CH4, g/d) and metabolic body weight (MBW, kg^0.75). CO2 production (g/d), which is closely related to
energy expenditure and, in respiration-chamber work, to feed intake [VERIFY], was included as a correlated
trait with zero economic weight, so that the index could be used to ask what happens to a plausible intake
proxy when methane is selected against. This replaces average daily gain, the correlated trait used in the
original submission.

Two breeding objectives were evaluated: the ratio CH4/MBW (first-order Taylor expansion of the ratio at the
trait means) and residual methane (CH4 adjusted for MBW using the phenotypic regression coefficient). A third
analysis searched a grid of CH4 and MBW economic weights (-10 to 10 in steps of 0.5) for the direction with
the largest reduction in CH4 subject to no reduction in MBW. Responses are per generation at a selection
intensity of 1 and are also given at i = 1.7 and per year for an assumed 2.8-year generation interval.

Genetic and phenotypic matrices were assembled from pairwise bivariate animal models (CH4-MBW, CH4-CO2,
MBW-CO2) with trait-specific permanent-environment variances and no permanent-environment covariance between
traits, because a three-trait model could not be fitted with the available memory. Uncertainty was propagated
by Monte Carlo: genetic and residual correlations were drawn on the Fisher-z scale from their standard errors
and heritabilities from normal distributions on their standard errors; variance-component uncertainty other than
heritability was not propagated (the `.pvc` files needed for it are not available). A second parameter set that
takes the MBW and CO2 variances from the MBW-CO2 pair was used as a sensitivity check.

</mark>

<mark>

## Results (proposed text and table)

Genetic correlations were 0.72 (CH4-MBW), 0.57 (CH4-CO2) and 0.83 (MBW-CO2). The partial genetic correlation
between CH4 and CO2 given MBW was -0.07, i.e. CO2 carried essentially no genetic information on methane beyond
what body size already provides.

| Objective | dCH4 (g/d) | dMBW (kg^0.75) | dCO2 (g/d) |
|---|---|---|---|
| Ratio CH4/MBW | -1.13 [-1.32, -0.91] | -0.55 [-0.72, -0.33] | -38.9 [-50.4, -24.0] |
| Residual methane | -1.27 [-1.40, -1.13] | -0.73 [-0.84, -0.62] | -53.3 [-60.3, -44.9] |
| Largest CH4 reduction with MBW change >= 0 | -0.58 [-0.72, -0.46] | +0.02 [0.00, 0.09] | +3.6 [-3.3, 11.0] |

Per generation at i = 1; mean and 95% Monte Carlo interval. At i = 1.7 and a 2.8-year generation interval the
CH4 responses are -0.69 (ratio), -0.77 (residual) and -0.35 (constrained) g/d per year.

With the rebuilt genetic correlation between CH4 and MBW, selecting on either the ratio or the residual is
expected to reduce both body size and CO2 as well as methane. This differs from the conclusion of the
submitted analysis, which used a CH4-MBW genetic correlation near zero and found little penalty in growth;
the earlier index numbers should therefore not be compared with those above. Methane can be reduced without
reducing MBW only by holding MBW constant, and this achieves about half the CH4 reduction of the ratio and
residual objectives, with an uncertain effect on CO2.

</mark>

<mark>

## Limitations (proposed text)

These results are an illustration, not a breeding-programme recommendation. (i) CO2 is used as a
correlated-response indicator, not as an economic trait. Reported genetic correlations of CO2 with dry matter
intake are high in beef cattle and Merino sheep, but weaker for residual feed intake [VERIFY], and the evidence
comes largely from respiration chambers rather than portable accumulation chambers on pasture lambs. Here the
CO2-MBW genetic correlation of 0.83 indicates that CO2 is largely a body-size proxy; in the 346-animal subset
with individual intake records the raw phenotypic correlation of CO2 with DMI was only 0.34 (CH4 0.36, MBW 0.24,
unadjusted), so the intake interpretation is weak. (ii) Genetic and phenotypic matrices were assembled from
pairwise fits and the variance-component uncertainty is only partly propagated. (iii) The objective omits
ewe maintenance costs, fecundity, and the other components of a full sheep breeding objective, as discussed
by Cuyabano et al. (2025) [VERIFY citation details]. (iv) A realistic selection intensity (about 1.7) and a
generation interval (about 2.8 years) change the scale, not the direction, of the responses. (v) Measurement of
methane and CO2 on all candidates, and genomic information, were not modelled.

</mark>

<!-- Open: the submitted paper's second framework (live weight, LW) cannot be rebuilt: it needs weight-CO2 and
CH4-LW bivariate models that have not been fitted. Decide whether to drop it or to request those runs. -->

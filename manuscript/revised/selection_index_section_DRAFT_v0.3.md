# Selection-index demonstration (revision draft v0.3, 2026-09-29)

Reshapes v0.2 (same results, different framing): instead of comparing methane traits against each other, the section
defines the region of genetic response that is biologically favourable and asks which index constructions can reach it and
at what weights. v0.1 and v0.2 are kept as records. Every paragraph is highlighted for the Word export. Numbers come from
`02_selection_index_trivariate.R` and `04_favourable_region.R` in `analysis/revision/selection_index/` (inputs: the single
CH4 x MBW x CO2 trivariate ASReml fit; point estimates, no Monte Carlo). Items marked [VERIFY] are literature claims not
yet checked against the source.

<mark>

## Methods: which indices can reach a favourable region of response?

**Purpose and scope.** This is an illustration of how the construction of a methane index determines the direction of
genetic change, not a bio-economic breeding objective. Feed intake was not measured; feed cost, ewe maintenance,
fecundity, longevity and lamb survival are not modelled (see Limitations).

**Genetic parameters.** Genetic, residual and permanent-environment (co)variances for methane (CH4, g/d), metabolic body
weight (MBW, kg^0.75) and CO2 production (g/d) came from a single three-trait animal model fitted in ASReml to all 15,869
records (each has all three traits), with the fixed effects of the bivariate models, an unstructured 3 x 3 additive
genetic matrix, trait-specific permanent-environment variances and an unstructured residual matrix. It converged in 13
iterations with no parameter at a boundary. The phenotypic matrix was P = G + R + diag(permanent environment).

**Favourable region.** We define the favourable region as the set of genetic responses in which CH4 decreases while MBW
and CO2 do not decrease. CO2 is treated as a candidate proxy for energy expenditure and feed intake [VERIFY]; a decrease in
either MBW or CO2 is read as a cost to the animal or to production. All responses are per generation at a selection
intensity of i = 1, which is what "progress per generation" meant throughout the submitted paper; i = 1.7 and per year
at a 2.8-year generation interval, values typical for sheep programmes, are given in the supplement tables.

**Attainable responses.** For Smith-Hazel indices (b = P^-1 G a, goal weights a) built from all three traits, the
responses attainable at i = 1 form an ellipsoid; its intersection with the favourable region is the set of responses any
linear index can achieve without penalising MBW or CO2. The largest methane reduction inside the region was found by
restricting the index (Kempthorne and Nordskog) so that the responses of the binding traits are exactly zero, and the
corresponding goal weights were recovered as a = G^-1 P b.

**Index constructions compared.** Each was evaluated at its own weights and checked for whether its response falls
inside the region: (1) the ratio CH4/MBW (first-order Taylor expansion at the trait means); (2) residual methane, CH4
regressed on MBW, using the phenotypic coefficient; (3) the same with the genetic coefficient; (4) residual methane from
regression on MBW and CO2 with phenotypic and with genetic coefficients; (5) an unrestricted three-trait Smith-Hazel
index whose weights were chosen to reach the region. Residual traits and the ratio each fix the relative weight on MBW
(beta), so we also scanned beta to find the range that reaches the region.

**Genetic independence of the residual.** The genetic variance of the phenotypic residual and its genetic correlations
with MBW, CH4 and CO2 were calculated from G, and the (residual, MBW) and (CH4, MBW) index forms were compared for the
equivalent goal.

**Sensitivity and measurement.** Because genetic correlations change under selection (Cuyabano et al. 2025 [VERIFY]),
responses were recomputed for CH4-MBW genetic correlations from -0.03 (the submitted value) to 0.80, holding variances
fixed. Information from CH4 alone, CH4 + MBW and CH4 + MBW + CO2 was compared to show the effect of not recording all traits.
Sampling variances of the variance components were not propagated (SE of the CH4-MBW genetic correlation, 0.027).

</mark>

<mark>

## Results

The three-trait model gave heritabilities of 0.27 (CH4), 0.58 (MBW) and 0.41 (CO2) and genetic correlations of 0.69
(CH4-MBW, SE 0.03), 0.57 (CH4-CO2, SE 0.03) and 0.83 (MBW-CO2, SE 0.02). The partial genetic correlation of CH4 and
CO2 given MBW was -0.004, so CO2 carried no genetic information on methane beyond that in body size.

**The favourable region is small.** With CH4 and MBW strongly positively correlated genetically, the favourable region
is a thin wedge (Figure X): MBW responses from 0 to +0.64 kg^0.75 and CH4 responses from 0 to -0.63 g/d per generation.
The most methane that can be removed without lowering MBW or CO2 is -0.63 g/d, about 47% of the -1.34 g/d obtainable
with no constraint at all. That optimum lies on the boundary, with the MBW response exactly zero (CO2 +10 g/d).

**Table X. Where each index construction lands (i = 1).** Goal weight is the weight on MBW relative to CH4 (CH4 = -1),
so beta = 0.64 means the objective is CH4 - 0.64 x MBW. Index weights are on the records (per g CH4/d, per kg^0.75).

| Index construction | Goal weight on MBW (beta) | Index weights (CH4, MBW) | dCH4 | dMBW | dCO2 | In region |
|---|---|---|---|---|---|---|
| Ratio CH4/MBW | 0.81 (fixed by means) | -0.0075, +0.0043 | -0.79 | -0.21 | -16.7 | No |
| Residual on MBW, phenotypic beta | 0.64 | -0.172, -0.002 | -1.10 | -0.64 | -51.2 | No |
| Residual on MBW, genetic beta | 0.83 | -0.164, +0.105 | -0.75 | -0.16 | -12.5 | No |
| Residual on MBW + CO2, phenotypic | 0.42 (CO2 0.37 per 100 g/d) | -0.186, -0.013 | -0.87 | -0.32 | -9.8 | No |
| Residual on MBW + CO2, genetic | 0.83 (CO2 -0.006 per 100 g/d) | -0.173, +0.073 | -0.71 | -0.09 | +2.0 | No |
| Three-trait index, weights chosen to reach the region | 0.86 (CO2 0) | -0.173, +0.088 | -0.63 | 0.00 | +10.0 | Yes |
| CH4 + MBW index, weights chosen to reach the region | 0.88 | -0.162, +0.134 | -0.61 | 0.00 | +0.1 | Yes |

(The two residual-on-MBW+CO2 rows and the three-trait row also use CO2 as an information trait, with index weights on CO2 of
0.0012, 0.0006 and 0.0007 per g/d respectively; all other rows use CH4 and MBW only.)

1. **Weights needed.** With CH4 and MBW as information traits the region is reached only when the goal weight on MBW is
   between 0.89 and 1.11 times the weight on CH4, i.e. roughly equal weight on a g/d of methane and a kg^0.75 of MBW.
2. **A ratio trait cannot be tuned to reach it.** The ratio's implied weight on MBW is the ratio of the trait means
   (17.9 / 22.1 = 0.81), fixed by the population rather than chosen; it falls short of 0.89, so the ratio reduces MBW
   (-0.21) and CO2 (-16.7 g/d) along with methane. It would reach the region only if the mean ratio exceeded 0.89 at
   these genetic parameters.
3. **Residual traits can reach it only through their coefficient.** The phenotypic coefficient (0.64) is well below
   0.89, and reduces MBW by 0.64; the genetic coefficient (0.83) lies just below it and reduces MBW by 0.16. Adding CO2
   to the regression does not change the picture. A residual trait defined by a coefficient of about 0.9 to 1.1 would
   enter the region, but that coefficient is a choice of economic weight, not a property of the data.
4. **The phenotypic residual is not genetically independent of body weight (Reviewer 2, line 499).** Its genetic
   correlation with MBW is 0.22 (with CH4 0.85, CO2 0.18), heritability 0.17. The (residual, MBW) and (CH4, MBW) forms
   of the index give identical responses (difference < 1e-8) but different index weights (-0.17, -0.11 versus -0.17,
   -0.002), so weights on a residual trait cannot be read as an economic weighting of MBW.
5. **CO2 adds almost nothing as an information trait.** Adding CO2 to CH4 + MBW raised index accuracy from 0.636 to
   0.637 (unconstrained) and from 0.291 to 0.300 (MBW held constant); also holding CO2 at zero cost 3% of the response
   (-0.631 to -0.610 g/d). CH4 alone gave accuracy 0.52 and -1.10 g/d, with MBW falling by 0.63.
6. **Dependence on the genetic correlation.** Where each construction lands depends on rg(CH4, MBW) (Table Y). The
   ratio's MBW response changes sign at rg of about 0.63, against an estimate of 0.69 (SE 0.03); at lower correlations
   (0.40 and the submitted -0.03) it raises MBW, while the phenotypic residual still lowers MBW at 0.40 (-0.12). The
   ratio's exclusion from the region is therefore a statement about this population's estimated correlation, not a
   general property of ratio traits. (The region's boundaries were computed only at the estimated correlation.)

**Table Y. Sensitivity to the CH4-MBW genetic correlation (i = 1, two-trait index).**

| rg (CH4, MBW) | Ratio: dCH4 / dMBW | Residual: dCH4 / dMBW | MBW held constant: dCH4 |
|---|---|---|---|
| -0.03 (submitted) | -0.84 / +1.01 | -1.09 / +0.40 | -1.10 |
| 0.40 | -0.60 / +0.54 | -1.01 / -0.12 | -0.95 |
| 0.60 | -0.66 / +0.11 | -1.04 / -0.45 | -0.74 |
| 0.69 (estimate) | -0.79 / -0.21 | -1.10 / -0.64 | -0.61 |
| 0.80 | -1.08 / -0.72 | -1.24 / -0.92 | -0.43 |

(-0.03 row: trivariate variances with the submitted correlation, so not the submitted numbers.)

**Figure X.** Responses attainable per generation by any linear index of CH4, MBW and CO2 (grey) and the favourable
region in which CH4 decreases while MBW and CO2 do not (green); `tri_favourable_region.png`.

</mark>

<mark>

## Limitations (proposed text)

These results illustrate how index construction determines the direction of response; they are not a breeding-programme
recommendation. (i) **The objective is not a farm economic model.** It omits feed cost per unit of intake, ewe maintenance
(about 70% of flock feed use), fecundity, longevity and lamb survival, and the relationships of these with methane are
unknown here; the favourable region is defined by the biological criterion of not lowering MBW or CO2. (ii) **Selection
intensity and generation interval.** Responses are at i = 1 unless stated; at i = 1.7 and 2.8 years they are scaled, which
changes size, not direction. (iii) **Measurement and accuracy.** In practice not all animals are measured for all traits,
measurement differs between sexes and progeny, and genomic information is used partially and with varying accuracy; the
measurement scenarios above show only the effect of dropping traits at fixed accuracy, and results should not be
extrapolated directly to a real flock. (iv) **Smith-Hazel is an approximation** whose validity erodes as selection changes
genetic variances and correlations; Cuyabano et al. (2025) [VERIFY citation details] document this, and the sensitivity to
the CH4-MBW correlation (Table Y) is one illustration. (v) **CO2 as an intake proxy.** Reported genetic correlations of CO2
with dry matter intake are high in beef cattle and Merino sheep but weaker for residual feed intake [VERIFY], mostly from
respiration chambers rather than portable accumulation chambers on pasture lambs. Here CO2 was largely a body-size proxy
(genetic correlation with MBW 0.83; partial correlation with CH4 given MBW about 0), and in the 346-animal subset with
individual intake records the raw phenotypic correlation of CO2 with intake was only 0.34 (unadjusted). (vi) **Uncertainty.**
Sampling variances of the variance components were not propagated, so the point estimates carry no interval; the
boundaries of the region and the coefficient range of 0.89 to 1.11 are therefore approximate.

</mark>

<!-- Reviewer map (not for the manuscript).
R1(b) trait/index vs economic model, intake proxy: scope statement, Limitations i, v; CO2 information-trait scenario (Results 5).
R1(c) i = 1 explicit, i = 1.7 and per year in the supplement; partial measurement / genomic accuracy: Methods, Results 5, Limitations
   ii, iii. Cuyabano et al. 2025: Limitations iv, Results 6, Table Y (citation to be verified).
R2 (CO2 as its own trait): trivariate model, Results first paragraph.
R2 line 499 (phenotypic residual not genetically independent): Results 3, 4.
Open: the submitted paper's second framework (live weight, LW) is not rebuilt (needs weight-CO2 and CH4-LW models).
Table X numbers were checked against results/tri_region_weights_responses.csv; Table Y is carried over unchanged from v0.2.
Region boundaries (MBW 0 to 0.64, CH4 0 to -0.63) are from 04_favourable_region.R's sampled ellipsoid (2e6 draws, checked
against the analytic maximum).
-->

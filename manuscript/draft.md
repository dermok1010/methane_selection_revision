<!--
Working draft of the submitted manuscript "Genetic Parameters and Selection
Responses for Alternative Methane Trait Definitions in Pasture-Based Sheep"
(GSEV-D-26-00126, Genetics Selection Evolution) -- for reading through and
dictating revision changes against, the same workflow used for the
rumen-core manuscript.

Source: manuscript/submitted/Methane_Genetic_Selection_Response_DK_Fnl.docx
(frozen, untouched -- do not edit, per this repo's CLAUDE.md). This file is
a faithful reconstruction of that docx's text and tables. Two deliberate
layout differences from the submitted file: Table 3 (correlations among
methane trait definitions) is placed inline after the "Correlations among
methane traits" section rather than at the very end of the document, and
section-heading levels have been normalised to standard markdown -- neither
changes any wording, number, or table content.

No numbers, wording, or scientific content have been changed from the
submitted version yet -- this is a read-through copy, not a revision. Track
changes via git history on this file: each applied round of edits is a
separate commit, so `git log -- manuscript/draft.md` is the changelog.

Reviewer comments (reviews/GSEV-D-26-00126_reviewer_comments.txt) and their
current addressed/open status (from docs/revision_plan.md's decision log)
are overlaid separately in the artifact used to read this draft -- they are
not reproduced in this file, to keep this file a clean manuscript copy.
-->

# Genetic Parameters and Selection Responses for Alternative Methane Trait Definitions in Pasture-Based Sheep

Dermot J. Kelly ²'³'*, Fiona McGovern ¹, Deirdre Purfield ², Patrick McCarron ¹, Eoin Dunne ¹, Thierry Pabiou ⁴, Nóirín McHugh ³

¹ Teagasc, Animal & Grassland Research and Innovation Centre, Mellows Campus, Athenry, Co. Galway, H65 R718, Ireland
² Department of Biological Sciences, Munster Technological University, Bishopstown, Co. Cork T12 P928, Ireland
³ Teagasc, Animal and Grassland Research and Innovation Centre, Fermoy, Co. Cork P61 P302, Ireland
⁴ Sheep Ireland, Link Road, Ballincollig, Co. Cork, P31 D452, Ireland

*Corresponding author. Email: dermot.kelly@teagasc.ie

## Abstract

**Background.** Enteric methane from ruminants represents a major challenge for environmentally sustainable livestock production. Genetic selection can deliver long-term and cumulative reductions in emissions; however, methane production is positively correlated with key performance traits such as body size and growth. Alternative methane definitions, including ratio- and residual-based definitions, have therefore been proposed. The objectives of this study were to estimate genetic parameters for a range of methane trait definitions in sheep and determine their consequences for selection response.

**Results.** A total of 16,535 methane (CH4) records from 8,354 sheep across 132 Irish flocks were analysed. Alternative methane traits were defined as ratios of methane relative to metabolic body weight (MBW), average daily gain (ADG), muscle mass and rumen volume. Methane production showed weak to moderate heritability across all trait definitions examined (h² = 0.08–0.34). Although alternative methane definitions were often genetically correlated, these correlations were not uniform (rg = 0.23–0.99). Genetic correlations with production traits also varied by methane definition. Selection index analyses showed that selection on CH₄/MBW reduced methane by 0.56 ± 0.07 g day⁻¹ per generation while maintaining favourable responses in MBW (+0.48 ± 0.08 kg) and ADG (+4.96 ± 1.60 g day⁻¹), whereas residual methane achieved a larger methane reduction (−0.68 ± 0.06 g day⁻¹) but with an unfavourable ADG response (−2.65 ± 1.26 g day⁻¹). When CH₄ and MBW were included as separate goal traits in a linear selection index, a wider range of responses was achievable, including comparable methane reductions (−0.66 ± 0.06 g day⁻¹) while maintaining favourable MBW response and approximately neutral ADG response.

**Conclusions.** Methane production in sheep exhibits meaningful additive genetic variation across alternative trait definitions. Although many definitions capture overlapping genetic signals, some altered the direction and magnitude of correlated responses in performance traits, indicating that methane definition choice influences the balance between methane reduction, body size, and growth. The choice of methane definition should therefore be viewed as a critical breeding decision, shaping both the effectiveness of methane reduction and the distribution of genetic gain across production traits.

## Background

Reducing greenhouse gas emissions from ruminant livestock has become a priority for greenhouse gas mitigation strategies worldwide. Enteric fermentation alone contributes approximately 30% of global anthropogenic methane emissions [1], making it one of the largest and most challenging emission sources to address [2]. At the same time, rising global demand for animal-sourced protein places increasing pressure on ruminant production systems to deliver sustained reductions in emissions without compromising productivity [3]. The trade-off between greenhouse gas mitigation and food production is particularly evident in grass-based systems, such as Ireland, where agriculture is the largest single sector source of national greenhouse gas emissions, with methane from enteric fermentation in cattle and sheep the dominant contributing gas [4]. Concurrently, despite this high sectoral methane output, Ireland ranks among the most carbon-efficient regions globally for ruminant production when evaluated on a per-kilogram-of-product basis [5, 6]. This places particular emphasis on mitigation strategies capable of delivering sustained reductions in enteric methane emissions without reducing productivity or altering the fundamental structure of pasture-based systems.

Genetic selection for low-emitting animals has emerged as one of the most promising methane mitigation strategies, with moderate heritability reported for methane production [7] and the cumulative, permanent nature of genetic gain [8]. The recent development of high-throughput phenotyping technologies, most notably portable accumulation chambers (PACs), has enabled routine, large-scale collection of individual-animal methane phenotypes across both research and commercial flocks [9, 10]. However, methane production has been shown to have strong (positive) genetic and phenotypic correlations with key production traits such as body weight, growth, and feed intake [11, 12]. As a result, direct selection for reduced absolute methane emissions risks inadvertently constraining animal performance.

Throughout this study, methane production and methane emission refer specifically to enteric methane released via eructation during rumen fermentation, as captured by PAC measurement, rather than emissions from manure management. The development of alternative methane trait definitions enables these emissions to be quantified independently of production. Metrics such as methane intensity, methane yield, and residual methane express emissions relative to an animal's metabolic demands or level of performance [12, 13]. These traits can identify animals that emit less methane than expected for their level of productivity and have therefore been proposed as a potential means of mitigating unfavourable genetic correlations between methane production and key production traits [14]. Phenotypic analyses have shown that these alternative methane metrics can differ substantially in their relationships with production traits and with each other [15]. However, both ratio and residual methane traits present known theoretical limitations when incorporated into selection indices, and as noted by Lassen and Difford [16], the extent to which these alternative definitions lead to meaningfully different selection outcomes requires further empirical evaluation. The present study addresses this gap directly by quantifying the heritability and genetic relationships among alternative methane trait definitions in sheep and evaluating how these definitions influence predicted selection responses within a selection index framework.

## Methods

### Gaseous emissions data

A total of 16,535 methane measurements were obtained from 8,354 sheep across 132 research and commercial flocks in Ireland between 2019 and 2025. Methane measurements were recorded using PACs following the protocol described by O'Connor et al. [9]. Animals were removed from feed at least one hour prior to measurement. Each animal was then randomly assigned to one of twelve PAC units. Once the chamber was sealed, gas concentrations were measured at entry and again after a 50-minute accumulation period using an RKI Eagle 2 gas monitor (Weatherall Equipment and Instruments Ltd., UK). Concentration changes for methane (CH₄) and carbon dioxide (CO₂) were converted to daily output (g day⁻¹) using chamber-specific calibration equations.

Methane (g day⁻¹) and carbon dioxide production (g day⁻¹) measurements were first screened for outliers using a 1.5 × interquartile range criterion applied separately to both gases (n = 511 (3.09%) gaseous records removed). All gaseous records were assigned to a contemporary group of date of measurement, flock, and PAC measurement group (i.e., the same 12 animals measured at the same time-point). Only contemporary groups with at least 5 animals were retained, leaving 15,869 records from 8,185 animals.

Measurements were collected across multiple physiological stages, including lambs (both sexes, 63 to 365 days of age; 5,564 records from 3,034 animals), hoggets (nulliparous females aged 365 to 600 days; 1,812 records from 1,271 animals), and mature ewes (females with a recorded lambing event aged 431 days to 10.5 years; 7,828 records from 4,327 animals). A total of 25.40% of animals had multiple methane records both within or across physiological stages.

### Additional phenotypic data

Additional phenotypic measurements were available for animals with methane records; these included live weight, average daily gain (ADG), muscle mass, and rumen volume, and were used to derive alternative methane traits.

**Live weight.** Live weight was recorded immediately prior to PAC measurement using a Prattley electronic weighing scale (O'Donovan Engineering Co. Ltd., Cork, Ireland) and was subjected to outlier removal (1.5 × interquartile range criterion). Metabolic body weight (live weight^0.75) was also derived for each animal. A total of 15,638 records from 8,002 animals were available for analysis.

**Average daily gain.** Average daily gain was derived for growing animals only (i.e. animals <660 days of age). All individual animal live weight records were obtained from the national sheep database operated by Sheep Ireland. For each methane measurement, live weights recorded within ±120 days of the PAC measurement date were considered. Average daily gain surrounding each methane measurement was estimated by fitting a linear regression of live weight on age in days, with the regression slope retained as the estimate of ADG (kg day⁻¹). A total of 4,316 ADG estimates were available from 2,658 growing animals after outlier removal (1.5 × interquartile range criterion).

**Rumen volume and muscle mass.** Individual animal computed tomography (CT) scan measurements taken within ±3 days of methane measurement were also available on a subset of animals. Computed tomography provides in vivo estimates of carcass tissue composition by classifying pixels in cross-sectional X-ray images according to their density, allowing fat, muscle and bone tissues to be quantified non-invasively as described by Clelland et al. [17]. From these scans, estimates of rumen volume (litres) and muscle mass (kg) were available. Following outlier screening (1.5 × interquartile range criterion), 766 CT measurements were available for both rumen volume (746 animals) and muscle mass (751 animals).

**Additional data.** Auxiliary data relating to animal age, breed composition, animal heterosis and recombination loss, and birth and rearing type were also available. The breed proportion of each animal for the six breeds with the greatest number of methane phenotypes (i.e., Belclare, Charolais, Cheviot, Suffolk, Lleyn, and Texel) was also calculated. The general heterosis and recombination loss coefficients for each animal were also included [18, 19], where sire_i and dam_i are the proportion of breed i in the sire and dam, respectively. For all growing animals the birth litter size (defined as whether the lamb was born as a single, twin, triplet or quadruplet), rearing litter size (defined as whether the lamb was reared as a single, twin or triplet), and dam parity (defined as 1, 2, 3, 4, 5, 6 or ≥7) were available. For ewes the birth and rearing type corresponding to the litter born to the ewe for the year of measurement were also available.

### Methane trait definitions

A suite of methane traits was constructed to represent alternative approaches to quantifying emissions (i.e., alternative to absolute, daily methane production), consisting of absolute traits, ratio-based traits, and residual traits (Table 1).

**Absolute methane production.** Methane production (CH4) measured in g day⁻¹ represented the total mass of methane emitted per animal per day based on PAC measurement.

**Ratio-based methane traits.** For all animals two ratio traits, representing methane intensity (CH4/MBW; methane per kg metabolic body weight) and methane as a proportion of total methane and carbon dioxide production (CH4 ratio), were calculated. For growing animals only, an additional three ratio traits were also computed: methane per kg of average daily gain (CH4/ADG), methane per kg muscle mass (CH4/MM), and methane per litre rumen volume (CH4/rumen). Here, CH₄ represents methane production measured in grams per day; CO₂ represents carbon dioxide production measured in grams per day; metabolic body weight is live weight^0.75 (kg); ADG is average daily gain (kg day⁻¹); MM is muscle mass (kg) derived from CT measurements; and rumen volume (litres) is the CT-derived estimate of rumen volume.

**Residual methane traits.** Three residual methane traits (RMT) were derived: methane adjusted for metabolic body weight (RMTMBW), methane adjusted for metabolic body weight and carbon dioxide production (RMTMBW+CO2), and methane adjusted for average daily gain (RMTADG; calculated in growing animals only). Residual methane traits were generated by regressing daily methane production (g day⁻¹) on the production trait of interest (metabolic body weight, carbon dioxide production; and where available, average daily gain). The residuals from each regression were extracted and used as the phenotype for the corresponding residual methane trait.

### Genetic analysis

Variance components for all alternative methane traits were estimated using pedigree-based animal models fitted in ASReml [20]. Pedigree records were available for 330,812 animals and were used to define the additive genetic relationships among animals. All methane traits were analysed using the following linear mixed animal model:

> y = μ + sex + BR + CL + CV + LY + SU + TX + het + rec + age + BTg + RTg + BTe + RTe + DP + CG + a + pe

where y was the phenotypic observation for the methane trait under analysis; μ was the overall mean; sex was the fixed class effect of sex (male or female); the fixed effects for breed proportion corresponding to Belclare (BR), Charolais (CL), Cheviot (CV), Lleyn (LY), Suffolk (SU), and Texel (TX) were included as covariates; het was the heterosis coefficient; rec was the recombination loss coefficient; age was the age at measurement (weeks of age); BTg was the fixed class effect of birth litter size of the growing animal itself (single, twin, triplet or quadruplet); RTg was the fixed class effect of rearing litter size of the growing animal itself (single, twin or triplet); BTe was the fixed class effect of birth litter size recorded for the ewe in the year of measurement (single, twin, triplet or quadruplet); RTe was the fixed class effect of rearing litter size recorded for the ewe in the year of measurement (single, twin or triplet); DP was the fixed class effect of dam parity for growing animals; CG was the contemporary group fixed class effect of flock-date-lot of measurement; a was the random animal additive genetic effect; pe was the non-additive random animal permanent environmental effect; and e was the residual random error term, where A was the numerator relationship matrix, I was the identity matrix, σ²ₐ was the direct additive genetic variance, σ²ₚₑ was the animal permanent environmental variance, and σ²ₑ was the residual variance.

This model described above was used for both univariate and bivariate analyses. Bivariate models were fitted to estimate the phenotypic and genetic correlations between (i) methane traits according to their definition/construction, and (ii) between methane traits and production traits (metabolic body weight, live weight, average daily gain, muscle mass, and rumen volume). When CH4/MM and CH4/rumen were the dependent variables the repeated animal effect was omitted from the model due to small numbers of repeated records. Fixed-effect significance (Wald F-tests) and diagnostics of pedigree completeness, connectedness, and contemporary-group confounding are reported in Supplementary Material S1.

### Selection index methodology

To evaluate the impact of selection on alternative methane trait definitions, linear selection indices were constructed using Smith-Hazel index theory [21]. Two selection frameworks were evaluated: (i) CH₄ and metabolic body weight (MBW) included as goal traits, and (ii) CH₄ and live weight (LW) included as goal traits. In both frameworks, average daily gain (ADG) was included as a correlated trait with zero economic weighting. The MBW-based framework was used to evaluate methane intensity (CH₄/MBW) and residual methane adjusted for MBW, while the LW-based framework was used to evaluate methane intensity (CH₄/LW) and residual methane adjusted for LW.

Additive genetic (G) and phenotypic (P) variance–covariance matrices for CH₄, the relevant weight trait and ADG were constructed from variance components and correlations estimated in the animal models described above. Within each framework, G and P remained fixed throughout the analysis.

To generate the range of possible selection responses, a comprehensive grid of breeding goal vectors, **a**, was constructed by varying the relative emphasis placed on CH₄ and the relevant weight trait. Weightings for both traits were varied from −10 to +10 in increments of 0.5, producing 1,680 alternative breeding goal vectors. For each breeding goal vector, Smith–Hazel index weights (**b**) were calculated, and predicted genetic responses (Δg) were scaled to unit selection intensity (i = 1).

The resulting response vectors defined the feasible response region in (ΔCH₄, Δweight trait) space, with the outer boundary representing the efficient trade-off between the two traits. Selection intensity (i = 1) acts only as a scalar multiplier in this analysis and therefore does not affect the relative trade-offs among traits.

The ratio traits were linearised using a first-order Taylor expansion evaluated at the observed trait means, thereby approximating the nonlinear ratio as an equivalent linear combination of CH₄ and the relevant weight trait for use within the selection index framework [22]. Residual methane was implemented as a linear objective of the form CH₄ − β·weight, where β was derived from the phenotypic covariance structure as β = Cov(CH₄, weight)/Var(weight), analogous to the residual feed intake framework [23]. Selection to decrease residual methane therefore corresponds to a breeding goal vector proportional to (−1, β).

Uncertainty in predicted responses was quantified by Monte Carlo propagation (1,000 draws), repeatedly sampling variance components and genetic correlations from their approximate sampling distributions based on ASReml reported standard errors, with uncertainty reported as the Monte Carlo standard deviation and 95% uncertainty interval. All computations were implemented in R version 4.2.3 [24] using the Matrix package version 1.5.3 [25], dplyr package version 1.1.1 [26], and tidyr package version 1.3.0 [27].

## Results

The mean MBW was 22.10 (SD = 4.92) kg, mean live weight was 62.72 (SD = 18.18) kg, while mean ADG, muscle mass, and rumen volume were 0.18 (SD = 0.10) kg day⁻¹, 11.7 (SD = 3.24) kg, and 6.16 (SD = 1.49) l, respectively. Descriptive statistics for methane traits are presented in Table 1. Mean methane production was 17.9 (SD = 7.56) g day⁻¹, with methane intensity (CH₄/MBW) averaging 0.81 (SD = 0.29) g kg⁻¹ day⁻¹. Methane expressed relative to average daily gain (CH₄/ADG) had a mean of 137.9 (SD = 189.3) g kg⁻¹ day⁻¹, reflecting the small denominator in this ratio trait. The mean values for methane traits derived from CT measurements were 1.44 (SD = 0.48) g kg⁻¹ day⁻¹ for CH₄/MM and 2.69 (SD = 0.88) g l⁻¹ day⁻¹ for CH₄/rumen. Residual methane traits were centred around zero by construction, with phenotypic standard deviations of 6.53 g day⁻¹ for RMTMBW, 5.32 g day⁻¹ for RMTMBW+CO2, and 4.75 g day⁻¹ for RMTADG.

**Table 1. Descriptive statistics for alternative methane trait definitions.**

| Trait group | Trait | No. records | No. animals | μ (SD) | Range |
|---|---|---|---|---|---|
| Absolute | CH4 | 15,869 | 8,185 | 17.90 (7.56) | 4.01 – 40.31 |
| Ratio | CH4/MBW | 15,638 | 8,002 | 0.81 (0.29) | 0.14 – 2.38 |
| | CH4 ratio | 15,869 | 8,185 | 0.02 (0.01) | 0.00 – 0.19 |
| | CH4/ADG | 4,316 | 2,658 | 137.89 (189.27) | 12.03 – 2058.33 |
| | CH4/MM | 766 | 751 | 1.44 (0.48) | 0.33 – 3.08 |
| | CH4/rumen | 766 | 746 | 2.69 (0.88) | 0.65 – 5.73 |
| Residual | RMTMBW | 15,638 | 8,002 | 0.00 (6.53) | -20.48 – 21.33 |
| | RMTMBW+CO2 | 15,638 | 8,002 | 0.00 (5.32) | -23.38 – 24.15 |
| | RMTADG | 4,316 | 2,658 | 0.00 (4.75) | -10.23 – 25.82 |

*CH₄ is daily methane output in grams per day; CH₄/MBW is methane intensity, expressed as CH₄ per kg of metabolic body weight; CH₄ ratio is the ratio of methane to methane and carbon dioxide production; CH₄/ADG is methane per kg of average daily gain; CH₄/MM is methane per kg muscle mass derived from computed tomography; CH₄/rumen is methane per litre rumen volume derived from computed tomography; RMTMBW, RMTMBW+CO2, RMTADG are residual methane traits derived from regression of CH₄ on metabolic body weight, metabolic body weight and carbon dioxide, and average daily gain, respectively.*

### Genetic parameters

Genetic parameters for methane trait definitions are presented in Table 2. Genetic standard deviations ranged from 0.06 g kg⁻¹ day⁻¹ for methane intensity (CH₄/MBW) to 43.50 g kg⁻¹ day⁻¹ for methane expressed relative to growth rate (CH₄/ADG), with corresponding genetic coefficient of variation (CVa) values of 7.41% and 31.55%, respectively. Methane production (CH₄) had a genetic standard deviation of 1.63 g day⁻¹ and CVa of 9.1%. The genetic standard deviation for methane expressed relative to muscle mass and rumen volume were 0.17 g kg⁻¹ day⁻¹ and 0.38 g l⁻¹ day⁻¹ with CVa values of 11.81% and 11.52%, respectively. Residual methane traits (RMTMBW, RMTMBW+CO2, and RMTADG) had genetic standard deviations of 1.40, 1.55, and 1.30 g day⁻¹, while CH₄ ratio displayed the lowest genetic variation of all traits (σa = 1.24×10⁻³; CVa = 0.24%).

Heritability estimates ranged from 0.08 ± 0.02 for CH₄ ratio to 0.34 ± 0.12 for CH₄/MM (Table 2). Heritability estimates for CH₄ g day⁻¹ (0.17 ± 0.03), CH₄/MBW (0.15 ± 0.02), CH₄/ADG (0.17 ± 0.05), and residual methane traits of RMTMBW (0.14 ± 0.02), RMTMBW+CO2 (0.16 ± 0.03) and RMTADG (0.20 ± 0.07) were broadly similar. Methane expressed relative to muscle mass and rumen volume produced larger heritability estimates (0.34 ± 0.12 and 0.29 ± 0.13), although both were associated with larger standard errors. Repeatability estimates ranged from 0.09 ± 0.007 (CH₄ ratio) to 0.35 ± 0.01 (RMTMBW+CO2).

**Table 2. Genetic parameters for alternative methane trait definitions.**

| Trait group | Trait | σa | σpe | h² (SE) | t | CVa |
|---|---|---|---|---|---|---|
| Absolute | CH4 | 1.62 (0.13) | 1.46 (0.14) | 0.17 (0.03) | 0.31 (0.01) | 9.05% |
| Ratio | CH4/MBW | 0.06 (0.01) | 0.06 (0.01) | 0.15 (0.02) | 0.28 (0.01) | 7.41% |
| | CH4 ratio | 1.24×10⁻³ (1.23×10⁻⁴) | 5.05×10⁻⁴ (2.90×10⁻⁴) | 0.08 (0.02) | 0.09 (0.01) | 0.24% |
| | CH4/ADG | 43.50 (7.81) | 36.30 (9.08) | 0.17 (0.05) | 0.29 (0.02) | 31.55% |
| | CH4/MM | 0.17 (0.03) | – | 0.34 (0.12) | – | 11.81% |
| | CH4/rumen | 0.38 (0.07) | – | 0.29 (0.13) | – | 11.52% |
| Residual | RMTMBW | 1.40 (0.12) | 1.40 (0.13) | 0.14 (0.02) | 0.28 (0.01) | – |
| | RMTMBW+CO2 | 1.55 (0.12) | 1.65 (0.12) | 0.16 (0.03) | 0.35 (0.01) | – |
| | RMTADG | 1.30 (0.21) | 0.54 (0.50) | 0.20 (0.07) | 0.24 (0.03) | – |

*σₐ = direct genetic standard deviation; σₚₑ = animal permanent environmental standard deviation; h² = heritability; t = repeatability; CVₐ = coefficient of genetic variation. Standard errors are shown in parentheses. Trait abbreviations as in Table 1.*

### Correlations among methane traits

Phenotypic and genetic correlations among methane trait definitions are presented in Table 3. Phenotypic correlations were generally strong and positive among size-adjusted traits, with methane intensity showing the strongest phenotypic correlation with methane production (0.87 ± 0.003), and weaker phenotypic correlations observed between methane production and both CH₄/ADG (0.30 ± 0.02) and CH₄ ratio (0.46 ± 0.007).

Methane production (CH₄) showed strong positive genetic correlations with methane intensity (0.87 ± 0.02) and CH₄/MM (0.85 ± 0.07). In contrast, CH₄ showed only a weak genetic correlation with CH₄/ADG (0.23 ± 0.06). A strong positive genetic correlation was observed between methane intensity and CH₄/MM (0.86 ± 0.04), but only a weak genetic correlation between methane intensity and CH₄/ADG (0.18 ± 0.06). Methane per litre of rumen volume (CH₄/rumen) showed a moderate genetic correlation with methane intensity (0.51 ± 0.18). Methane as a proportion of total gas production (CH₄ ratio) exhibited moderate to strong genetic correlations with several size-adjusted methane definitions, including methane intensity (0.85 ± 0.04), and CH₄ (0.73 ± 0.05). Residual methane traits showed weak to moderate genetic correlations with absolute methane production (0.26–0.55); the genetic correlation between the residual traits ranged from 0.55 ± 0.07 between RMTMBW+CO2 and RMTADG to 0.77 ± 0.03 between RMTADG and RMTMBW.

**Table 3. Genetic (above diagonal) and phenotypic (below diagonal) correlations among alternative methane trait definitions.**

| | CH4 | CH4/MBW | CH4 ratio | CH4/ADG | CH4/MM | CH4/rumen | RMTMBW | RMTMBW+CO2 | RMTADG |
|---|---|---|---|---|---|---|---|---|---|
| CH4 | | 0.87 (0.02) | 0.73 (0.05) | 0.23 (0.06) | 0.85 (0.07) | 0.65 (0.11) | 0.55 (0.06) | 0.40 (0.07) | 0.26 (0.48) |
| CH4/MBW | 0.87 | | 0.85 (0.04) | 0.18 (0.06) | 0.86 (0.04) | 0.51 (0.14) | 0.55 (0.06) | 0.86 (0.02) | 0.81 (0.03) |
| CH4 ratio | 0.46 | 0.53 | | – | 0.44 (0.19) | 0.27 (0.20) | 0.82 (0.04) | – | 0.71 (0.07) |
| CH4/ADG | 0.30 | 0.24 | – | | 0.57 (0.17) | 0.40 (0.17) | 0.30 (0.06) | 0.24 (0.06) | 0.04 (0.06) |
| CH4/MM | 0.87 | 0.85 | 0.69 | 0.48 | | 0.49 (0.18) | 0.82 (0.04) | 0.79 (0.07) | 0.99 (0.08) |
| CH4/rumen | 0.67 | 0.63 | 0.49 | 0.38 | 0.62 | | 0.79 (0.09) | 0.62 (0.11) | 0.37 (0.28) |
| RMTMBW | 0.78 | 0.78 | 0.50 | 0.32 | 0.91 | 0.70 | | 0.62 (0.05) | 0.77 (0.03) |
| RMTMBW+CO2 | 0.66 | 0.82 | – | 0.26 | 0.83 | 0.60 | 0.71 | | 0.55 (0.07) |
| RMTADG | 0.66 | 0.89 | 0.32 | 0.23 | 0.85 | 0.58 | 0.82 | 0.72 | |

*Standard error of all phenotypic correlations ≤0.07. Trait abbreviations as in Table 1.*

### Correlations between methane and production traits

Phenotypic and genetic correlations between methane traits and production traits are presented in Tables 4 and 5, respectively. Phenotypically, CH₄ showed weak to moderate positive correlations with the production traits examined, including metabolic body weight (MBW; 0.08 ± 0.02), live weight (LW; 0.26 ± 0.02), ADG (0.19 ± 0.02), rumen volume (0.20 ± 0.05), and muscle mass (0.07 ± 0.05). As expected, several ratio-based methane traits showed negative phenotypic correlations with the denominator production traits, including methane intensity (CH₄/MBW) with MBW (−0.10 ± 0.01), CH₄/MM with muscle mass (−0.24 ± 0.04), and CH₄/rumen with rumen volume (−0.46 ± 0.03). Residual methane traits showed contrasting patterns, with RMTMBW negatively phenotypically correlated with MBW (−0.24 ± 0.01), whereas RMTADG showed a positive phenotypic correlation with MBW (0.17 ± 0.03).

**Table 4. Phenotypic correlations between methane traits and production traits (standard errors in parentheses).**

| Trait group | Trait | Metabolic body weight | Live Weight | Average daily gain | Muscle mass | Rumen volume |
|---|---|---|---|---|---|---|
| Absolute | CH₄ | 0.08 (0.02) | 0.26 (0.02) | 0.19 (0.02) | 0.07 (0.05) | 0.20 (0.05) |
| Ratio | CH4/MBW | -0.10 (0.01) | -0.10 (0.01) | -0.11 (0.02) | -0.04 (0.04) | 0.13 (0.04) |
| | CH₄ ratio | -0.06 (0.01) | – | -0.01 (0.02) | -0.06 (0.04) | 0.19 (0.04) |
| | CH₄/ADG | -0.00 (0.02) | -0.02 (0.02) | – | 0.26 (0.05) | 0.20 (0.05) |
| | CH₄/MM | -0.09 (0.05) | -0.06 (0.05) | 0.01 (0.05) | -0.24 (0.04) | 0.13 (0.04) |
| | CH₄/rumen | – | 0.04 (0.05) | 0.00 (0.05) | -0.03 (0.04) | -0.46 (0.03) |
| Residual | RMTMBW | -0.24 (0.01) | -0.16 (0.01) | 0.02 (0.02) | -0.13 (0.05) | 0.07 (0.05) |
| | RMTMBW+CO2 | -0.21 (0.02) | -0.12 (0.01) | 0.02 (0.02) | – | – |
| | RMTADG | 0.17 (0.03) | 0.47 (0.02) | 0.02 (0.01) | 0.21 (0.08) | 0.21 (0.08) |

*Trait abbreviations as in Table 1.*

Genetically, CH₄ showed a near-zero correlation with metabolic body weight (MBW; −0.03 ± 0.08), but moderate positive genetic correlations with ADG (0.41 ± 0.05), live weight (0.50 ± 0.03), and rumen volume (0.68 ± 0.29). Ratio-based methane traits were generally negatively genetically correlated with the denominator production traits, including methane intensity (CH₄/MBW) with MBW (−0.27 ± 0.04), CH₄/MM with muscle mass (−0.39 ± 0.19), and CH₄/rumen with rumen volume (−0.35 ± 0.26). Methane ratio showed weak to moderate negative genetic correlations with MBW (−0.21 ± 0.04), ADG (−0.04 ± 0.06), and muscle mass (−0.23 ± 0.19). Among the residual methane traits, RMTMBW showed a strong negative genetic correlation with MBW (−0.69 ± 0.06) and a near-zero genetic correlation with ADG (0.01 ± 0.05), whereas RMTADG showed a moderate positive genetic correlation with MBW (0.31 ± 0.11).

**Table 5. Genetic correlations between methane traits and production traits (standard errors in parentheses).**

| Trait group | Trait | Metabolic body weight | Live weight | Average daily gain | Muscle mass | Rumen volume |
|---|---|---|---|---|---|---|
| Absolute | CH4 | -0.03 (0.08) | 0.50 (0.03) | 0.41 (0.05) | – | 0.68 (0.29) |
| Ratio | CH4/MBW | -0.27 (0.04) | -0.27 (0.03) | -0.31 (0.08) | -0.10 (0.16) | -0.31 (0.22) |
| | CH4 ratio | -0.21 (0.04) | – | -0.04 (0.06) | -0.23 (0.19) | 0.13 (0.30) |
| | CH4/ADG | -0.12 (0.07) | -0.19 (0.08) | – | -0.02 (0.21) | 0.06 (0.22) |
| | CH4/MM | -0.26 (0.14) | -0.21 (0.12) | -0.04 (0.13) | -0.39 (0.19) | 0.22 (0.30) |
| | CH4/rumen | – | 0.12 (0.12) | -0.04 (0.12) | 0.16 (0.22) | -0.35 (0.26) |
| Residual | RMTMBW | -0.69 (0.06) | -0.44 (0.06) | 0.01 (0.05) | -0.52 (0.48) | 0.39 (0.42) |
| | RMTMBW+CO2 | -0.61 (0.02) | -0.36 (0.05) | 0.02 (0.05) | – | – |
| | RMTADG | 0.31 (0.11) | 0.94 (0.07) | – | 0.37 (0.28) | 0.37 (0.28) |

*Trait abbreviations as in Table 1.*

### Selection index

Ratio-based and residual methane definitions corresponded to distinct positions along the CH₄–MBW response-to-selection frontier, illustrating how alternative methane metrics imply different predicted selection responses in CH4 and MBW (Fig. 1). All responses are presented per generation. For ease of interpretation, ADG responses from the selection index analyses are presented in g day⁻¹ rather than kg day⁻¹. When methane intensity expressed as CH₄/MBW was assessed as the breeding goal, the predicted response was −0.56 ± 0.07 g day⁻¹ in CH4, +0.48 ± 0.08 kg in MBW and +4.96 ± 1.60 g day⁻¹ in ADG per generation. When residual methane (i.e., CH₄ − βMBW) was assessed as the breeding goal, the predicted response to selection for CH4 was larger (−0.68 ± 0.06 g day⁻¹), although this was accompanied by a smaller response in MBW (+0.19 ± 0.08 kg) and an unfavourable correlated response in ADG (−2.65 ± 1.26 g day⁻¹). These contrasting outcomes reflected differences in the implicit emphasis placed on the component traits. The CH₄/MBW objective corresponded to a relatively balanced weighting between CH₄ and MBW (55.1% vs 44.9%), whereas residual methane placed substantially greater emphasis on CH₄ reduction (87.55%) than on MBW (12.45%).

Across the full set of linear index combinations within the biologically favourable quadrant, which was defined as ΔMBW > 0, ΔCH₄ < 0, the predicted correlated response in ADG ranged from −6.87 to +15.05 g day⁻¹. When the correlated response in ADG was approximately zero, methane emissions could be reduced by −0.66 ± 0.06 g day⁻¹ while maintaining a favourable response in MBW (+0.31 ± 0.05 kg). This outcome corresponded to a breeding objective placing approximately 75% of the relative emphasis on CH₄ reduction and 25% on MBW.

**Fig. 1.** Predicted genetic response frontier per generation for methane production (CH₄) and metabolic body weight (MBW). Colour shading represents correlated responses in average daily gain (g day⁻¹), with red indicating decreased and green indicating increased responses. The square denotes the response obtained when residual methane (CH₄ − βMBW) was assessed as the breeding goal, while the triangle denotes the response obtained when methane intensity (CH₄/MBW) was assessed as the breeding goal.

When live weight was used as the weight trait in the selection index framework (Fig. 2), ratio-based methane expressed per kg of live weight corresponded to a predicted response of +0.45 ± 0.05 g day⁻¹ in CH4, +6.21 ± 0.21 kg in live weight and +33.37 ± 2.28 g day⁻¹ in ADG per generation. In contrast, residual methane adjusted for live weight corresponded to a CH4 reduction of −0.29 ± 0.11 g day⁻¹, accompanied by a reduced predicted response in live weight (+1.67 ± 0.48 kg) and +8.96 ± 2.88 g day⁻¹ in ADG. These outcomes again reflected differences in implicit weighting, with the ratio objective placing 77.79% of emphasis on CH₄ and 22.21% on live weight, compared with 89.35% and 10.65%, respectively, for the residual objective. Greater reductions in CH4 could be achieved without negative responses in live weight or ADG, such as a relative emphasis of 90.48% on CH4 and 9.52% on live weight, which would correspond to a predicted reduction of 0.43 ± 0.08 g day⁻¹ of CH4, while maintaining favourable responses in live weight (0.43 ± 0.25 kg) and ADG (2.25 ± 1.39 g day⁻¹).

**Fig. 2.** Predicted genetic response frontier per generation for methane production (CH₄) and live weight (LW). Colour shading represents correlated responses in average daily gain (g day⁻¹), with red indicating decreased and green indicating increased responses. The square denotes the response obtained when residual methane (CH₄ − βLW) was assessed as the breeding goal, while the triangle denotes the response obtained when methane intensity (CH₄/LW) was assessed as the breeding goal.

## Discussion

The present study examined how alternative methane trait definitions differ in their genetic parameters and in the expected correlated responses when incorporated into breeding objectives. Although multiple methane phenotypes can be used to quantify emissions efficiency, their differing statistical properties and potential behaviour as selection targets are not always immediately apparent. Lassen and Difford [16] highlighted the need for further research evaluating the extent to which ratio- and residual-based methane traits deviate from optimal index-based selection outcomes. By directly comparing absolute, ratio-based, and residual methane definitions within a common analytical framework, the current results help address this gap and provide insight into how phenotype choice may influence the design of breeding programmes.

With the exception of the CH4 ratio trait all other metrics demonstrated moderate heritability and repeatability. This is consistent with findings in other studies across sheep [28], beef [7, 29] and dairy [30]. The magnitude of genetic parameters found here is comparable to many traits already included in breeding programmes, for example, somatic cell count [31], a trait that has been successfully incorporated into dairy breeding programmes and has delivered sustained, cumulative genetic gains [32]. Taken together, these findings indicate that methane production possesses sufficient additive genetic variation to respond to selection and therefore support the feasibility of achieving sustained genetic progress for methane mitigation within multi-trait sheep breeding programmes.

The variation in the strength of the genetic and phenotypic correlations observed among methane trait definitions indicate that, although these traits capture overlapping aspects of methane variation, they are not interchangeable, a pattern also observed in beef cattle by Crowley et al. [29]. Strong correlations among several methane definitions suggest that they are governed by common genetic architecture, but weaker relationships between methane production and traits such as CH₄/ADG (rg = 0.23 ± 0.06) and RMTMBW (rg = 0.55 ± 0.06) indicate that ratio-based scaling and residualisation alter the variance–covariance structure of the resulting phenotype [33].

The distinction between the methane traits becomes even more apparent when methane traits are considered in relation to production traits. Methane production showed positive genetic correlations with production-related traits such as ADG (rg = 0.41 ± 0.05), whereas ratio- and residual-based methane traits were generally negatively genetically correlated with the denominator or covariate traits used in their construction, similar to findings in beef cattle [29]. This indicates that ratio and residual methane definitions do not remove the genetic correlations with production traits but instead modify the correlations between methane and production, consistent with the broader statistical limitations of ratio-based variables described by Kronmal [34]. From a breeding perspective, this means that alternative methane definitions should not be viewed as interchangeable measures of methane efficiency. Rather, each definition captures a different balance between methane output and the biological processes underpinning production. Consequently, the choice of methane definition is not a matter of biological intuition or conceptual appeal, but one that directly influences the pattern of correlated responses expected under selection.

The selection index analyses demonstrated that it is possible to reduce methane production without necessarily compromising key performance traits, similar to findings in dairy cattle [35]. The correlated responses obtained from methane selection depended strongly on how the breeding objective was defined. Ratio-based (CH₄/MBW) and residual methane traits each represented specific positions on the CH₄–MBW trade-off frontier and therefore corresponded to only a subset of the possible selection outcomes. Similar patterns were observed when live weight was used as the alternative production trait, with ratio- and residual-based methane definitions again corresponding to distinct points on the response frontier. Notably, methane expressed per kg of live weight was associated with favourable responses in live weight and ADG, but an increase in methane production (reflecting the stronger positive genetic correlation between methane and live weight (0.50), together with the greater scale and variability of live weight relative to MBW), illustrating that improvement in a ratio phenotype does not necessarily imply direct methane reduction [34, 36]. Across both analyses, methane reductions of comparable and greater magnitudes to those achieved under ratio- and residual-based methods could be obtained under alternative index weightings, but with markedly more favourable correlated responses in growth and body size.

These findings therefore indicate that ratio and residual methane traits, while biologically interpretable, impose implicit and often suboptimal restrictions on the breeding objective. This is consistent with previous work by Zetouni et al. [36], earlier more theoretical work by Sutherland [37] and subsequent work on residual efficiency traits [33, 38]. This constraint becomes increasingly important in the context of multi-trait breeding objectives, where multiple economically relevant traits must be optimised simultaneously. Under such conditions, embedding a single implicit weighting between methane and production traits reduces the scope to explore alternative trade-offs and limits the ability to identify more desirable solutions across the wider trait space.

For methane specifically, assigning a stable economic value may be challenging, as the relative importance of emissions reduction is likely to depend on evolving policy, carbon pricing, market incentives, and societal priorities [39, 40]. Consequently, methane mitigation may be more naturally approached through a desired-gains framework, where breeding programmes target a specified reduction in methane emissions while maintaining favourable responses in growth, body size, and other economically relevant traits [41]. Under this scenario, it would be unlikely that the fixed implicit weighting imposed by a ratio or residual methane phenotype would exactly coincide with the desired responses. In contrast, the linear index framework provides direct control over the balance between emissions and performance, allowing the relative emphasis on methane, body size, growth, and any other traits of interest to be explicitly tailored to breeding goals. This flexibility therefore represents a more effective and adaptable approach for integrating methane mitigation into multi-trait breeding programmes.

## Conclusions

This study is the first of its kind to characterise genetic parameters across a comprehensive suite of alternative methane trait definitions and to evaluate their implications within a selection index framework in a pasture-based sheep population, offering a foundation for informed trait selection in breeding programmes. Methane emissions exhibited weak to moderate additive genetic variation across all definitions examined, and although alternative metrics differ in statistical properties, much of the underlying genetic variation was shared. Scaling or residualising methane alters variance structure but did not remove the heritable component available for selection. Selection index analyses demonstrated that methane emissions can be reduced without necessitating unfavourable responses in body size or growth, but that the correlated outcomes of selection depend strongly on how methane is defined within the breeding objective. The choice of methane trait definition is therefore not a minor consideration; but a fundamental breeding decision that directly determines both the magnitude of emissions reduction and the direction of correlated responses in key production traits. Ratio- and residual-based definitions impose implicit, fixed weightings that constrain this trade-off and can produce unintended productivity penalties. As high-throughput methane phenotyping becomes increasingly routine and the pressure to deliver climate commitments intensifies, the definition of the breeding objective warrants careful consideration. The present findings provide a clear empirical basis for that decision, with direct relevance for national and international programmes integrating methane mitigation into pasture-based ruminant breeding.

## Declarations

### Ethics approval and consent to participate

Data were generated on growing animals and ewes from 132 Irish sheep flocks. Data collection was approved by the Teagasc Animal Ethics Committee (TAEC2020-252; TAEC2020-258; TAEC0323-374) and the Health Protection Regulatory Authority (AE19132/P112; AE19132/P114; AE19132/P181).

### Consent for publication

Not applicable.

### Availability of data and materials

The datasets analysed in the current study are not publicly available as they contain commercially sensitive information collected from farmers and private enterprises.

Code used for the selection index analyses (https://github.com/dermok1010/Methane_Selection_Index_Analysis), together with supplementary materials including full variance components, complete correlation matrices, selection response outputs across the response surface, and Monte Carlo simulation distributions, are available via Zenodo [DOI to be added upon acceptance].

### Competing interests

The authors declare that they have no competing interests.

### Funding

Funding from the Irish Department of Agriculture, Food, and Marine MethanePredict (2022IRLNZ121), SustainSheep (2023GEH253), and Science Foundation Ireland under the Grant 21/FFP-A/9148 (OviSeq) projects is gratefully acknowledged.

### Authors' contributions

[Text — unchanged template placeholder in the submitted docx.]

### Acknowledgements

The authors gratefully acknowledge the participating farmers and industry partners.

## Supplementary Material

**S1. Fixed-effect significance and connectedness diagnostics.** [PENDING — not yet drafted.] Wald F-statistic table for the 7 univariate genetic-analysis models (breed-proportion covariates significant at p<0.001 for every trait; Lleyn never significant), plus pedigree completeness/connectedness diagnostics (100% of phenotyped animals in the pedigree, 88.5% both parents known, 1,025 unique sires, mean pedigree depth 17.6 generations, 73.1% of sires linking 2+ contemporary groups) and the Cheviot/Lleyn breed-proportion/contemporary-group confounding result. Source analysis: `analysis/diagnostics/reviewer_a2_a3/` in the methane_selection_revision repo.

## References

1. FAO, Methane emissions in livestock and rice systems – Sources, quantification, mitigation and metrics, Food and Agriculture Organization of the United Nations, Rome, 2023.
2. Roques S., Martinez-Fernandez G., Ramayo-Caldas Y., Popova M., Denman S., Meale S.J., Morgavi D.P., Recent Advances in Enteric Methane Mitigation and the Long Road to Sustainable Ruminant Production, Annual Review of Animal Biosciences. 12 (2024) 321-343.
3. Makkar H.P.S., Review: Feed demand landscape and implications of food-not feed strategy for food security and climate change, Animal. 12 (2018) 1744-1754.
4. EPA, Agriculture Greenhouse Gas Emissions in Ireland, Environmental Protection Agency, Wexford, Ireland, 2024.
5. O'Mara F., Richards K.G., Shalloo L., Donnellan T., Finn J.A., Lanigan G., Sustainability of ruminant livestock production in Ireland, Animal Frontiers. 11 (2021) 32-43.
6. Shalloo L., & Herron, J., The Sustainability of Ireland's Livestock Systems, Sustainability in Agriculture: The Science & Evidence, Teagasc, 2024.
7. Ryan C.V., Pabiou T., Purfield D.C., Kelly D.N., Murphy C.P., Evans R.D., Genetic correlations between enteric methane and traits of economic importance in a beef finishing system, J Anim Sci. 103 (2025).
8. Rowe S.J., Hickey S.M., Bain W.E., Greer G.J., Johnson P.L., Elmes S., Pinares-Patiño C.S., Young E.A., Dodds K.G., Knowler K., Pickering N.K., Jonker A., McEwan J.C., Can we have our steak and eat it: The impact of breeding for lowered environmental impact on yield and meat quality in sheep, Frontiers in Genetics. Volume 13 - 2022 (2022).
9. O'Connor E., McGovern F.M., Byrne D.T., Boland T.M., Dunne E., McHugh N., Repeatability of gaseous measurements across consecutive days in sheep using portable accumulation chambers, J Anim Sci. 99 (2021).
10. Jonker A., Hickey S.M., Rowe S.J., Janssen P.H., Shackell G.H., Elmes S., Bain W.E., Wing J., Greer G.J., Bryson B., MacLean S., Dodds K.G., Pinares-Patiño C.S., Young E.A., Knowler K., Pickering N.K., McEwan J.C., Genetic parameters of methane emissions determined using portable accumulation chambers in lambs and ewes grazing pasture and genetic correlations with emissions determined in respiration chambers, J Anim Sci. 96 (2018) 3031-3042.
11. Bird-Gardiner T., Arthur P.F., Barchia I.M., Donoghue K.A., Herd R.M., Phenotypic relationships among methane production traits assessed under ad libitum feeding of beef cattle, Journal of Animal Science. 95 (2017) 4391-4398.
12. Crowley S.B., Purfield D.C., Conroy S.B., Kelly D.N., Evans R.D., Ryan C.V., Berry D.P., Associations between a range of enteric methane emission traits and performance traits in indoor-fed growing cattle, Journal of Animal Science. 102 (2024).
13. Smith P.E., Waters S.M., Kenny D.A., Kirwan S.F., Conroy S., Kelly A.K., Effect of divergence in residual methane emissions on feed intake and efficiency, growth and carcass performance, and indices of rumen fermentation and methane emissions in finishing beef cattle, Journal of Animal Science. 99 (2021).
14. Manzanilla-Pech C.I.V., Stephansen R.B., Difford G.F., Løvendahl P., Lassen J., Selecting for Feed Efficient Cows Will Help to Reduce Methane Gas Emissions, Frontiers in Genetics. Volume 13 - 2022 (2022).
15. Kelly D.J., Mchugh N., Purfield D., Mccarron P., Pabiou T., Murphy C., Mcgovern F., Assessing alternative metrics of methane output measured in a multi-breed, pasture-based sheep population, Journal of Animal Science. (2026).
16. Lassen J., Difford G.F., Review: Genetic and genomic selection as a methane mitigation strategy in dairy cattle, Animal. 14 (2020) s473-s483.
17. Clelland N., Bunger L., McLean K.A., Conington J., Maltin C., Knott S., Lambe N.R., Prediction of intramuscular fat levels in Texel lamb loins using X-ray computed tomography scanning, Meat Science. 98 (2014) 263-271.
18. VanRaden P.M., Accounting for Inbreeding and Crossbreeding in Genetic Evaluation of Large Populations, Journal of Dairy Science. 75 (1992) 3136-3144.
19. VanRaden P.M., Sanders A.H., Economic Merit of Crossbred and Purebred US Dairy Cattle, Journal of Dairy Science. 86 (2003) 1036-1044.
20. Gilmour A.R., Gogel B.J., Cullis B.R., Welham S.J., Thompson R., ASReml User Guide Release 4.2: Functional Specification, Hemel Hempstead, United Kingdom, 2021.
21. Hazel L.N., The Genetic Basis for Constructing Selection Indexes, Genetics. 28 (1943) 476-490.
22. Lin C.Y., Relative Efficiency of Selection Methods for Improvement of Feed Efficiency, Journal of Dairy Science. 63 (1980) 491-494.
23. Koch R.M., Swiger L.A., Chambers D., Gregory K.E., Efficiency of Feed Use in Beef Cattle, Journal of Animal Science. 22 (1963) 486-494.
24. R Core Team, R: A Language and Environment for Statistical Computing. R Foundation for Statistical Computing., 2024.
25. Bates D., Maechler M., Jagan M., Matrix: Sparse and Dense Matrix Classes and Methods, R package, 2022.
26. Wickham H., François R., Henry L., Müller K., Vaughan D., dplyr: A Grammar of Data Manipulation, 2023.
27. Wickham H., Vaughan D., Girlich M., tidyr: Tidy Messy Data, 2023.
28. Pinares-Patiño C.S., Hickey S.M., Young E.A., Dodds K.G., MacLean S., Molano G., Sandoval E., Kjestrup H., Harland R., Hunt C., Pickering N.K., McEwan J.C., Heritability estimates of methane emissions from sheep, Animal. 7 (2013) 316-321.
29. Crowley S.B., Purfield D.C., Conroy S.B., Kelly D.N., Evans R.D., Ryan C.V., Berry D.P., Genetic Insights into Enteric Methane Emissions in Indoor-Fed Growing Cattle, Journal of Animal Science. (2026).
30. van Breukelen A.E., Aldridge M.N., Veerkamp R.F., Koning L., Sebek L.B., de Haas Y., Heritability and genetic correlations between enteric methane production and concentration recorded by GreenFeed and sniffers on dairy cows, Journal of Dairy Science. 106 (2023) 4121-4132.
31. Shook G.E., Schutz M.M., Selection on Somatic Cell Score to Improve Resistance to Mastitis in the United States, Journal of Dairy Science. 77 (1994) 648-658.
32. García-Ruiz A., Cole J.B., VanRaden P.M., Wiggans G.R., Ruiz-López F.J., Van Tassell C.P., Changes in genetic selection differentials and generation intervals in US Holstein dairy cattle as a result of genomic selection, Proceedings of the National Academy of Sciences. 113 (2016) E3995-E4004.
33. Kennedy B.W., van der Werf J.H., Meuwissen T.H., Genetic and statistical properties of residual feed intake, J Anim Sci. 71 (1993) 3239-3250.
34. Kronmal R.A., Spurious Correlation and the Fallacy of the Ratio Standard Revisited, Journal of the Royal Statistical Society. Series A (Statistics in Society). 156 (1993) 379-392.
35. Richardson C.M., Amer P.R., Quinton C., Crowley J., Hely F.S., van den Berg I., Pryce J.E., Reducing greenhouse gas emissions through genetic selection in the Australian dairy industry, Journal of Dairy Science. 105 (2022) 4272-4288.
36. Zetouni L., Henryon M., Kargo M., Lassen J., Direct multitrait selection realizes the highest genetic response for ratio traits, Journal of Animal Science. 95 (2017) 1921-1925.
37. Sutherland T.M., The Correlation between Feed Efficiency and Rate of Gain, a Ratio and Its Denominator, Biometrics. 21 (1965) 739-749.
38. Aggrey S., Rekaya R., Dissection of Koch's residual feed intake: Implications for selection, Poultry science. 92 (2013) 2600-2605.
39. Bognar J., Springer K., Nesbit M., Nadeu E., Hiller N., van Dijk R., Pricing Agricultural Emissions and Rewarding Climate Action in the Agri-Food Value Chain, Trinomics / Ecologic Institute, Rotterdam, Netherlands, 2023.
40. Matthews A., O'Neill M.G., Designing Agricultural Climate Policy in Ireland from 2030 to Net Zero, Institute of International and European Affairs, Dublin, Ireland, 2023.
41. Pešek J., Baker R.J., DESIRED IMPROVEMENT IN RELATION TO SELECTION INDICES, Canadian Journal of Plant Science. 49 (1969) 803-804.

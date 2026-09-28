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

# ==Genetic Parameters for Alternative Methane Trait Definitions in Pasture-Based Sheep==

Dermot J. Kelly ²'³'*, Fiona McGovern ¹, Deirdre Purfield ², Patrick McCarron ¹, Eoin Dunne ¹, Thierry Pabiou ⁴, Nóirín McHugh ³

¹ Teagasc, Animal & Grassland Research and Innovation Centre, Mellows Campus, Athenry, Co. Galway, H65 R718, Ireland
² Department of Biological Sciences, Munster Technological University, Bishopstown, Co. Cork T12 P928, Ireland
³ Teagasc, Animal and Grassland Research and Innovation Centre, Fermoy, Co. Cork P61 P302, Ireland
⁴ Sheep Ireland, Link Road, Ballincollig, Co. Cork, P31 D452, Ireland

*Corresponding author. Email: dermot.kelly@teagasc.ie

## Abstract

**Background.** Enteric methane from ruminants represents a major challenge for environmentally sustainable livestock production. Genetic selection can deliver long-term and cumulative reductions in emissions; however, methane production is positively correlated with key performance traits such as body size and growth. Alternative methane definitions, including ratio- and residual-based definitions, have therefore been proposed. ==The objective of this study was to estimate genetic parameters for a range of alternative methane trait definitions in sheep and to characterise the genetic and phenotypic relationships among them and with key production traits.==

**Results.** A total of 16,535 methane (CH4) records from 8,354 sheep across 132 Irish flocks were analysed. Alternative methane traits were defined as ratios of methane relative to metabolic body weight (MBW), average daily gain (ADG), muscle mass and rumen volume, and as residuals of methane regressed on these traits. ==Methane production showed low to moderate heritability across all trait definitions examined (h² = 0.10–0.46). Although alternative methane definitions were often strongly genetically correlated, these correlations were not uniform. Daily methane was moderately-to-strongly positively genetically correlated with body size and growth (rg = 0.72 with MBW, 0.71 with live weight and 0.51 with ADG), and ratio- and residual-based definitions redistributed rather than removed these relationships: methane intensity and residual methane were negatively genetically correlated with their denominator or adjustment traits, while remaining strongly genetically correlated with absolute methane itself (rg = 0.78–0.86 for the residual traits). These results indicate that the choice of methane definition materially changes the genetic relationship between methane and production.==

**Conclusions.** Methane production in sheep exhibits meaningful additive genetic variation across alternative trait definitions. ==Although many definitions capture overlapping genetic signals -- residual and ratio methane traits remained strongly genetically correlated with absolute methane -- they differed markedly in their genetic relationships with body size and growth. Scaling or residualising methane therefore does not eliminate its genetic association with production, but redistributes it, so the choice of methane definition should be viewed as a substantive genetic decision that shapes the direction and magnitude of correlated responses in production traits.==

## Background

Reducing greenhouse gas emissions from ruminant livestock has become a priority for ==greenhouse gas mitigation== strategies worldwide. Enteric fermentation alone contributes approximately 30% of global anthropogenic methane emissions [1], making it one of the largest and most challenging emission sources to address [2]. At the same time, rising global demand for animal-sourced protein places increasing pressure on ruminant production systems to deliver sustained reductions in emissions without compromising productivity [3]. The trade-off between ==greenhouse gas mitigation== and food production is particularly evident in grass-based systems, such as Ireland, where agriculture ==is the largest single sector source of national greenhouse gas emissions, with methane from enteric fermentation in cattle and sheep the dominant contributing gas== [4]. Concurrently, ==despite this high sectoral methane output,== Ireland ranks among the most carbon-efficient regions globally for ruminant production ==when evaluated on a per-kilogram-of-product basis== [5, 6]. This places particular emphasis on mitigation strategies capable of delivering sustained reductions in enteric methane emissions without reducing productivity or altering the fundamental structure of pasture-based systems.

Genetic selection for low-emitting animals has emerged as one of the most promising methane mitigation strategies, with moderate heritability reported for methane production [7] and the cumulative, permanent nature of genetic gain [8]. The recent development of high-throughput phenotyping technologies, most notably portable accumulation chambers (PACs), has enabled routine, large-scale collection of individual-animal methane phenotypes across both research and commercial flocks [9, 10]. However, methane production has been shown to have strong (positive) genetic and phenotypic correlations with key production traits such as body weight, growth, and feed intake [11, 12]. As a result, direct selection for reduced absolute methane emissions risks inadvertently constraining animal performance.

==Throughout this study, methane production and methane emission refer specifically to enteric methane released via eructation during rumen fermentation, as captured by PAC measurement, rather than emissions from manure management.== The development of alternative methane trait definitions -- traits expressed relative to production or as residuals, rather than as daily methane alone -- ==enables emissions to be quantified in a way that is less directly tied to an animal's body size and growth==. Metrics such as methane intensity, methane yield, and residual methane express emissions relative to an animal's metabolic demands or level of performance [12, 13]. ==Portable accumulation chambers provide a short, spot measurement of methane output rather than a continuous record of an animal's true emissions, but have nonetheless been shown to rank animals for methane output effectively, which is the property most relevant for genetic selection [9].== These traits can identify animals that emit less methane than expected for their level of productivity and have therefore been proposed as a potential means of mitigating unfavourable genetic correlations between methane production and key production traits [14]. Phenotypic analyses have shown that these alternative methane metrics can differ substantially in their relationships with production traits and with each other [15]. However, both ratio and residual methane traits present known theoretical limitations, and as noted by Lassen and Difford [16], ==the genetic parameters of these alternative definitions remain underexplored==. ==The present study addresses this gap directly by quantifying the heritability of, and the genetic and phenotypic relationships among, alternative methane trait definitions in sheep, and their genetic relationships with key production traits.==

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

**Absolute gas production.** Methane production (CH4) measured in g day⁻¹ represented the total mass of methane emitted per animal per day based on PAC measurement. ==Carbon dioxide production (CO2), measured concurrently on the same PAC record and also expressed in g day⁻¹, was analysed as an additional trait in its own right (see Results).==

**Ratio-based methane traits.** For all animals two ratio traits, representing methane intensity (CH4/MBW; methane per kg metabolic body weight) and methane as a proportion of total methane and carbon dioxide production (CH4 ratio), were calculated. ==CH4 ratio was calculated as CH4/(CH4+CO2) using each gas's daily output in grams (g day⁻¹).== For growing animals only, an additional three ratio traits were also computed: methane per kg of average daily gain (CH4/ADG), methane per kg muscle mass (CH4/MM), and methane per litre rumen volume (CH4/rumen). Here, CH₄ represents methane production measured in grams per day; CO₂ represents carbon dioxide production measured in grams per day; metabolic body weight is live weight^0.75 (kg); ADG is average daily gain (kg day⁻¹); MM is muscle mass (kg) derived from CT measurements; and rumen volume (litres) is the CT-derived estimate of rumen volume.

**Residual methane traits.** Three residual methane traits (RMT) were derived: methane adjusted for metabolic body weight (RMTMBW), methane adjusted for metabolic body weight and carbon dioxide production (RMTMBW+CO2), and methane adjusted for average daily gain (RMTADG; calculated in growing animals only). Residual methane traits were generated by regressing daily methane production (g day⁻¹) on the production trait of interest (metabolic body weight, carbon dioxide production; and where available, average daily gain). The residuals from each regression were extracted and used as the phenotype for the corresponding residual methane trait.

### Genetic analysis

Variance components for all alternative methane traits were estimated using pedigree-based animal models fitted in ASReml [20]. ==Pedigree records were available for 36,449 animals (all phenotyped animals plus their recursively traced ancestors) and were used to define the additive genetic relationships among animals; 100% of phenotyped animals were represented in the pedigree, 88.5% had both parents known, the pedigree comprised 1,025 unique sires directly above phenotyped animals with a mean pedigree depth of 17.6 generations, and 73.1% of sires linked two or more contemporary groups.== All methane traits were analysed using the following linear mixed animal model:

> y = *μ* + *sex* + *BR* + *CL* + *CV* + *LY* + *SU* + *TX* + *het* + *rec* + *age* + *BTg* + *RTg* + *BTe* + *RTe* + *DP* + *CG* + *a* + *pe* ==+ *e*==

where *y* was the phenotypic observation for the methane trait under analysis; *μ* was the overall mean; *sex* was the fixed class effect of sex (male or female); the fixed effects for breed proportion corresponding to Belclare (*BR*), Charolais (*CL*), Cheviot (*CV*), Lleyn (*LY*), Suffolk (*SU*), and Texel (*TX*) were included as covariates; *het* was the heterosis coefficient; *rec* was the recombination loss coefficient; *age* was the age at measurement (weeks of age); *BTg* was the fixed class effect of birth litter size of the growing animal itself (single, twin, triplet or quadruplet); *RTg* was the fixed class effect of rearing litter size of the growing animal itself (single, twin or triplet); *BTe* was the fixed class effect of birth litter size recorded for the ewe in the year of measurement (single, twin, triplet or quadruplet); *RTe* was the fixed class effect of rearing litter size recorded for the ewe in the year of measurement (single, twin or triplet); *DP* was the fixed class effect of dam parity for growing animals; *CG* was the contemporary group fixed class effect of flock-date-lot of measurement; *a* was the random animal additive genetic effect; *pe* was the non-additive random animal permanent environmental effect; and ==*e* was the residual random error term==, where *A* was the numerator relationship matrix, *I* was the identity matrix, σ²ₐ was the direct additive genetic variance, σ²ₚₑ was the animal permanent environmental variance, and σ²ₑ was the residual variance.

This model described above was used for both univariate and bivariate analyses. ==Residual variance heterogeneity by physiological stage and by contemporary-group mean was examined for the five methane traits with sufficient data spanning multiple stages (CH4, CH4/MBW, CH4 ratio, RMTMBW, RMTMBW+CO2); it was not estimable for the four traits restricted to a single physiological stage or the sparse computed-tomography subset (CH4/ADG, CH4/MM, CH4/rumen, RMTADG). A young (<660 days) versus mature genetic correlation for CH4 was also estimated (rg = 0.99). The genetic correlations reported below (Tables 3–5) are nonetheless from a single homogeneous residual variance for every trait: a heterogeneous-residual bivariate model was not estimable given the size and imbalance of the underlying contemporary groups, so this was instead checked by refitting the CH4–CH4/MBW bivariate model separately in young and mature animals; the genetic correlation was essentially unchanged across the full data and both age groups (rg = 0.85, 0.85 and 0.85, respectively).== When CH4/MM and CH4/rumen were the dependent variables the repeated animal effect was omitted from the model due to small numbers of repeated records. ==Heritability, repeatability and each derived genetic and phenotypic correlation were obtained from the fitted (co)variance components, with standard errors derived by the delta method; computations were implemented in R version 4.2.3 [24].== Fixed-effect significance (Wald F-tests) and diagnostics of pedigree completeness, connectedness, and contemporary-group confounding are reported in Supplementary Material S1.

## Results

The mean MBW was 22.10 (SD = 4.92) kg, mean live weight was 62.72 (SD = 18.18) kg, while mean ADG, muscle mass, and rumen volume were 0.18 (SD = 0.10) kg day⁻¹, 11.7 (SD = 3.24) kg, and 6.16 (SD = 1.49) l, respectively. Descriptive statistics for methane traits are presented in Table 1. Mean methane production was 17.9 (SD = 7.56) g day⁻¹, with methane intensity (CH₄/MBW) averaging 0.81 (SD = 0.29) g kg⁻¹ day⁻¹. ==Mean carbon dioxide production was 1,189.6 (SD = 534.2) g day⁻¹ (range 40.9–2,869.1).== Methane expressed relative to average daily gain (CH₄/ADG) had a mean of 137.9 (SD = 189.3) g kg⁻¹ day⁻¹, reflecting the small denominator in this ratio trait. The mean values for methane traits derived from CT measurements were 1.44 (SD = 0.48) g kg⁻¹ day⁻¹ for CH₄/MM and 2.69 (SD = 0.88) g l⁻¹ day⁻¹ for CH₄/rumen. Residual methane traits were centred around zero by construction, with phenotypic standard deviations of 6.53 g day⁻¹ for RMTMBW, 5.32 g day⁻¹ for RMTMBW+CO2, and 4.75 g day⁻¹ for RMTADG.

**Table 1. Descriptive statistics for alternative methane trait definitions.**

| Trait group | Trait | No. records | No. animals | μ (SD) | Range |
|---|---|---|---|---|---|
| Absolute | CH4 | 15,869 | 8,185 | 17.90 (7.56) | 4.01 – 40.31 |
| ==Absolute== | ==CO2== | ==15,869== | ==8,185== | ==1189.64 (534.24)== | ==40.92 – 2869.08== |
| Ratio | CH4/MBW | 15,638 | 8,002 | 0.81 (0.29) | 0.14 – 2.38 |
| | CH4 ratio | 15,869 | 8,185 | 0.02 (0.01) | 0.00 – 0.19 |
| | CH4/ADG | 4,316 | 2,658 | 137.89 (189.27) | 12.03 – 2058.33 |
| | CH4/MM | 766 | 751 | 1.44 (0.48) | 0.33 – 3.08 |
| | CH4/rumen | 766 | 746 | 2.69 (0.88) | 0.65 – 5.73 |
| Residual | RMTMBW | 15,638 | 8,002 | 0.00 (6.53) | -20.48 – 21.33 |
| | RMTMBW+CO2 | 15,638 | 8,002 | 0.00 (5.32) | -23.38 – 24.15 |
| | RMTADG | 4,316 | 2,658 | 0.00 (4.75) | -10.23 – 25.82 |

*CH₄ is daily methane output in grams per day; ==CO2 is daily carbon dioxide output in grams per day;== CH₄/MBW is methane intensity, expressed as CH₄ per kg of metabolic body weight; CH₄ ratio is the ratio of methane to methane and carbon dioxide production; CH₄/ADG is methane per kg of average daily gain; CH₄/MM is methane per kg muscle mass derived from computed tomography; CH₄/rumen is methane per litre rumen volume derived from computed tomography; RMTMBW, RMTMBW+CO2, RMTADG are residual methane traits derived from regression of CH₄ on metabolic body weight, metabolic body weight and carbon dioxide, and average daily gain, respectively.*

### Genetic parameters

==Genetic parameters for the methane and CO2 trait definitions are presented in Table 2. Genetic standard deviations ranged from 0.07 g kg⁻¹ day⁻¹ for methane intensity (CH₄/MBW) to 35.92 g kg⁻¹ day⁻¹ for methane expressed relative to growth rate (CH₄/ADG), with corresponding genetic coefficient of variation (CVa) values of 8.89% and 26.05%, respectively. Methane production (CH₄) had a genetic standard deviation of 1.98 g day⁻¹ and CVa of 11.06%, and carbon dioxide production (CO2) had a genetic standard deviation of 138.44 g day⁻¹ and CVa of 11.64%. The genetic standard deviation for methane expressed relative to muscle mass and rumen volume were 0.20 g kg⁻¹ day⁻¹ and 0.37 g l⁻¹ day⁻¹ with CVa values of 13.59% and 13.83%, respectively. Residual methane traits (RMTMBW, RMTMBW+CO2, and RMTADG) had genetic standard deviations of 1.59, 1.65, and 1.55 g day⁻¹.==

==Heritability estimates ranged from 0.10 ± 0.01 for CH₄ ratio to 0.46 ± 0.11 for CH₄/MM (Table 2). Heritability estimates for CH₄ g day⁻¹ (0.25 ± 0.02), CH₄/MBW (0.19 ± 0.02), CH₄/ADG (0.12 ± 0.03), and residual methane traits of RMTMBW (0.18 ± 0.02), RMTMBW+CO2 (0.18 ± 0.02) and RMTADG (0.28 ± 0.03) were broadly similar. Carbon dioxide production (CO2) was somewhat more heritable (0.28 ± 0.02; repeatability 0.54 ± 0.01). Methane expressed relative to muscle mass and rumen volume produced larger heritability estimates (0.46 ± 0.11 and 0.35 ± 0.11), although both were associated with larger standard errors, consistent with their much smaller sample sizes (766 CT records). Repeatability estimates ranged from 0.10 ± 0.008 (CH₄ ratio) to 0.46 (CH₄/MM, where the permanent environmental variance was not estimable and t therefore equals h²).==

==CH₄ ratio's heritability (0.10 ± 0.01) was the lowest of any definition and was sensitive to how residual variance was modelled: allowing the residual variance to differ across contemporary-group-mean classes raised it to 0.19 (repeatability 0.32), because its near-zero permanent-environmental variance under a single homogeneous residual recovered once the residual was allowed to vary by class. An independent estimate derived from the component (co)variances of CH₄ and CO₂ gave a similar value (~0.19). Table 2 reports the homogeneous-residual estimate, used consistently across all nine methane definitions.==

**Table 2. Genetic parameters for methane and CO2 trait definitions.**

| Trait group | Trait | σa | σpe | h² (SE) | t (SE) | CVa |
|---|---|---|---|---|---|---|
| Absolute | CH4 | ==1.98 (0.09)== | ==1.09 (0.13)== | ==0.2474 (0.0205)== | ==0.3223 (0.0127)== | ==11.06%== |
| ==Absolute== | ==CO2== | ==138.44== | ==130.92== | ==0.2838 (0.0230)== | ==0.5376 (0.0100)== | ==11.64%== |
| Ratio | CH4/MBW | ==0.072 (0.004)== | ==0.052 (0.005)== | ==0.1877 (0.0192)== | ==0.2865 (0.0126)== | ==8.89%== |
| | CH4 ratio | ==1.40×10⁻³ (0.09×10⁻³)== | ==1.16×10⁻⁴ (0.83×10⁻³)== | ==0.1016 (0.0125)== | ==0.1023 (0.0079)== | ==–== |
| | CH4/ADG | ==35.92 (4.73)== | ==44.35 (3.68)== | ==0.1176 (0.0301)== | ==0.2970 (0.0166)== | ==26.05%== |
| | CH4/MM | ==0.20 (0.03)== | – | ==0.4581 (0.1064)== | – | ==13.59%== |
| | CH4/rumen | ==0.37 (0.06)== | – | ==0.3547 (0.1066)== | – | ==13.83%== |
| Residual | RMTMBW | ==1.59 (0.09)== | ==1.26 (0.10)== | ==0.1803 (0.0193)== | ==0.2935 (0.0125)== | – |
| | RMTMBW+CO2 | ==1.65 (0.09)== | ==1.60 (0.09)== | ==0.1836 (0.0195)== | ==0.3560 (0.0119)== | – |
| | RMTADG | ==1.55 (0.08)== | – | ==0.2806 (0.0259)== | – | – |

*σₐ = direct genetic standard deviation; σₚₑ = animal permanent environmental standard deviation; h² = heritability; t = repeatability; CVₐ = coefficient of genetic variation. Standard errors in parentheses. Trait abbreviations as in Table 1. ==CVₐ is not reported for CH₄ ratio: as a dimensionless mass proportion with an extremely small genetic standard deviation, its coefficient of genetic variation is not meaningfully interpretable on the same footing as the other traits. A permanent environmental effect could not be estimated for CH₄/MM, CH₄/rumen or RMTADG (permanent environmental variance at the zero boundary; no repeatability reported), and for CH₄ ratio the permanent environmental variance is likewise near-zero (standard error exceeding the estimate). Standard errors for CO2's σₐ and σₚₑ were not available at the time of writing; its h² and t standard errors above are unaffected.==*

### Correlations among methane traits

==Genetic and phenotypic correlations between daily methane production (CH₄), CO2, and each alternative methane trait definition are presented in Table 3. Phenotypically, daily methane was strongly correlated with the size-adjusted definitions -- 0.87 with both CH₄/MBW and CH₄/MM, 0.90 with RMTMBW, 0.79 with RMTMBW+CO2 and 0.71 with CH₄/rumen -- and essentially perfectly correlated with RMTADG (1.00), but more weakly with CH₄/ADG (0.31) and CH₄ ratio (0.46).==

==Genetically, daily methane was strongly correlated with methane intensity (CH₄/MBW; 0.85 ± 0.02) and CH₄/MM (0.85 ± 0.04), moderately-to-strongly with CH₄/rumen (0.78 ± 0.10) and CH₄ ratio (0.71 ± 0.03), and only moderately with CH₄/ADG (0.38 ± 0.08). Most notably, all three residual methane traits were strongly genetically correlated with absolute methane: RMTMBW (0.86 ± 0.01), RMTMBW+CO2 (0.78 ± 0.02) and RMTADG (1.00 ± 0.00), the last being genetically indistinguishable from daily methane. Daily methane was also strongly genetically correlated with CO2 production (0.57 ± 0.04; phenotypic correlation 0.35), consistent with CO2 output tracking overall metabolic size and intake. Taken together, these estimates show that residualising or scaling methane does not create a phenotype that is genetically distinct from daily methane: the size-adjusted definitions remain largely governed by the same additive genetic variation as absolute methane, with CH₄/ADG the most distinct of the set.==

**Table 3. Genetic and phenotypic correlations between daily methane production (CH₄), CO2, and each alternative methane trait definition.**

| Trait | Genetic correlation with CH₄ (SE) | Phenotypic correlation with CH₄ |
|---|---|---|
| ==CO2== | ==0.57 (0.04)== | ==0.35== |
| CH4/MBW | ==0.85 (0.02)== | ==0.87== |
| CH4 ratio | ==0.71 (0.03)== | ==0.46== |
| CH4/ADG | ==0.38 (0.08)== | ==0.31== |
| CH4/MM | ==0.85 (0.04)== | ==0.87== |
| CH4/rumen | ==0.78 (0.10)== | ==0.71== |
| RMTMBW | ==0.86 (0.01)== | ==0.90== |
| RMTMBW+CO2 | ==0.78 (0.02)== | ==0.79== |
| RMTADG | ==1.00 (0.00)== | ==1.00== |

*==Phenotypic correlation standard errors were all ≤0.02. Correlations among the alternative definitions themselves are not reported here; the focus is on daily methane against each definition and against the production traits (Tables 4 and 5).== Trait abbreviations as in Table 1.*

### Correlations between methane and production traits

Phenotypic and genetic correlations between methane traits and production traits are presented in Tables 4 and 5, respectively. Phenotypically, CH₄ showed weak to moderate positive correlations with the production traits examined, including metabolic body weight (MBW; ==0.36 ± 0.01==), live weight (LW; ==0.35 ± 0.01==), ADG (0.17 ± 0.02), rumen volume (==0.31 ± 0.04==), and muscle mass (==0.26 ± 0.04==). As expected, several ratio-based methane traits showed negative phenotypic correlations with the denominator production traits, including methane intensity (CH₄/MBW) with MBW (−0.10 ± 0.01), CH₄/MM with muscle mass (−0.24 ± 0.04), ==CH4/ADG with ADG itself (−0.25 ± 0.02)==, and CH₄/rumen with rumen volume (==−0.45 ± 0.03==). Residual methane traits showed contrasting patterns, with RMTMBW negatively phenotypically correlated with MBW (==−0.08 ± 0.01==), whereas RMTADG showed a positive phenotypic correlation with ==its own adjustment trait, ADG (0.12 ± 0.02)==.

**Table 4. Phenotypic correlations between methane traits and production traits (standard errors in parentheses).**

| Trait group | Trait | Metabolic body weight | Live Weight | Average daily gain | Muscle mass | Rumen volume |
|---|---|---|---|---|---|---|
| Absolute | CH₄ | ==0.36 (0.01)== | ==0.35 (0.01)== | 0.19 (0.02) | ==0.26 (0.04)== | ==0.31 (0.04)== |
| Ratio | CH4/MBW | -0.10 (0.01) | -0.10 (0.01) | -0.11 (0.02) | -0.04 (0.04) | 0.13 (0.04) |
| | CH₄ ratio | -0.06 (0.01) | – | -0.01 (0.02) | -0.06 (0.04) | 0.19 (0.04) |
| | CH₄/ADG | -0.00 (0.02) | -0.02 (0.02) | ==-0.25 (0.02)== | 0.26 (0.05) | 0.20 (0.05) |
| | CH₄/MM | -0.09 (0.05) | -0.06 (0.05) | 0.01 (0.05) | -0.24 (0.04) | 0.13 (0.04) |
| | CH₄/rumen | – | 0.04 (0.05) | 0.00 (0.05) | -0.03 (0.04) | ==-0.45 (0.03)== |
| Residual | RMTMBW | ==-0.08 (0.01)== | -0.16 (0.01) | 0.02 (0.02) | -0.13 (0.05) | 0.07 (0.05) |
| | RMTMBW+CO2 | ==-0.02 (0.01)== | -0.12 (0.01) | 0.02 (0.02) | – | – |
| | RMTADG | 0.17 (0.03) | 0.47 (0.02) | ==0.12 (0.02)== | 0.21 (0.08) | 0.21 (0.08) |

*Trait abbreviations as in Table 1.*

==Genetically, CH₄ showed a moderate-to-strong positive genetic correlation with metabolic body weight (MBW; 0.72 ± 0.03), live weight (0.71 ± 0.03), ADG (0.51 ± 0.07), muscle mass (0.42 ± 0.12), and rumen volume (0.68 ± 0.15).== Ratio-based methane traits were generally negatively genetically correlated with the denominator production traits, including methane intensity (CH₄/MBW) with MBW (−0.27 ± 0.04), CH₄/MM with muscle mass (−0.39 ± 0.19), ==CH4/ADG with ADG itself (−0.81 ± 0.08)==, and CH₄/rumen with rumen volume (==−0.14 ± 0.30, a correlation with a wide confidence interval==). Methane ratio showed weak to moderate negative genetic correlations with MBW (−0.21 ± 0.04), ADG (−0.04 ± 0.06), and muscle mass (−0.23 ± 0.19). Among the residual methane traits, ==RMTMBW's genetic correlation with MBW was −0.28 ± 0.04, and RMTMBW+CO2's with MBW was −0.11 ± 0.04==, whereas RMTADG showed a moderate positive genetic correlation with ==its own adjustment trait, ADG (0.42 ± 0.07)==.

**Table 5. Genetic correlations between methane traits and production traits (standard errors in parentheses).**

| Trait group | Trait | Metabolic body weight | Live weight | Average daily gain | Muscle mass | Rumen volume |
|---|---|---|---|---|---|---|
| Absolute | CH4 | ==0.72 (0.03)== | ==0.71 (0.03)== | ==0.51 (0.07)== | ==0.42 (0.12)== | ==0.68 (0.15)== |
| Ratio | CH4/MBW | -0.27 (0.04) | -0.27 (0.03) | -0.31 (0.08) | -0.10 (0.16) | -0.31 (0.22) |
| | CH4 ratio | -0.21 (0.04) | – | -0.04 (0.06) | -0.23 (0.19) | 0.13 (0.30) |
| | CH4/ADG | -0.12 (0.07) | -0.19 (0.08) | ==-0.81 (0.08)== | -0.02 (0.21) | 0.06 (0.22) |
| | CH4/MM | -0.26 (0.14) | -0.21 (0.12) | -0.04 (0.13) | -0.39 (0.19) | 0.22 (0.30) |
| | CH4/rumen | – | 0.12 (0.12) | -0.04 (0.12) | 0.16 (0.22) | ==-0.14 (0.30)== |
| Residual | RMTMBW | ==-0.28 (0.04)== | -0.44 (0.06) | 0.01 (0.05) | -0.52 (0.48) | 0.39 (0.42) |
| | RMTMBW+CO2 | ==-0.11 (0.04)== | -0.36 (0.05) | 0.02 (0.05) | – | – |
| | RMTADG | 0.31 (0.11) | 0.94 (0.07) | ==0.42 (0.07)== | 0.37 (0.28) | 0.37 (0.28) |

*Trait abbreviations as in Table 1. ==A genetic correlation between CH4/MM and muscle mass could not be estimated (model non-convergence).==*

## Discussion

==The present study estimated genetic parameters for a comprehensive set of alternative methane trait definitions in pasture-based sheep, comparing absolute, ratio-based, and residual methane phenotypes within a common analytical framework. Multiple methane phenotypes are used across the literature to quantify emissions, but their statistical properties, and the genetic relationships each carries with production traits, are not always made explicit. Lassen and Difford [16] highlighted the need for further empirical work establishing how ratio- and residual-based methane traits actually behave genetically; the results presented here address that gap directly.==

==Heritability estimates across the nine methane trait definitions ranged from 0.10 to 0.46, indicating that methane production carries meaningful additive genetic variation whichever way it is expressed. This is consistent with heritability estimates reported elsewhere in sheep [28], beef [7, 29] and dairy [30], and is comparable in magnitude to traits already used in livestock breeding programmes, such as somatic cell count [31], which has delivered sustained genetic gain in dairy cattle once incorporated into a breeding objective [32]. Ratio- and residual-based methane traits were originally proposed because feed intake -- the trait that most directly determines an animal's methane output for a given level of production -- is rarely measured at scale; scaling or residualising methane against body size, growth, or production traits is intended as a practical proxy for that missing feed-intake information [12, 13]. The results presented here show both the value and the limits of that approach.==

==Genetically, the alternative methane definitions were strongly correlated with absolute methane in most cases (rg = 0.71–1.00), indicating that they share much of the same underlying additive genetic variation rather than capturing a materially distinct trait. CH4/ADG was the most genetically distinct definition (rg = 0.38 with absolute methane), consistent with growth rate being measured over a different, non-instantaneous window than the gas measurement itself. Daily methane was also strongly and positively genetically correlated with body size and growth: metabolic body weight (rg = 0.72), live weight (rg = 0.71), and average daily gain (rg = 0.51). Ratio and residual methane traits did not remove these genetic relationships; instead, they redistributed them. Methane intensity and the residual methane traits were negatively genetically correlated with their own denominator or adjustment trait, while remaining strongly genetically correlated with absolute methane itself (rg = 0.78–0.86 for the three residual traits). This shows that scaling or residualising methane changes which trait absorbs the genetic association with body size, rather than eliminating that association, consistent with the general statistical behaviour of ratio and residual variables described by Kennedy et al. [33] and Kronmal [34]. A phenotypic residual is also not automatically a genetically independent trait: regressing methane on body weight removes their phenotypic association but does not guarantee the resulting residual is free of the same underlying additive genetic variation, and the strong genetic correlations observed here between the residual methane traits and absolute methane confirm that it is not.==

==Carbon dioxide production was itself moderately heritable (h² = 0.28 ± 0.02) and strongly genetically correlated with both daily methane (rg = 0.57 ± 0.04) and metabolic body weight (rg = 0.83 ± 0.03). Because CO2 output reflects overall aerobic metabolic rate rather than methanogenesis specifically, this is consistent with a large part of the genetic variation in gas production overall, methane included, tracking an animal's general metabolic size and intake level rather than a methane-specific physiological process. This supports treating CO2 as a useful additional descriptor of an animal's overall energy metabolism alongside methane, rather than only as a denominator for a ratio trait.==

==CH4 ratio's heritability (0.10 ± 0.01) was the lowest of the definitions examined, and is lower than the 0.17–0.25 (repeatability 0.27–0.43) reported by Jonker et al. [10] in respiration-chamber and PAC-measured lambs and ewes. Two findings narrow this gap without closing it fully. First, expressing the ratio on a molar rather than a mass basis raised its heritability moderately (to 0.13), showing the estimate is somewhat sensitive to the ratio's units, which are stated explicitly here as a mass basis (Methods). Second, allowing residual variance to differ across contemporary-group-mean classes raised CH4 ratio's heritability to 0.19, driven by its near-zero permanent-environmental variance under a single homogeneous residual recovering to a real, non-zero value once that heterogeneity was accommodated; an independent estimate derived from the component (co)variances of CH4 and CO2 gave a similar value. Both point toward CH4 ratio's very small genetic standard deviation, and the specific way its residual variance is structured, as more likely explanations for the discrepancy with Jonker et al. than a fundamental problem with the trait itself, though the estimate reported in Table 2 retains the homogeneous-residual specification used consistently for every definition.==

==PAC contemporary groups in this dataset pooled animals across a wide range of ages and physiological stages, and allowing residual variance to differ across these groups changed the estimated variance partitioning materially for several definitions (methane, CH4/MBW, RMTMBW and RMTMBW+CO2), lowering their heritability relative to a single pooled residual variance. This confirms that contemporary-group heterogeneity in absolute scale is a real feature of this dataset. However, the genetic correlation between methane and methane intensity was essentially unchanged whether estimated from the full dataset or from young and mature animals separately (rg = 0.85 in all three cases), and a direct young-versus-mature genetic correlation for methane itself was very high (rg = 0.99). Together these indicate that residual heterogeneity affects how precisely heritability is estimated more than it affects the underlying genetic relationships reported in Tables 3–5. A fully heterogeneous-residual bivariate model was attempted but was not estimable given the size and imbalance of the resulting contemporary-group classes; this is reported here as a limitation of the available data structure rather than evidence against the underlying genetic relationships.==

==The alternative methane definitions examined here are, in effect, proxies for the feed-intake information this dataset does not contain: because feed intake was not measured, scaling or residualising methane against body size, growth or CT-derived body composition is the closest practical approximation to methane per unit of feed available. This is a real limitation. On a typical pasture-based ewe flock, roughly 70% of feed intake supports ewe maintenance and reproduction, with only around 30% going to lamb carcass production; fecundity, ewe longevity and lamb survival are therefore plausibly at least as important to a flock's overall bio-economic outcome as the liveweight- and growth-based traits examined here, and none of them are represented among the trait definitions in this study. The genetic parameters reported here should accordingly be read as a characterisation of methane's genetic relationship with body size and growth specifically, not as a complete accounting of methane's place in a real breeding objective.==

## Conclusions

==This study estimated genetic parameters for nine alternative methane trait definitions in a large, pasture-based sheep population, and shows that these definitions differ meaningfully in their genetic parameters and in their genetic relationships with body size and growth. All definitions were heritable, with estimates ranging from low to moderate (h² = 0.10–0.46). Ratio and residual methane traits remained strongly genetically correlated with absolute daily methane, showing that they share much of the same underlying genetic variation rather than representing a genetically distinct trait. Daily methane itself was strongly and positively genetically correlated with body size and growth, and scaling or residualising methane redistributed this genetic association rather than removing it. The choice of methane trait definition is therefore a substantive genetic decision, not an arbitrary or purely statistical one: it determines the direction and magnitude of the genetic relationship between methane and production. As high-throughput methane phenotyping becomes increasingly routine, characterising these genetic relationships provides a necessary empirical basis for deciding how methane should be defined within pasture-based ruminant breeding objectives.==

## Declarations

### Ethics approval and consent to participate

Data were generated on growing animals and ewes from 132 Irish sheep flocks. Data collection was approved by the Teagasc Animal Ethics Committee (TAEC2020-252; TAEC2020-258; TAEC0323-374) and the Health Protection Regulatory Authority (AE19132/P112; AE19132/P114; AE19132/P181).

### Consent for publication

Not applicable.

### Availability of data and materials

The datasets analysed in the current study are not publicly available as they contain commercially sensitive information collected from farmers and private enterprises. ==Supplementary materials, including full variance components and complete correlation matrices, are available via Zenodo [DOI to be added upon acceptance].==

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

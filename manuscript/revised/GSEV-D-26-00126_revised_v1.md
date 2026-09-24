<!--
REVISED DRAFT v1 of GSEV-D-26-00126, generated 2026-09-24.
Built from manuscript/draft.md (the read-through reconstruction of the
submitted docx). This is a REVISION, not the frozen submitted baseline.

Scope of this revision (per user instruction 2026-09-24):
 1. Selection-index content REMOVED throughout (title, Abstract, Methods
    "Selection index methodology", Results "Selection index" + Figs 1-2,
    the selection-index Discussion paragraphs, and Conclusions framing).
    "For now" -- intended to be reinstated or handled separately later.
 2. All genetic parameters (Table 2) and correlations (Tables 3-5)
    updated to the rebuilt, independent-PE ASReml analysis.
 3. Discussion and Conclusions rewritten around the corrected findings.
 4. Reviewer minor edits from the 2026-09-23/24 rounds retained.

Highlight convention: ==...== marks content that is NEW or CHANGED
relative to the submitted manuscript, so it renders highlighted in the
Word export and a reader can see at a glance what moved. Unmarked text is
carried over from the submitted version unchanged.
-->

==**Revision note (not part of the manuscript body -- for the co-authors).** This draft (i) removes all selection-index material for now, narrowing the paper to genetic parameters and genetic/phenotypic relationships among methane trait definitions; (ii) updates every genetic parameter and correlation to a full rebuild of the ASReml analysis using trait-specific (independent) permanent-environmental variances in the bivariate models; and (iii) rewrites the Discussion and Conclusions accordingly. The single most consequential change is that daily methane (CH4) is now estimated to be moderately-to-strongly, positively genetically correlated with metabolic body weight (rg = 0.72), rather than near-zero as in the submitted version -- a correction traced to a permanent-environmental-variance misspecification in the original bivariate models, not new data. References [21] Hazel, [22] Lin and [23] Koch were cited only by the removed selection-index section and would be pruned (with renumbering) in the final version; they are retained here to keep all other in-text citation numbers stable.==

# ==Genetic Parameters for Alternative Methane Trait Definitions in Pasture-Based Sheep==

Dermot J. Kelly ²'³'*, Fiona McGovern ¹, Deirdre Purfield ², Patrick McCarron ¹, Eoin Dunne ¹, Thierry Pabiou ⁴, Nóirín McHugh ³

¹ Teagasc, Animal & Grassland Research and Innovation Centre, Mellows Campus, Athenry, Co. Galway, H65 R718, Ireland
² Department of Biological Sciences, Munster Technological University, Bishopstown, Co. Cork T12 P928, Ireland
³ Teagasc, Animal and Grassland Research and Innovation Centre, Fermoy, Co. Cork P61 P302, Ireland
⁴ Sheep Ireland, Link Road, Ballincollig, Co. Cork, P31 D452, Ireland

*Corresponding author. Email: dermot.kelly@teagasc.ie

## Abstract

**Background.** Enteric methane from ruminants represents a major challenge for environmentally sustainable livestock production. Genetic selection can deliver long-term and cumulative reductions in emissions; however, methane production is positively correlated with key performance traits such as body size and growth. Alternative methane definitions, including ratio- and residual-based definitions, have therefore been proposed. ==The objective of this study was to estimate genetic parameters for a range of alternative methane trait definitions in sheep and to characterise the genetic and phenotypic relationships among them and with key production traits.==

**Results.** A total of 16,535 methane (CH4) records from 8,354 sheep across 132 Irish flocks were analysed. Alternative methane traits were defined as ratios of methane relative to metabolic body weight (MBW), average daily gain (ADG), muscle mass and rumen volume, and as residuals of methane regressed on these traits. ==Methane production showed weak to moderate heritability across all trait definitions examined (h² = 0.10–0.46). Although alternative methane definitions were often strongly genetically correlated, these correlations were not uniform. Daily methane was moderately-to-strongly positively genetically correlated with body size and growth (rg = 0.72 with MBW, 0.71 with live weight and 0.51 with ADG), and ratio- and residual-based definitions redistributed rather than removed these relationships: methane intensity and residual methane were negatively genetically correlated with their denominator or adjustment traits, while remaining strongly genetically correlated with absolute methane itself (rg = 0.78–0.86 for the residual traits). These results indicate that the choice of methane definition materially changes the genetic relationship between methane and production, and therefore the correlated response expected under selection.==

**Conclusions.** Methane production in sheep exhibits meaningful additive genetic variation across alternative trait definitions. ==Although many definitions capture overlapping genetic signals -- residual and ratio methane traits remained strongly genetically correlated with absolute methane -- they differed markedly in their genetic relationships with body size and growth. Scaling or residualising methane therefore does not eliminate its genetic association with production, but redistributes it, so the choice of methane definition should be viewed as a substantive genetic decision that shapes the direction and magnitude of correlated responses in production traits.==

## Background

Reducing greenhouse gas emissions from ruminant livestock has become a priority for greenhouse gas mitigation strategies worldwide. Enteric fermentation alone contributes approximately 30% of global anthropogenic methane emissions [1], making it one of the largest and most challenging emission sources to address [2]. At the same time, rising global demand for animal-sourced protein places increasing pressure on ruminant production systems to deliver sustained reductions in emissions without compromising productivity [3]. The trade-off between greenhouse gas mitigation and food production is particularly evident in grass-based systems, such as Ireland, where agriculture is the largest single sector source of national greenhouse gas emissions, with methane from enteric fermentation in cattle and sheep the dominant contributing gas [4]. Concurrently, despite this high sectoral methane output, Ireland ranks among the most carbon-efficient regions globally for ruminant production when evaluated on a per-kilogram-of-product basis [5, 6]. This places particular emphasis on mitigation strategies capable of delivering sustained reductions in enteric methane emissions without reducing productivity or altering the fundamental structure of pasture-based systems.

Genetic selection for low-emitting animals has emerged as one of the most promising methane mitigation strategies, with moderate heritability reported for methane production [7] and the cumulative, permanent nature of genetic gain [8]. The recent development of high-throughput phenotyping technologies, most notably portable accumulation chambers (PACs), has enabled routine, large-scale collection of individual-animal methane phenotypes across both research and commercial flocks [9, 10]. However, methane production has been shown to have strong (positive) genetic and phenotypic correlations with key production traits such as body weight, growth, and feed intake [11, 12]. As a result, direct selection for reduced absolute methane emissions risks inadvertently constraining animal performance.

Throughout this study, methane production and methane emission refer specifically to enteric methane released via eructation during rumen fermentation, as captured by PAC measurement, rather than emissions from manure management. The development of alternative methane trait definitions enables these emissions to be quantified independently of production. Metrics such as methane intensity, methane yield, and residual methane express emissions relative to an animal's metabolic demands or level of performance [12, 13]. These traits can identify animals that emit less methane than expected for their level of productivity and have therefore been proposed as a potential means of mitigating unfavourable genetic correlations between methane production and key production traits [14]. Phenotypic analyses have shown that these alternative methane metrics can differ substantially in their relationships with production traits and with each other [15]. However, both ratio and residual methane traits present known theoretical limitations, and as noted by Lassen and Difford [16], the extent to which these alternative definitions differ in their genetic behaviour requires further empirical evaluation. ==The present study addresses this gap directly by quantifying the heritability of, and the genetic and phenotypic relationships among, alternative methane trait definitions in sheep, and their genetic relationships with key production traits.==

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

**Ratio-based methane traits.** For all animals two ratio traits, representing methane intensity (CH4/MBW; methane per kg metabolic body weight) and methane as a proportion of total methane and carbon dioxide production (CH4 ratio), were calculated. ==CH4 ratio was calculated as CH4/(CH4+CO2) using each gas's daily output in grams (g day⁻¹); as both gases are expressed on the same mass basis, CH4 ratio itself is a dimensionless mass proportion.== For growing animals only, an additional three ratio traits were also computed: methane per kg of average daily gain (CH4/ADG), methane per kg muscle mass (CH4/MM), and methane per litre rumen volume (CH4/rumen). Here, CH₄ represents methane production measured in grams per day; CO₂ represents carbon dioxide production measured in grams per day; metabolic body weight is live weight^0.75 (kg); ADG is average daily gain (kg day⁻¹); MM is muscle mass (kg) derived from CT measurements; and rumen volume (litres) is the CT-derived estimate of rumen volume.

**Residual methane traits.** Three residual methane traits (RMT) were derived: methane adjusted for metabolic body weight (RMTMBW), methane adjusted for metabolic body weight and carbon dioxide production (RMTMBW+CO2), and methane adjusted for average daily gain (RMTADG; calculated in growing animals only). Residual methane traits were generated by regressing daily methane production (g day⁻¹) on the production trait of interest (metabolic body weight, carbon dioxide production; and where available, average daily gain). The residuals from each regression were extracted and used as the phenotype for the corresponding residual methane trait.

### Genetic analysis

Variance components for all alternative methane traits were estimated using pedigree-based animal models fitted in ASReml [20]. ==Pedigree records were available for 36,449 animals (all phenotyped animals plus their recursively traced ancestors) and were used to define the additive genetic relationships among animals; 100% of phenotyped animals were represented in the pedigree, 88.5% had both parents known, the pedigree comprised 1,025 unique sires directly above phenotyped animals with a mean pedigree depth of 17.6 generations, and 73.1% of sires linked two or more contemporary groups.== All methane traits were analysed using the following linear mixed animal model:

> y = *μ* + *sex* + *BR* + *CL* + *CV* + *LY* + *SU* + *TX* + *het* + *rec* + *age* + *BTg* + *RTg* + *BTe* + *RTe* + *DP* + *CG* + *a* + *pe* ==+ *e*==

where *y* was the phenotypic observation for the methane trait under analysis; *μ* was the overall mean; *sex* was the fixed class effect of sex (male or female); the fixed effects for breed proportion corresponding to Belclare (*BR*), Charolais (*CL*), Cheviot (*CV*), Lleyn (*LY*), Suffolk (*SU*), and Texel (*TX*) were included as covariates; *het* was the heterosis coefficient; *rec* was the recombination loss coefficient; *age* was the age at measurement (weeks of age); *BTg* was the fixed class effect of birth litter size of the growing animal itself (single, twin, triplet or quadruplet); *RTg* was the fixed class effect of rearing litter size of the growing animal itself (single, twin or triplet); *BTe* was the fixed class effect of birth litter size recorded for the ewe in the year of measurement (single, twin, triplet or quadruplet); *RTe* was the fixed class effect of rearing litter size recorded for the ewe in the year of measurement (single, twin or triplet); *DP* was the fixed class effect of dam parity for growing animals; *CG* was the contemporary group fixed class effect of flock-date-lot of measurement; *a* was the random animal additive genetic effect; *pe* was the non-additive random animal permanent environmental effect; and ==*e* was the residual random error term==, where *A* was the numerator relationship matrix, *I* was the identity matrix, σ²ₐ was the direct additive genetic variance, σ²ₚₑ was the animal permanent environmental variance, and σ²ₑ was the residual variance.

This model was used for both univariate and bivariate analyses. ==Bivariate models were used to estimate the phenotypic and genetic correlations between (i) methane traits according to their definition and (ii) methane traits and production traits, and were fitted with trait-specific (independent) permanent-environmental variances so that a single shared permanent-environmental term was not forced across two traits measured on very different scales.== When CH4/MM and CH4/rumen were the dependent variables the repeated animal effect was omitted from the model due to small numbers of repeated records. ==Heritability (h²), repeatability (t) and each derived genetic and phenotypic correlation were obtained directly from the fitted (co)variance components, with standard errors derived by the delta method. All computations were implemented in R version 4.2.3 [24], with the Matrix [25], dplyr [26] and tidyr [27] packages.==

==Residual variance heterogeneity across physiological stage was additionally examined for every trait with sufficient data spanning multiple stages (CH4, CH4/MBW, CH4 ratio, RMTMBW and RMTMBW+CO2); it was not estimable for the four traits restricted to a single physiological stage or to the sparse CT subset (CH4/ADG, CH4/MM, CH4/rumen and RMTADG). Where estimable, allowing the residual variance to differ by contemporary-group-mean class materially altered the partitioning of variance for several traits, and a young (<660 days) versus mature genetic correlation for CH4 was estimated as supporting evidence (rg = 0.99). The genetic correlations reported below were nonetheless estimated under a single homogeneous residual variance: a heterogeneous-residual bivariate model was not estimable given the size and imbalance of the underlying classes, and stage-split bivariate models (young-only and mature-only refits) gave an essentially unchanged CH4–CH4/MBW genetic correlation across the full-data, young and mature subsets (rg = 0.85, 0.85 and 0.85), indicating that residual heterogeneity affects heritability estimation more than the genetic correlations reported here.== Fixed-effect significance (Wald F-tests) and diagnostics of pedigree completeness, connectedness, and contemporary-group confounding are reported in Supplementary Material S1.

==The selection-index analyses presented in the original submission (predicted correlated responses under ratio-, residual- and linear-index breeding objectives) have been removed from this version and will be addressed separately.==

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

==Genetic parameters for the methane trait definitions are presented in Table 2. Genetic standard deviations ranged from 0.07 g kg⁻¹ day⁻¹ for methane intensity (CH₄/MBW) to 35.92 g kg⁻¹ day⁻¹ for methane expressed relative to growth rate (CH₄/ADG), with corresponding genetic coefficient of variation (CVa) values of 8.89% and 26.05%, respectively. Methane production (CH₄) had a genetic standard deviation of 1.98 g day⁻¹ and CVa of 11.06%. The genetic standard deviations for methane expressed relative to muscle mass and rumen volume were 0.20 g kg⁻¹ day⁻¹ and 0.37 g l⁻¹ day⁻¹, with CVa values of 13.59% and 13.83%, respectively. Residual methane traits (RMTMBW, RMTMBW+CO2, and RMTADG) had genetic standard deviations of 1.59, 1.65, and 1.55 g day⁻¹.==

==Heritability estimates ranged from 0.10 ± 0.01 for CH₄ ratio to 0.46 ± 0.11 for CH₄/MM (Table 2). Heritabilities for CH₄ (0.25 ± 0.02), CH₄/MBW (0.19 ± 0.02), CH₄/ADG (0.12 ± 0.03), and the residual methane traits RMTMBW (0.18 ± 0.02), RMTMBW+CO2 (0.18 ± 0.02) and RMTADG (0.28 ± 0.03) were broadly similar and in the low-to-moderate range. Methane expressed relative to muscle mass and rumen volume produced larger heritability estimates (0.46 ± 0.11 and 0.35 ± 0.11), but both were associated with substantially larger standard errors, consistent with their much smaller sample sizes (766 CT records). Repeatability estimates ranged from 0.10 ± 0.008 (CH₄ ratio) to 0.36 ± 0.01 (RMTMBW+CO2); for CH₄/MM and CH₄/rumen the permanent-environmental variance was not estimable and the repeated animal effect was omitted, so no repeatability is reported. CH₄ ratio displayed both the lowest heritability and, by a wide margin, the lowest genetic coefficient of variation of any trait examined, a point returned to in the Discussion.==

**Table 2. Genetic parameters for alternative methane trait definitions.**

| Trait group | Trait | σa | σpe | h² (SE) | t (SE) | CVa |
|---|---|---|---|---|---|---|
| Absolute | CH4 | ==1.98== | ==1.09== | ==0.25 (0.02)== | ==0.32 (0.01)== | ==11.06%== |
| Ratio | CH4/MBW | ==0.07== | ==0.05== | ==0.19 (0.02)== | ==0.29 (0.01)== | ==8.89%== |
| | CH4 ratio | ==1.40×10⁻³== | ==1.16×10⁻⁴== | ==0.10 (0.01)== | ==0.10 (0.01)== | ==0.24%== |
| | CH4/ADG | ==35.92== | ==44.35== | ==0.12 (0.03)== | ==0.30 (0.02)== | ==26.05%== |
| | CH4/MM | ==0.20== | – | ==0.46 (0.11)== | – | ==13.59%== |
| | CH4/rumen | ==0.37== | – | ==0.35 (0.11)== | – | ==13.83%== |
| Residual | RMTMBW | ==1.59== | ==1.26== | ==0.18 (0.02)== | ==0.29 (0.01)== | – |
| | RMTMBW+CO2 | ==1.65== | ==1.60== | ==0.18 (0.02)== | ==0.36 (0.01)== | – |
| | RMTADG | ==1.55== | – | ==0.28 (0.03)== | – | – |

*σₐ = direct genetic standard deviation; σₚₑ = animal permanent environmental standard deviation; h² = heritability; t = repeatability; CVₐ = coefficient of genetic variation. Trait abbreviations as in Table 1. ==h² and t standard errors are delta-method values from the fitted model; σₐ and σₚₑ standard errors are omitted in this draft pending extraction from the rebuilt output. CH₄ ratio's CVa is provisional: the value depends on a genetic standard deviation that is extremely small on the trait's own scale, and is retained here only for continuity with Table 1.==*

### Correlations among methane traits

Phenotypic and genetic correlations among methane trait definitions are presented in Table 3. Phenotypic correlations were generally strong and positive among size-adjusted traits, with methane intensity showing the strongest phenotypic correlation with methane production (0.87 ± 0.003), and weaker phenotypic correlations observed between methane production and both CH₄/ADG (==0.31 ± 0.02==) and CH₄ ratio (0.46 ± 0.007).

==Methane production (CH₄) was strongly positively genetically correlated with methane intensity (0.85 ± 0.02) and CH₄/MM (0.85 ± 0.04), and moderately-to-strongly correlated with CH₄/rumen (0.78 ± 0.10) and CH₄/ADG (0.38 ± 0.08). Most notably, CH₄ was strongly genetically correlated with the residual methane traits: 0.86 ± 0.01 with RMTMBW and 0.78 ± 0.02 with RMTMBW+CO2. In other words, residualising methane on body size did not produce a phenotype that was genetically distinct from absolute methane; the residual traits remained genetically very close to daily methane itself.== A strong positive genetic correlation was observed between methane intensity and CH₄/MM (0.86 ± 0.04), but only a weak genetic correlation between methane intensity and CH₄/ADG (0.18 ± 0.06). Methane per litre of rumen volume (CH₄/rumen) showed a moderate genetic correlation with methane intensity (0.51 ± 0.18). Methane as a proportion of total gas production (CH₄ ratio) exhibited moderate to strong genetic correlations with several size-adjusted methane definitions, including methane intensity (0.85 ± 0.04). The genetic correlations among the residual traits themselves were moderate to strong, ranging from 0.55 ± 0.07 (RMTMBW+CO2 with RMTADG) to 0.77 ± 0.03 (RMTADG with RMTMBW).

**Table 3. Genetic (above diagonal) and phenotypic (below diagonal) correlations among alternative methane trait definitions.**

| | CH4 | CH4/MBW | CH4 ratio | CH4/ADG | CH4/MM | CH4/rumen | RMTMBW | RMTMBW+CO2 | RMTADG |
|---|---|---|---|---|---|---|---|---|---|
| CH4 | | ==0.85 (0.02)== | 0.73 (0.05) | ==0.38 (0.08)== | ==0.85 (0.04)== | ==0.78 (0.10)== | ==0.86 (0.01)== | ==0.78 (0.02)== | 0.26 (0.48) |
| CH4/MBW | ==0.87== | | 0.85 (0.04) | 0.18 (0.06) | 0.86 (0.04) | 0.51 (0.14) | 0.55 (0.06) | 0.86 (0.02) | 0.81 (0.03) |
| CH4 ratio | 0.46 | 0.53 | | – | 0.44 (0.19) | 0.27 (0.20) | 0.82 (0.04) | – | 0.71 (0.07) |
| CH4/ADG | ==0.31== | 0.24 | – | | 0.57 (0.17) | 0.40 (0.17) | 0.30 (0.06) | 0.24 (0.06) | 0.04 (0.06) |
| CH4/MM | ==0.87== | 0.85 | 0.69 | 0.48 | | 0.49 (0.18) | 0.82 (0.04) | 0.79 (0.07) | 0.99 (0.08) |
| CH4/rumen | ==0.71== | 0.63 | 0.49 | 0.38 | 0.62 | | 0.79 (0.09) | 0.62 (0.11) | 0.37 (0.28) |
| RMTMBW | ==0.90== | 0.78 | 0.50 | 0.32 | 0.91 | 0.70 | | 0.62 (0.05) | 0.77 (0.03) |
| RMTMBW+CO2 | ==0.79== | 0.82 | – | 0.26 | 0.83 | 0.60 | 0.71 | | 0.55 (0.07) |
| RMTADG | 0.66 | 0.89 | 0.32 | 0.23 | 0.85 | 0.58 | 0.82 | 0.72 | |

*Standard error of all phenotypic correlations ≤0.07 except where shown. Trait abbreviations as in Table 1. ==Highlighted cells are re-estimated values from the rebuilt bivariate analysis (daily methane against each of the other definitions). The CH4–CH4 ratio and CH4–RMTADG genetic correlations could not be re-estimated reliably in this round and are retained at their originally submitted values; remaining cells are carried over from the submitted analysis, which did not re-estimate the full off-diagonal.==*

### Correlations between methane and production traits

Phenotypic and genetic correlations between methane traits and production traits are presented in Tables 4 and 5, respectively. ==Phenotypically, CH₄ was weakly-to-moderately positively correlated with the production traits examined: metabolic body weight (MBW; 0.36 ± 0.01), live weight (0.35 ± 0.01), ADG (0.17 ± 0.02), rumen volume (0.31 ± 0.04) and muscle mass (0.26 ± 0.04).== As expected, several ratio-based methane traits showed negative phenotypic correlations with their denominator production traits, including methane intensity (CH₄/MBW) with MBW (−0.10 ± 0.01) and CH₄/rumen with rumen volume (==−0.45 ± 0.03==). ==CH₄/ADG was moderately negatively phenotypically correlated with ADG itself (−0.25 ± 0.02).== Residual methane traits showed the expected near-orthogonality to their adjustment traits, with RMTMBW only weakly negatively correlated with MBW (==−0.08 ± 0.01==) and RMTADG only weakly positively correlated with ==ADG (0.12 ± 0.02)==.

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

*Trait abbreviations as in Table 1. ==Highlighted cells are re-estimated: daily methane against each production trait, and each ratio or residual trait against its own denominator or adjustment trait. Remaining cells are carried over from the submitted analysis.==*

==Genetically, and in contrast to the near-zero estimate reported in the original submission (−0.03), daily methane (CH₄) was moderately-to-strongly positively genetically correlated with metabolic body weight (0.72 ± 0.03). CH₄ was likewise positively genetically correlated with live weight (0.71 ± 0.03), ADG (0.51 ± 0.07), rumen volume (0.68 ± 0.15) and muscle mass (0.42 ± 0.12). This corrected pattern -- a consistently positive genetic association between absolute methane and every measure of body size and growth -- reconciles the genetic and phenotypic estimates with each other and with the wider literature (see Discussion).== Ratio-based methane traits were, as expected, negatively genetically correlated with their denominator production traits, including methane intensity (CH₄/MBW) with MBW (−0.27 ± 0.04). ==CH₄/ADG was strongly negatively genetically correlated with ADG itself (−0.81 ± 0.08).== Among the residual methane traits, ==RMTMBW was only moderately negatively genetically correlated with MBW (−0.28 ± 0.04) and RMTMBW+CO2 only weakly so (−0.11 ± 0.04) -- both markedly weaker than the strong negative correlations reported in the original submission -- while RMTADG was moderately positively genetically correlated with its own adjustment trait, ADG (0.42 ± 0.07).==

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

*Trait abbreviations as in Table 1. ==Highlighted cells are re-estimated: daily methane against each production trait, and each ratio or residual trait against its own denominator or adjustment trait. CH4/MM against muscle mass did not converge in this round and is carried over. Remaining cells are carried over from the submitted analysis.==*

## Discussion

==This study characterised the genetic parameters of a range of alternative methane trait definitions in a large, multi-breed, pasture-based sheep population, and quantified how those definitions differ in their genetic relationships with one another and with production traits. Although multiple methane phenotypes can be used to express emissions relative to production, their genetic behaviour is not always apparent from their construction. By comparing absolute, ratio-based and residual methane definitions within a common analytical framework, these results clarify what each definition does, and does not, change about the underlying genetics of methane.==

With the exception of the CH₄ ratio trait, all metrics demonstrated low-to-moderate heritability and repeatability. This is consistent with findings in other studies across sheep [28], beef [7, 29] and dairy [30]. The magnitude of genetic parameters found here is comparable to many traits already included in breeding programmes, for example somatic cell count [31], a trait that has been successfully incorporated into dairy breeding programmes and has delivered sustained, cumulative genetic gains [32]. Taken together, these findings indicate that methane production possesses sufficient additive genetic variation to respond to selection and therefore support the feasibility of achieving sustained genetic progress for methane mitigation within multi-trait sheep breeding programmes.

==The CH₄ ratio trait was the clear exception, with both the lowest heritability (0.10 ± 0.01) and by far the lowest genetic coefficient of variation (0.24%) of any definition examined. This estimate is lower than the heritabilities of 0.17–0.25 reported by Jonker et al. [10] for a comparable methane-to-carbon-dioxide ratio in sheep. Two observations bear on this difference. First, the estimate is robust to analytical choices at the level of the pipeline: it was reproduced when the full analysis was rebuilt from the raw phenotypes, so it does not reflect a coding or data-handling error. Second, and more substantively, the heritability of this particular trait is sensitive to how residual variance is modelled. When the residual variance was allowed to differ across contemporary-group-mean classes -- capturing the very different absolute scales of methane and carbon dioxide output across animals of different size and stage -- the heritability of CH₄ ratio rose to 0.19 and its repeatability to 0.32, values much closer to those of Jonker et al. [10]. The low homogeneous-model estimate therefore appears to be at least partly an artefact of pooling animals of very different scale under a single residual variance, rather than evidence of an intrinsically non-heritable trait. Because the CH₄ ratio is defined on a dimensionless scale with an extremely small genetic standard deviation, it is also the definition most sensitive to measurement and rounding error, and we would caution against treating its point heritability as a stable property of the trait.==

The variation in the strength of the genetic and phenotypic correlations observed among methane trait definitions indicates that, although these traits capture overlapping aspects of methane variation, they are not interchangeable, a pattern also observed in beef cattle by Crowley et al. [29]. ==Strong genetic correlations among several definitions indicate a substantial shared genetic basis. In particular, the residual methane traits were strongly genetically correlated with absolute daily methane (rg = 0.78–0.86), showing that residualisation on body size does not create a genetically distinct phenotype but rather one that remains largely governed by the same additive genetic variation as daily methane itself. Weaker genetic correlations, such as those between methane production and CH₄/ADG (rg = 0.38 ± 0.08), indicate that some forms of scaling do more substantially alter the variance–covariance structure of the resulting phenotype [33].==

==The clearest distinctions between the definitions emerge in their genetic relationships with production traits. Daily methane was moderately-to-strongly positively genetically correlated with body size and growth (rg = 0.72 with metabolic body weight, 0.71 with live weight and 0.51 with ADG). This corrects the near-zero methane–body-weight genetic correlation reported in the original submission, which arose from a permanent-environmental variance that had been constrained to be shared across two traits measured on very different scales; once each trait was allowed its own permanent-environmental variance, the genetic and phenotypic correlations became mutually consistent and aligned with the strong positive methane–size relationships widely reported in sheep and cattle [10, 11, 12, 29]. Against this background, the ratio- and residual-based definitions behaved as designed: methane intensity and the residual traits were negatively, or only weakly, genetically correlated with the body-size traits used in their construction, whereas absolute methane was strongly positively correlated with them. This confirms that ratio and residual definitions do not remove the genetic association between methane and production, but redistribute it -- moving the strong positive genetic correlation carried by absolute methane toward zero or negative values for the size-adjusted definitions [34].==

==A related point concerns the genetic, as opposed to phenotypic, independence of the residual traits. Residual methane was constructed as a phenotypic residual -- the deviation of daily methane from its regression on a production trait -- and such a construction guarantees phenotypic, but not genetic, orthogonality to the adjustment trait [33]. The present estimates make this explicit: RMTMBW and RMTMBW+CO2 were close to phenotypically uncorrelated with metabolic body weight (rp = −0.08 and −0.02) yet retained a moderate negative genetic correlation with it (rg = −0.28 and −0.11) and a strong positive genetic correlation with absolute methane (rg = 0.86 and 0.78). A residual methane phenotype therefore remains genetically tied both to the trait it was adjusted for and to absolute methane, and should not be interpreted as a genetically independent measure of "excess" methane.==

==From a breeding perspective, these results indicate that the choice of methane definition is a substantive genetic decision rather than a matter of convention. Each definition embeds a different genetic relationship between methane and production, and therefore implies a different correlated response when placed in a breeding objective. Quantifying those correlated responses -- and the trade-offs they imply within a formal selection index -- is the subject of ongoing work and is not addressed in the present study, which is confined to the estimation of genetic parameters. A number of further questions also merit attention, including the transferability of these estimates beyond an Irish grass-based system, the biological interpretation of carbon dioxide output as a trait in its own right, and the handling of physiological-stage heterogeneity in the residual variance, which materially affected the heritability of some definitions here.==

## Conclusions

==This study characterised the genetic parameters of a comprehensive suite of alternative methane trait definitions in a large, pasture-based sheep population. Methane emissions exhibited low-to-moderate additive genetic variation across all definitions examined, indicating that methane is heritable however it is defined. Although the definitions differed in their genetic relationships with production traits, much of the underlying genetic variation was shared: residual and ratio methane traits remained strongly genetically correlated with absolute methane, and residualising or scaling methane redistributed, rather than removed, its genetic association with body size and growth. Daily methane was found to be strongly and positively genetically correlated with body size and growth, correcting a near-zero estimate in the original submission. The choice of methane trait definition is therefore not a minor consideration but one that determines the direction and magnitude of the genetic relationship between methane and production, and hence the correlated responses expected under selection. As high-throughput methane phenotyping becomes increasingly routine, characterising these genetic relationships provides a necessary empirical basis for deciding how methane should be defined within pasture-based ruminant breeding objectives.==

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

**S1. Fixed-effect significance and connectedness diagnostics.** [PENDING — not yet drafted.] Wald F-statistic table for the univariate genetic-analysis models (breed-proportion covariates significant at p<0.001 for every trait; Lleyn never significant), plus pedigree completeness/connectedness diagnostics (100% of phenotyped animals in the pedigree, 88.5% both parents known, 1,025 unique sires, mean pedigree depth 17.6 generations, 73.1% of sires linking 2+ contemporary groups) and the Cheviot/Lleyn breed-proportion/contemporary-group confounding result.

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
21. Hazel L.N., The Genetic Basis for Constructing Selection Indexes, Genetics. 28 (1943) 476-490. ==[Cited only by the removed selection-index section; prune in final.]==
22. Lin C.Y., Relative Efficiency of Selection Methods for Improvement of Feed Efficiency, Journal of Dairy Science. 63 (1980) 491-494. ==[Cited only by the removed selection-index section; prune in final.]==
23. Koch R.M., Swiger L.A., Chambers D., Gregory K.E., Efficiency of Feed Use in Beef Cattle, Journal of Animal Science. 22 (1963) 486-494. ==[Cited only by the removed selection-index section; prune in final.]==
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

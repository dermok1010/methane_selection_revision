# Citation review — manuscript draft 7 (doc rev 685), 2026-10-05

Every citation in the revised manuscript, with what it is cited for and a judgement on whether the
source supports the claim. Numbers are the current reference numbers (before EndNote renumbering;
R packages [25]–[27] dropped). Checks against the literature used Consensus where the claim
depends on a specific number; everything else is judged from the paper's own content.

Verdicts: **OK** = supports the claim as written · **Weak** = related, but not the best or not a
direct support · **Fix** = the source does not support the sentence as written.

## Needs action

| Ref | Where / what it supports | Verdict | Issue and suggested fix |
|---|---|---|---|
| [69] de Haas 2011 | Discussion: dairy methane h² "0.16–0.35"; "residual methane (0.38–0.46) more heritable in cattle [29, 69, 70]" | **Fix** | Reports *predicted* methane (6% of gross energy intake, IPCC), h² 0.35, i.e. essentially intake. Its 0.40 is residual *feed intake*, not residual methane. Drop [69] from both sentences. The dairy range then becomes 0.16–0.33 from measured methane: Kamalanathan [70] 0.16 (GreenFeed) and van Breukelen [30] 0.19 daily / 0.33 weekly. Check the residual-methane 0.38–0.46 against [29] alone. |
| [11] Bird-Gardiner 2017, [12] Crowley 2024 | Background: methane has "strong (positive) genetic and phenotypic correlations" with body weight, growth and intake | **Fix** | Both are phenotypic studies in indoor cattle, so nothing supports "genetic". Add a genetic source, e.g. [7] Ryan 2025 or [29] Crowley 2026, or Manzanilla-Pech et al. 2016 (rg methane–DMI 0.83, –weight 0.80 in Angus). Note that the sheep RC study [28] found weak genetic correlations with production traits. |
| [51] O'Connor 2024, [50] Levrault 2023 | Background: PACs "have been consistently validated for ranking animals" | **Weak** | O'Connor 2024 found a PAC–RC correlation of only 0.37 (60 lambs), although the authors conclude PAC is suitable for ranking. Robinson 2015 [46] found PAC–RC correlations of 0–0.19 after adjustment. "Consistently" overstates this. Suggest "have been shown to rank animals for methane output [50, 51], with high genetic correlations with RC measurements under the same management [48]". Robinson 2020 found rg 0.98–1.00. |
| [60] Huhtanen 2021, [62] Arthur 2018 | Discussion: "PAC-measured CO₂ is strongly correlated with feed intake in sheep [47, 61] and cattle [60, 62]" | **Fix (wording)** | The cattle studies used GreenFeed/RC, not PAC. Reword: "CO₂ is strongly correlated with feed intake in PAC-measured sheep [47, 61] and in cattle [60, 62]". |
| [8] Rowe 2022 | Background: "the cumulative, long term nature of genetic gain" | **Weak** | Rowe 2022 is about the effect of breeding for low methane on yield and meat quality. For "permanent and cumulative", de Haas et al. 2021 (*Animal*, selective breeding as a methane mitigation tool) states it directly, or keep [8] and add it. |
| [14] Manzanilla-Pech 2022 | Background: ratio/residual traits "proposed as a potential means of mitigating unfavourable genetic correlations" | **Weak** | This paper is about feed-efficient cows emitting less methane. Manzanilla-Pech et al. 2016 (*J Anim Sci*) proposes residual methane traits "without compromising DMI and WT", which fits much better. |
| [12, 13] Crowley 2024, Smith 2021 | Discussion: scaling/residualising methane "serves as a practical proxy for that missing feed-intake information" in grazing sheep | **Weak** | Both are indoor cattle studies with measured intake. They show the traits, not their use as an intake proxy in grazing sheep. Add [47]/[48] (PAC methane and intake in sheep). |
| [9] O'Connor 2021 | Background: PACs enabled "routine, large-scale collection … across research and commercial flocks [9, 10]" | **Weak** | O'Connor 2021 is a 48-lamb repeatability study. [10] is fine. Consider Bilton et al. 2025, *GSE* (4,585 lambs across NZ flocks), which is large-scale and in the target journal. Also cited with [10, 46] for "PACs show lower repeatability than RCs", but [9] has no RC comparison (it shows the large between-day variance, 39–40%). |
| [22] Lin 1980 | Methods: ratio traits "linearised … using a first-order Taylor series approximation [22, 53, 54]" | **Weak** | Lin 1980 compares ratio and index selection rather than giving the linearisation. Gunsett [53] and Lin & Aggrey [54] are the right sources. Keep [22] only in the feed-efficiency debate sentence. |
| [33] Kennedy 1993 (2nd use) | Discussion: "A ratio or residual trait is, in effect, a fixed weighting of methane against its denominator or adjustment trait [33]" | **Weak** | Kennedy covers the residual case. For the ratio case add Gunsett [53]: "[33, 53]". |
| [48] Robinson 2020 | "CO₂ … closely related to feed intake in PAC-measured sheep [47, 48]" | **Check** | The abstract reports methane–intake correlations (0.86–0.95), not CO₂–intake. Confirm the paper reports CO₂ and intake; if not, keep [47] and add [61]. |
| [7] Ryan 2025, [29] Crowley 2026 | Discussion: beef daily methane h² "0.15 to 0.42"; methane relative to product "0.21–0.66"; residual methane "0.38–0.46" | **Check** | I could not verify these ranges from abstracts. The 0.21 matches Kamalanathan [70] methane intensity. Confirm the upper bounds against the papers' tables. |
| [1] FAO 2023 | "Enteric fermentation alone contributes approximately 30% of global anthropogenic methane emissions" | **Check** | Published figures range from ~17% to "one-third" (Black 2021: 30%; Arndt 2021: about one-third). Confirm FAO 2023 gives ~30% for enteric fermentation alone, not for livestock including manure. |
| [50] Levrault 2023 | "repeatability > 0.99 against known methane releases" | **Check** | The value was not verifiable from the abstract. Confirm it in the paper. |
| [64] Van Vleck 1987 | Heterogeneous residual variance biases variance components and breeding values | **Weak** | This is a general paper on defining contemporary groups. [65] and [66] carry the claim; [52] Meuwissen 1996 could be added here too. |
| [52] Meuwissen 1996 | Genetic correlation "expected to be largely unaffected by residual heterogeneity" | **OK, with a caveat** | This holds under the multiplicative scaling model that paper uses; it is an assumption of that model. Suggest "under a multiplicative scaling model [52]". The empirical CH₄–CH₄/MBW check that follows already backs it. |
| [24] R Core Team | R version 4.5.3 | **OK** | The EndNote record is dated 2024; update it to 2026 to match R 4.5.3. |

## All other citations — supported as cited

| Ref | Cited for | Verdict |
|---|---|---|
| [2] Roques 2024 | Enteric methane one of the hardest emission sources to address | OK |
| [3] Makkar 2018 | Rising demand for animal protein, pressure on ruminant systems | OK |
| [4] EPA 2024 | Agriculture largest sector source in Ireland; enteric methane dominant | OK |
| [5] O'Mara 2021, [6] Shalloo & Herron 2024 | Ireland's carbon efficiency per kg of product | OK ([6] is grey literature) |
| [7] Ryan 2025 | Moderate heritability of methane production (beef) | OK (a sheep source, e.g. [10], would sit better in a sheep paper) |
| [10] Jonker 2018 | PAC heritability (0.19–0.20 lambs/ewes), PAC–RC rg 0.62–0.67, lower PAC repeatability, CH₄ ratio h² 0.17–0.25 | OK (checked) |
| [13] Smith 2021 | Residual methane expresses emissions relative to performance | OK |
| [15] Kelly 2026 | Phenotypic relationships among alternative metrics | OK |
| [16] Lassen & Difford 2020 | Genetic parameters of ratio/residual traits underexplored | OK |
| [17] Clelland 2014 | CT tissue quantification | OK (Texel loin IMF study; a general CT methods paper would be a tighter fit) |
| [18] VanRaden 1992, [19] VanRaden & Sanders 2003 | Heterosis and recombination-loss coefficients | OK |
| [20] Gilmour 2021 | ASReml 4.2 | OK |
| [21] Hazel 1943, [44] Smith 1936 | Smith–Hazel selection index | OK |
| [23] Koch 1963 | Ratio/residual debate in feed efficiency | OK |
| [28] Pinares-Patiño 2013 | Sheep RC methane h² 0.29 | OK (checked: 0.29 ± 0.05) |
| [30] van Breukelen 2023 | Dairy methane heritability | OK (daily 0.19, weekly 0.33) |
| [31] Shook & Schutz 1994 | SCS as a low-heritability trait used in breeding | OK |
| [32] García-Ruiz 2016 | Sustained genetic gain in SCS | OK (shows accelerated trends for low-h² traits, including SCS) |
| [34] Kronmal 1993 | Statistical behaviour of ratios | OK |
| [35] Richardson 2022, [39] Bognar 2023, [40] Matthews 2023 | Economic values / carbon pricing for methane | OK ([39], [40] are policy reports) |
| [36] Zetouni 2017, [38] Aggrey & Rekaya 2013 | Direct multi-trait selection matches or beats ratio/residual selection | OK |
| [37] Sutherland 1965 | Same sentence | Weak but acceptable: it is about the ratio–denominator correlation, closer to the Kronmal point |
| [41] Pešek & Baker 1969 | Desired-gains index | OK |
| [42] Cuyabano 2025 | Genetic parameters change under selection | OK (preprint) |
| [43] Kempthorne & Nordskog 1959 | Restricted index (zero response in MBW and CO₂) | OK |
| [45] Goopy 2016 | PAC h² in grazing sheep (lower bound 0.13); portable, low-cost | OK (the 0.13 is sire-based and was not maintained across sites) |
| [46] Robinson 2015 | Portable, about an hour per test; protocol effects; lower repeatability | OK |
| [47] Robinson 2016 | PAC CO₂ informative about intake | OK |
| [49] Wahinya 2022 | PAC h² (field 0.17); sire rankings kept across environments | OK (rg 0.85–0.99, large SEs) |
| [53] Gunsett 1984, [54] Lin & Aggrey 2013 | Linear approximation of ratio traits | OK |
| [55] Belanche 2023, [56] Hristov 2018 | Intake is the main determinant of methane | OK |
| [57] Manzanilla-Pech 2021, [58] Richardson 2021 | Methane per unit intake / residual on intake; proposed selection criteria | OK |
| [59] Goopy 2014 | Rumen volume, retention time and methane yield | OK |
| [61] Paganoni 2017 | Efficient sheep emit less CH₄ and CO₂ | OK (confirm it used PAC if kept under "PAC-measured") |
| [63] Huhtanen 2020 | More efficient animals produce less CO₂ per unit intake | OK |
| [65] Carvalheiro 2002, [66] Cardoso 2005 | Bias from heterogeneous residual variance | OK |
| [67] de Haas 2017, [68] Fresco 2023 | Alternative methane traits proposed as selection criteria | OK ([68] compares the traits rather than proposing one) |
| [70] Kamalanathan 2023 | Dairy methane h² 0.16; intensity 0.21 | OK (checked) |

## Candidate additions (from the checks)

- de Haas Y. et al. 2021. Selective breeding as a mitigation tool for methane emissions from dairy cattle. *Animal* 15:100294. Permanent, cumulative genetic gain (for [8]).
- Manzanilla-Pech C.I.V. et al. 2016. Genomewide association study of methane emissions in Angus beef cattle with validation in dairy cattle. *J Anim Sci* 94:4151–4166. Genetic correlations with intake and weight; residual methane traits (for [11, 12] and [14]).
- Bilton T.P. et al. 2025. Rumen metagenome profiles are heritable and rank the New Zealand national sheep flock for enteric methane emissions. *Genet Sel Evol*. Large-scale PAC recording (for [9]).

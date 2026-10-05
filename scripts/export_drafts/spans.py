"""Manuscript passages that answer the reviewers, for draft 6 and response letter draft 4.

HIGHLIGHT spans are highlighted in the manuscript .docx (key passages that directly
answer a reviewer comment; not every edit since submission). LOCATE spans are only
looked up for line numbers. Each span is (start, end): the highlighted text runs from
the start of `start` to the end of `end`, both exact substrings of one paragraph's
plain text (markdown stripped). end=None means the span is `start` itself.

LETTER_REFS maps each **Response:** in the letter, in order (0-based), to the span ids
whose line numbers are added to it.
"""

HIGHLIGHT = {
    # Abstract
    "abs_ratio": ("Alternative methane traits were defined as ratios", "regressed on these traits."),
    # Background
    "bg_ghg": ("Reducing greenhouse gas emissions from ruminant livestock has become a priority for greenhouse gas mitigation strategies worldwide.", None),
    "bg_enteric": ("Throughout this paper, methane production and methane emissions refer to enteric methane", "exclude methane from manure management."),
    "bg_sector": ("where agriculture is the largest single sector source", "the dominant contributing gas [4]."),
    "bg_carbon": ("Ireland ranks among the most carbon-efficient regions", "per-kilogram-of-product basis [5, 6]."),
    "bg_pac": ("Portable accumulation chambers are portable and low-cost", "large-scale genetic evaluation of methane in sheep [10, 49]."),
    "bg_alt": ("with alternative referring to traits expressed relative to production or as residuals rather than as daily (absolute) methane alone", None),
    # Methods
    "m_defalt": ("Here, alternative methane traits are any methane trait other than", "one or more of these traits."),
    "m_enteric": ("represented the total mass of enteric methane, released via eructation during rumen fermentation,", None),
    "m_co2": ("Carbon dioxide production (CO₂), measured concurrently on the same PAC record and also expressed in g day⁻¹, was also analysed.", None),
    "m_ratio": ("CH₄ ratio was calculated on a mass basis as CH₄/(CH₄+CO₂), with both gases expressed in g day⁻¹.", None),
    "m_ped": ("Pedigree records were available for 36,449 animals", "73.1% of sires linked two or more contemporary groups."),
    "m_eq": ("+ e", None),  # the residual term of the model equation
    "m_het": ("Residual variance heterogeneity was examined by contemporary-group mean.", "a single homogeneous residual variance was used."),
    "m_rg": ("The genetic correlations reported below", "(rg = 0.85 in each case)."),
    "m_h2t": ("Heritability (h²) and repeatability (t) were calculated as:", None),
    "m_h2": ("h² = ", None),  # whole equation paragraphs
    "m_t": ("t = (", None),
    "m_wald": ("Fixed-effect significance (Wald F-tests)", "Supplementary Material S1."),
    "m_si_aim": ("To investigate how methane traits respond to selection", "not to estimate the response to selection under a national breeding index."),
    "m_si_i": ("Responses are reported per generation at i = 1;", "are given in Supplementary Table S2."),
    "m_mc": ("Uncertainty in the index results was quantified by Monte Carlo simulation.", "(2.5th and 97.5th percentiles of the samples)."),
    "m_assume": ("The analysis assumes that genetic parameters are constant across generations", "all three traits are recorded on every candidate."),
    # Results
    "r_co2mean": ("Mean carbon dioxide production was 1,189.6", "(range 40.9–2,869.1)."),
    "r_co2h2": ("Carbon dioxide production (CO₂), also from the heterogeneous-residual model,", "(0.25; repeatability 0.43)."),
    "r_tab2foot": ("For CO₂, CH₄, CH₄/MBW, CH₄ ratio, RMTMBW and RMTMBW+CO₂, estimates are from the model", "on the same footing as the other traits."),
    "r_co2rg": ("Daily methane was also strongly genetically correlated with CO₂ production", "(0.57 ± 0.04; phenotypic correlation 0.35)."),
    "r_mc": ("Holding both MBW and CO₂ at zero response", "(−1.34 g day⁻¹; −1.46 to −1.22)."),
    "r_any": ("The reference favourable response (−0.61 g day⁻¹ CH₄, with MBW and CO₂ held at zero) could be reached", "not by which methane trait the goal was built on."),
    # Discussion
    "d_proxy": ("Feed intake is the main determinant of an animal's daily methane output", "The results presented here show both the value and the limits of that approach."),
    "d_compare": ("In sheep, the heritability of daily methane matched", "rather than for measured intake or output."),
    "d_transfer": ("The present data come from Irish pasture-based flocks", "remains to be tested."),
    "d_resid": ("This is expected, as a phenotypic residual is not genetically independent", "applied at the genetic level."),
    "d_co2": ("Carbon dioxide production was moderately heritable (h² = 0.25)", "although more efficient animals produce less CO₂ per unit of intake [63]."),
    "d_het": ("Genetic evaluations can assume a common residual variance across contemporary groups.", "across flocks and physiological stages."),
    "d_weight": ("A ratio or residual trait is, in effect, a fixed weighting", "that determines whether methane can be reduced without reducing size."),
    "d_econ": ("The weights in Table 6 are breeding-goal weights, not economic values", "selects one point among the attainable responses in Figure 1."),
    "d_limits": ("Several limitations bound these results.", "fecundity, longevity and lamb survival were not included."),
}

# Rows of these tables whose trait cell is CO₂ are highlighted (CO₂ added as a trait).
HIGHLIGHT_TABLE_ROWS = {"Table 1.": "CO₂", "Table 2.": "CO₂", "Table 3.": "CO₂"}

LOCATE = {
    "loc_breeds": ("Belclare, Charolais, Cheviot, Suffolk, Lleyn, and Texel", None),
    "loc_terms": ("where y was the phenotypic observation", "σ²ₑ was the residual variance."),
}

LETTER_REFS = [
    [],                                                        # 0 Editor
    ["m_ratio", "m_het", "r_tab2foot", "d_compare"],           # 1 R1 Jonker / CH4 ratio heritability
    [],                                                        # 2 R1 MI -> CH4/MBW (global rename)
    ["m_ratio", "m_co2", "r_co2mean"],                         # 3 R1 units, CO2 descriptive stats
    ["m_ped", "m_wald"],                                       # 4 R1 fixed effects, connectedness
    ["m_eq"],                                                  # 5 R1 + e
    ["m_het", "m_rg", "d_het"],                                # 6 R1 contemporary-group scaling
    ["m_wald", "d_compare"],                                   # 7 R1 summary
    ["m_si_aim", "d_proxy", "r_any", "d_co2", "d_weight", "d_econ", "d_limits"],  # 8 R1 trait definitions / proxies
    ["m_si_i", "m_mc", "m_assume", "r_mc", "d_limits"],        # 9 R1 Smith-Hazel caveats
    ["bg_alt", "d_proxy", "m_co2", "r_co2h2", "r_co2rg", "d_co2"],  # 10 R2 biology, CO2
    ["bg_pac"],                                                # 11 R2 PAC pros/cons
    ["d_compare", "d_transfer"],                               # 12 R2 other studies, transferability
    ["m_het", "m_rg", "d_het"],                                # 13 R2 growing vs adult
    ["abs_ratio"],                                             # 14 L47
    [],                                                        # 15 L48 (units kept)
    ["bg_ghg"],                                                # 16 L70-71
    ["bg_sector"],                                             # 17 L72
    ["bg_carbon"],                                             # 18 L73
    ["bg_enteric", "m_enteric"],                               # 19 L84-85
    ["loc_breeds"],                                            # 20 L154
    ["bg_alt", "m_defalt"],                                    # 21 L164
    ["m_ped"],                                                 # 22 L195
    ["loc_terms"],                                             # 23 L202 ff
    [],                                                        # 24 L213
    ["m_ratio"],                                               # 25 L297
    ["r_tab2foot"],                                            # 26 L304 two numbers
    ["m_h2t", "m_h2", "m_t"],                                  # 27 L304 formulas
    ["d_resid", "d_weight"],                                   # 28 L499
]

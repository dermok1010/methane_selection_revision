"""Manuscript passages that answer the reviewers (re-anchored 2026-10-21 to manuscript doc rev 88, letter rev 10).

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
    "bg_enteric": ("Enteric methane emissions (hereafter referred to as methane emissions), produced during rumen fermentation,", None),
    "bg_sector": ("where agriculture is the largest single sector source", "the dominant gas [4]."),
    "bg_carbon": ("Ireland ranks among the most carbon-efficient regions", "per-kilogram-of-product basis [5, 6]."),
    "bg_pac": ("PACs allow groups of animals to be measured in about an hour", "which is what genetic selection requires."),
    # Methods
    "m_defalt": ("In addition to daily (absolute) methane production (CH₄, g day⁻¹), a series of alternative methane traits were investigated", "one or more of these traits."),
    "m_enteric": ("represented the total mass of enteric methane, released via eructation during rumen fermentation,", None),
    "m_co2": ("Carbon dioxide production (CO₂), measured concurrently on the same PAC record and also expressed in g day⁻¹, was also analysed.", None),
    "m_ratio": ("CH₄ ratio was calculated on a mass basis (g/g) as CH₄/(CH₄+CO₂), with both gases expressed in g day⁻¹.", None),
    "m_ped": ("Pedigree records were available for 36,449 animals", "73.1% of sires linked in at least two contemporary groups."),
    "m_eq": ("+ e", None),  # the residual term of the model equation
    "m_un": ("and the combined proportion of all other or unknown breeds (UN)", None),
    "m_het": ("To account for heterogeneous residual variance,", "a single homogeneous residual variance was used."),
    "m_h2t": ("Heritability (h²) and repeatability (t) were calculated as:", None),
    "m_h2": ("h² = ", None),  # whole equation paragraphs
    "m_t": ("t = (", None),
    "m_wald": ("Fixed-effect significance (Wald F-tests)", "Supplementary Material S1."),
    "m_si_aim": ("The selection index analysis examined how absolute, ratio and residual methane traits themselves operate within an index.", "not to estimate the response to selection under a national breeding index."),
    "m_si_i": ("Responses are reported per generation for a selection intensity (i) of 1.", "are given in Supplementary Table S2."),
    "m_mc": ("Uncertainty in the index results was quantified by Monte Carlo simulation.", "(2.5th and 97.5th percentiles of the samples)."),
    "m_assume": ("The analysis assumes that genetic parameters are constant across generations", "all three traits are recorded on every candidate."),
    # Results
    "r_co2mean": ("Mean carbon dioxide production was 1,189.6", "(range 40.9–2,869.1)."),
    "r_co2h2": ("Carbon dioxide production (CO₂), also from the heterogeneous-residual model,", "(0.25; repeatability 0.43)."),
    "r_tab2foot": ("For CO₂, CH₄, CH₄/MBW, CH₄ ratio, RMTMBW and RMTMBW+CO₂, a heterogeneous residual variance (41 classes) was modelled", "a single homogeneous residual variance was assumed."),
    "r_co2rg": ("Daily methane was also moderately correlated with CO₂ production", "genetically (0.57 ± 0.04)."),
    "r_mc": ("Holding both MBW and CO₂ at zero response", "(−1.34 g day⁻¹; −1.46 to −1.22)."),
    "r_any": ("The largest methane reduction attainable without any change in MBW or CO₂", "not by which methane trait the goal was built on."),
    # Discussion
    "d_proxy": ("Feed intake is the main determinant of an animal's daily methane output", "therefore CH₄ ratio and RMTMBW+CO₂ approximate methane relative to intake."),
    "d_compare": ("In sheep, the heritability of daily methane was similar to those previously estimated", "rather than for measured intake or output."),
    "d_resid": ("This is expected, as a phenotypic residual is not genetically independent", "applied at the genetic level."),
    "d_co2": ("Carbon dioxide production was moderately heritable (h² = 0.25)", "which limits its accuracy as a proxy for intake."),
    "d_het": ("Genetic evaluations can assume a common residual variance across contemporary groups.", "recorded across physiological stages."),
    "d_weight": ("A ratio or residual trait is, in effect, a fixed weighting", "that determines whether methane can be reduced without reducing size."),
    "d_econ": ("The weights on MBW and CO₂ in the present index are not economic values", "to avoid an unintended cost to production."),
    "d_limits": ("The weights reported here depend on the genetic parameters and are specific to this population.", "none of which were modelled."),
    "d_repeat": ("However, only 25.4% of animals had more than one methane record", "for the computed-tomography traits and RMTADG."),
    # Supplementary Material S1 (now tables only) and Results
    "s1_ped": ("Table S1b. Pedigree completeness and connectedness of the phenotyped animals.", None),
    "s1_wald": ("Table S1a. Significance of fixed effects (Wald F-tests) in the univariate models of the component traits.", None),
    "s1_conf": ("Texel and Suffolk proportions varied substantially within contemporary groups", "Most contemporary groups (82.1%) contained a single sex."),
}

# Rows of these tables whose trait cell is CO₂ are highlighted (CO₂ added as a trait).
HIGHLIGHT_TABLE_ROWS = {"Table 1.": "CO₂", "Table 2.": "CO₂", "Table 3.": "CO₂"}

# Citation-support fixes made 2026-10-05 after docs/citation_review.md (shown in green).
# (context, words): `words` is highlighted inside the first occurrence of `context`.
GREEN = {}  # draft 7 citation-fix marks; not shown from draft 8 on

LOCATE = {
    "loc_breeds": ("Belclare, Charolais, Cheviot, Suffolk, Lleyn, and Texel", None),
    "loc_terms": ("where y was the phenotypic observation", "σ²ₑ was the residual variance."),
}

LETTER_REFS = [
    [],                                                        # 0 Editor
    ["m_ratio", "m_het", "r_tab2foot", "d_compare"],           # 1 R1 Jonker / CH4 ratio heritability
    [],                                                        # 2 R1 MI -> CH4/MBW (global rename)
    ["m_ratio", "m_co2", "r_co2mean"],                         # 3 R1 units, CO2 descriptive stats
    ["m_ped", "m_un", "m_wald", "s1_conf", "s1_wald", "s1_ped"],  # 4 R1 fixed effects, connectedness
    ["m_eq"],                                                  # 5 R1 + e
    ["m_het", "d_het"],                                        # 6 R1 contemporary-group scaling
    ["m_wald", "s1_wald", "s1_ped", "d_compare"],              # 7 R1 summary
    ["m_si_aim", "d_proxy", "r_any", "d_co2", "d_weight", "d_econ", "d_limits"],  # 8 R1 trait definitions / proxies
    ["m_si_i", "m_mc", "m_assume", "r_mc", "d_limits"],        # 9 R1 Smith-Hazel caveats
    ["d_proxy", "m_co2", "r_co2h2", "r_co2rg", "d_co2"],       # 10 R2 biology, CO2
    ["bg_pac", "d_repeat"],                                    # 11 R2 PAC pros/cons
    ["d_compare"],                                             # 12 R2 other studies (transferability: letter only)
    ["m_het", "d_het"],                                        # 13 R2 growing vs adult
    ["abs_ratio"],                                             # 14 L47
    [],                                                        # 15 L48 (units kept)
    ["bg_ghg"],                                                # 16 L70-71
    ["bg_sector"],                                             # 17 L72
    ["bg_carbon"],                                             # 18 L73
    ["bg_enteric", "m_enteric"],                               # 19 L84-85
    ["loc_breeds"],                                            # 20 L154
    ["m_defalt"],                                              # 21 L164
    ["m_ped", "s1_ped"],                                       # 22 L195
    ["loc_terms"],                                             # 23 L202 ff
    ["d_repeat"],                                              # 24 L213
    ["m_ratio"],                                               # 25 L297
    ["r_tab2foot"],                                            # 26 L304 two numbers
    ["m_h2t", "m_h2", "m_t"],                                  # 27 L304 formulas
    ["d_resid", "d_weight"],                                   # 28 L499
]

# "(LXX)" placeholders in the letter, in order, and the spans whose lines replace them.
LXX = [["m_ratio"], ["m_assume", "d_limits"]]

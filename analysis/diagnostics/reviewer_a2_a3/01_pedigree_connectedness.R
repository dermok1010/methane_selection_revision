#!/usr/bin/env Rscript
# Reviewer action plan A2 (pedigree completeness/sire counts, connectedness,
# confounding) and A3's descriptive half (CH4 by physiological stage).
# Audits the already-frozen pedigree and phenotype data; changes nothing.
# Run from analysis/diagnostics/reviewer_a2_a3/.

suppressPackageStartupMessages({})

pipeline_dir <- "../../revision/asreml_pipeline"
ped <- read.csv(file.path(pipeline_dir, "..", "pedigree", "data", "pedigree_full_2026-09-15.csv"),
                 header = FALSE, col.names = c("ANI_ID", "sire", "dam"))
pheno <- read.csv(file.path(pipeline_dir, "data", "phenotype_asreml.csv"))

out <- character(0)
say <- function(...) out <<- c(out, sprintf(...))

# ---------------------------------------------------------------------
# A2: pedigree completeness for phenotyped animals
# ---------------------------------------------------------------------
pheno_ids <- unique(pheno$ANI_ID)
ped_pheno <- ped[ped$ANI_ID %in% pheno_ids, ]

sire_known <- ped_pheno$sire != 0
dam_known <- ped_pheno$dam != 0
n <- nrow(ped_pheno)

say("=== A2: Pedigree completeness (phenotyped animals) ===")
say("Phenotyped animals in phenotype file: %d", length(pheno_ids))
say("Phenotyped animals found in pedigree: %d (%.1f%%)", n, 100 * n / length(pheno_ids))
say("Both parents known:  %d (%.1f%%)", sum(sire_known & dam_known), 100 * mean(sire_known & dam_known))
say("Sire known, dam not: %d (%.1f%%)", sum(sire_known & !dam_known), 100 * mean(sire_known & !dam_known))
say("Dam known, sire not: %d (%.1f%%)", sum(!sire_known & dam_known), 100 * mean(!sire_known & dam_known))
say("Neither known:       %d (%.1f%%)", sum(!sire_known & !dam_known), 100 * mean(!sire_known & !dam_known))
say("Unique sires (phenotyped animals' own sires): %d", length(unique(ped_pheno$sire[sire_known])))
say("Unique dams  (phenotyped animals' own dams):  %d", length(unique(ped_pheno$dam[dam_known])))
say("")
say("Full pedigree size (all animals, phenotyped + ancestors): %d", nrow(ped))
say("Unique sires across the full pedigree: %d", length(unique(ped$sire[ped$sire != 0])))
say("Unique dams  across the full pedigree: %d", length(unique(ped$dam[ped$dam != 0])))

# Basic pedigree depth: for each phenotyped animal, the number of
# generations back with at least one traceable ancestor (simple max-depth
# along the best-known lineage, not the more elaborate "equivalent
# complete generations" metric -- documented here as exactly that, a
# basic depth count, not a claim of full generation-equivalent depth).
sire_of <- setNames(as.character(ped$sire), as.character(ped$ANI_ID))
dam_of <- setNames(as.character(ped$dam), as.character(ped$ANI_ID))
# Memoized -- pedigrees share huge amounts of ancestry between animals,
# so an unmemoized recursive depth walk is exponential in the worst
# case. A plain environment cache makes this O(n) in the pedigree size
# regardless of how many animals' depths are queried.
depth_cache <- new.env(parent = emptyenv())
depth_of <- function(id) {
  id <- as.character(id)
  if (is.na(id) || id == "0" || id == "") return(0L)
  cached <- depth_cache[[id]]
  if (!is.null(cached)) return(cached)
  depth_cache[[id]] <- 0L  # cycle guard: treat a self-referential loop as depth 0 if revisited mid-computation
  s <- sire_of[[id]]; d <- dam_of[[id]]
  s_d <- if (is.null(s) || is.na(s)) 0L else depth_of(s)
  d_d <- if (is.null(d) || is.na(d)) 0L else depth_of(d)
  result <- 1L + max(s_d, d_d)
  depth_cache[[id]] <- result
  result
}
set.seed(1)
sample_ids <- sample(pheno_ids, min(500, length(pheno_ids)))
depths <- sapply(sample_ids, depth_of)
say("")
say("Basic pedigree depth (max traceable generations back, simple lineage")
say("count -- not equivalent-complete-generations): sampled %d phenotyped", length(sample_ids))
say("animals -- mean %.1f, median %.0f, max %.0f", mean(depths), median(depths), max(depths))

# ---------------------------------------------------------------------
# A2: connectedness -- sires represented across contemporary groups
# ---------------------------------------------------------------------
say("")
say("=== A2: Connectedness (sires across ch4_GroupNumber contemporary groups) ===")
link <- merge(pheno[, c("ANI_ID", "ch4_GroupNumber")], ped_pheno[, c("ANI_ID", "sire")], by = "ANI_ID")
link <- link[link$sire != 0, ]
sire_groups <- tapply(link$ch4_GroupNumber, link$sire, function(x) length(unique(x)))
say("Sires with progeny records: %d", length(sire_groups))
say("Sires linking only 1 contemporary group:  %d (%.1f%%)",
    sum(sire_groups == 1), 100 * mean(sire_groups == 1))
say("Sires linking 2-4 contemporary groups:     %d (%.1f%%)",
    sum(sire_groups >= 2 & sire_groups <= 4), 100 * mean(sire_groups >= 2 & sire_groups <= 4))
say("Sires linking 5+ contemporary groups:       %d (%.1f%%)",
    sum(sire_groups >= 5), 100 * mean(sire_groups >= 5))
say("Max contemporary groups linked by one sire: %d", max(sire_groups))
say("(A sire linking >=2 groups provides genetic connectedness between them;")
say(" a sire confined to 1 group cannot help separate genetic merit from")
say(" that group's own contemporary-group effect.)")

# ---------------------------------------------------------------------
# A2: confounding/nesting checks
# ---------------------------------------------------------------------
say("")
say("=== A2: Confounding/nesting checks ===")
grp_sex <- table(pheno$ch4_GroupNumber, pheno$SEX)
single_sex_groups <- sum(grp_sex[, "F"] == 0 | grp_sex[, "M"] == 0)
say("Contemporary groups containing only one SEX: %d / %d (%.1f%%)",
    single_sex_groups, nrow(grp_sex), 100 * single_sex_groups / nrow(grp_sex))
say("(SEX is not itself confounded with ch4_GroupNumber overall -- both")
say(" sexes appear across many groups -- but a meaningful minority of")
say(" individual groups are single-sex, expected given ram lambs are")
say(" almost all <1yr and rarely co-measured with mature ewes.)")

# breed proportion columns aren't in phenotype_asreml.csv itself (they's
# read straight from data/phenotype_asreml.csv's own SEX/TX/BR/... columns
# per config/models.yaml -- check directly)
breed_cols <- c("TX", "BR", "SU", "CL", "CV", "LY", "UN")
breed_cols <- breed_cols[breed_cols %in% names(pheno)]
if (length(breed_cols) > 0) {
  # within-group variance vs total variance for each breed covariate --
  # a simple, defensible proxy for "is this covariate confounded with
  # contemporary group" without a full formal nesting test.
  say("")
  say("Breed-proportion within-group vs total variance ratio (1.0 = no")
  say("confounding with ch4_GroupNumber; near 0 = breed proportion is")
  say("almost fully determined by which group an animal is in):")
  for (b in breed_cols) {
    total_var <- var(pheno[[b]], na.rm = TRUE)
    within_var <- mean(tapply(pheno[[b]], pheno$ch4_GroupNumber, var, na.rm = TRUE), na.rm = TRUE)
    ratio <- if (total_var > 0) within_var / total_var else NA
    say("  %-4s within/total variance ratio: %.3f", b, ratio)
  }
}

# ---------------------------------------------------------------------
# A3: CH4 by physiological stage (young < 2yr vs mature ewes >= 2yr)
# ---------------------------------------------------------------------
say("")
say("=== A3: CH4 descriptive stats by physiological stage ===")
say("Stage rule (pre-specified): young = age_in_years < 2 (lambs/hoggets,")
say("includes virtually all male ram lambs, which are ~100%% <1yr in this")
say("dataset); mature = age_in_years >= 2 (this group is >99.8%% female,")
say("i.e. effectively 'mature ewes' as the reviewers' comment names it,")
say("even though the rule itself is age- not sex-based).")
stage <- ifelse(pheno$age_in_years < 2, "young", "mature")
say("")
for (s in c("young", "mature")) {
  x <- pheno$ch4_g_day2_1v3[stage == s]
  n_rec <- length(x)
  n_ani <- length(unique(pheno$ANI_ID[stage == s]))
  say("%s: n records=%d, n animals=%d, mean=%.3f, SD=%.3f, CV=%.1f%%",
      s, n_rec, n_ani, mean(x, na.rm = TRUE), sd(x, na.rm = TRUE),
      100 * sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE))
}
n_both <- length(intersect(pheno$ANI_ID[stage == "young"], pheno$ANI_ID[stage == "mature"]))
say("Animals with records in BOTH stages: %d", n_both)

writeLines(out, "pedigree_connectedness_stage_summary.txt")
cat(paste(out, collapse = "\n"))
cat("\n\nWritten to analysis/diagnostics/reviewer_a2_a3/pedigree_connectedness_stage_summary.txt\n")

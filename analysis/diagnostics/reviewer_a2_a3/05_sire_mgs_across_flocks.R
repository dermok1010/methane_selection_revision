#!/usr/bin/env Rscript
# Sire and maternal-grandsire (MGS) representation across flocks, for the
# 15,869 analysed CH4 records / 8,185 animals. Complements
# 01_pedigree_connectedness.R (sires across contemporary groups) with the
# flock-level view. Audits frozen inputs only; changes no result.
#
# Flock = `source` (user-confirmed, 2026-10-05; the same field the legacy
# CG definition date_flock_lot uses). `source` has only 14 levels, whereas
# the manuscript reports 132 flocks -- that figure matches the `breeder`
# field (133 levels), so every summary is also produced by `breeder` for
# comparison rather than silently picking one.
#
# Sire and dam come from the frozen revision pedigree (the one the models
# use); MGS = the sire of the animal's dam in that pedigree.
# Run from analysis/diagnostics/reviewer_a2_a3/.

suppressPackageStartupMessages(library(dplyr))

raw_path <- "/home/dermodkkelly/PAC_data_pipeline/data/PAC_data_covariates_QC_NA_with_traits_plus_dam_parity.csv"
ped_path <- "../../revision/pedigree/data/pedigree_full_2026-09-15.csv"
pheno_path <- "../../revision/asreml_pipeline/data/phenotype_asreml.csv"

raw <- read.csv(raw_path)
pheno <- read.csv(pheno_path)
ped <- read.csv(ped_path, header = FALSE, col.names = c("ANI_ID", "sire", "dam"))

# The prep script keeps every input row in order; confirm before using
# the raw file's flock fields as the analysed records' flock.
stopifnot(nrow(raw) == nrow(pheno),
          identical(raw$ANI_ID, pheno$ANI_ID),
          identical(raw$ch4_GroupNumber, pheno$ch4_GroupNumber))

sire_of <- setNames(ped$sire, ped$ANI_ID)
dam_of <- setNames(ped$dam, ped$ANI_ID)

recs <- data.frame(ANI_ID = raw$ANI_ID, source = raw$source,
                   breeder = as.character(raw$breeder))
recs$sire <- unname(sire_of[as.character(recs$ANI_ID)])
recs$dam <- unname(dam_of[as.character(recs$ANI_ID)])
recs$mgs <- ifelse(is.na(recs$dam) | recs$dam == 0, 0,
                   unname(sire_of[as.character(recs$dam)]))
recs$mgs[is.na(recs$mgs)] <- 0
recs$sire[is.na(recs$sire)] <- 0

out <- character(0)
say <- function(...) out <<- c(out, sprintf(...))
rows <- list()
per_flock_rows <- list()

animals <- recs %>% distinct(ANI_ID, .keep_all = TRUE)
say("Analysed records: %d; animals: %d", nrow(recs), nrow(animals))
say("Animals with sire known: %d (%.1f%%); with MGS known: %d (%.1f%%)",
    sum(animals$sire != 0), 100 * mean(animals$sire != 0),
    sum(animals$mgs != 0), 100 * mean(animals$mgs != 0))
say("Animals recorded in >1 source: %d; in >1 breeder code: %d",
    sum(tapply(recs$source, recs$ANI_ID, function(x) length(unique(x))) > 1),
    sum(tapply(recs$breeder, recs$ANI_ID, function(x) length(unique(x))) > 1))

# Connected components of the flock graph (flocks = nodes, an edge = at
# least one common sire/MGS), by simple union-find.
flock_components <- function(flocks, pairs) {
  parent <- setNames(flocks, flocks)
  find <- function(x) { while (parent[[x]] != x) x <- parent[[x]]; x }
  for (pr in pairs) {
    ab <- strsplit(pr, "|", fixed = TRUE)[[1]]
    ra <- find(ab[1]); rb <- find(ab[2])
    if (ra != rb) parent[[ra]] <- rb
  }
  roots <- sapply(flocks, find)
  tab <- table(roots)
  big <- names(tab)[which.max(tab)]
  list(n = length(tab), largest_n = max(tab), largest = flocks[roots == big])
}

summarise_link <- function(ancestor, flock) {
  # Animal-level: one row per (animal, flock) so an animal measured in two
  # flocks counts in both, and progeny counts are animals, not records.
  af <- recs %>% filter(.data[[ancestor]] != 0) %>%
    distinct(ANI_ID, anc = .data[[ancestor]], flk = .data[[flock]])
  rf <- recs %>% filter(.data[[ancestor]] != 0) %>%
    count(anc = .data[[ancestor]], name = "n_records")
  per_anc <- af %>% group_by(anc) %>%
    summarise(n_prog = n_distinct(ANI_ID), n_flocks = n_distinct(flk), .groups = "drop") %>%
    left_join(rf, by = "anc")
  n_flocks_total <- n_distinct(recs[[flock]])
  multi <- per_anc$n_flocks >= 2
  # Flock-level: sires used in each flock, and how many of them also have
  # progeny in another flock.
  shared_ids <- per_anc$anc[multi]
  per_flock <- af %>% group_by(flk) %>%
    summarise(n_anc = n_distinct(anc),
              n_anc_shared = n_distinct(anc[anc %in% shared_ids]),
              n_animals = n_distinct(ANI_ID), .groups = "drop")
  linked_flocks <- sum(per_flock$n_anc_shared > 0)
  # Direct flock-pair links: pairs of flocks sharing >=1 ancestor.
  fl <- split(af$flk, af$anc)
  fl <- lapply(fl[sapply(fl, function(x) length(unique(x)) >= 2)], unique)
  pairs <- unique(unlist(lapply(fl, function(f) {
    cmb <- combn(sort(f), 2); paste(cmb[1, ], cmb[2, ], sep = "|")
  })))
  n_pairs <- if (is.null(pairs)) 0 else length(pairs)
  comp <- flock_components(unique(recs[[flock]]), pairs)
  prog_multi <- sum(per_anc$n_prog[multi])

  q <- function(x) sprintf("mean %.1f, median %.0f, range %d-%d", mean(x), median(x), min(x), max(x))
  lab <- if (ancestor == "sire") "Sires" else "Maternal grandsires"
  say("")
  say("=== %s across flocks (flock = %s, %d flocks) ===", lab, flock, n_flocks_total)
  say("Unique %s with phenotyped (grand)progeny: %d", tolower(lab), nrow(per_anc))
  say("Phenotyped (grand)progeny per %s: %s", ancestor, q(per_anc$n_prog))
  say("Records per %s: %s", ancestor, q(per_anc$n_records))
  say("Flocks per %s: %s", ancestor, q(per_anc$n_flocks))
  for (b in list(c(1, 1), c(2, 2), c(3, 4), c(5, Inf))) {
    k <- per_anc$n_flocks >= b[1] & per_anc$n_flocks <= b[2]
    say("  in %s flock(s): %d %s (%.1f%%), %d progeny",
        if (is.infinite(b[2])) paste0(b[1], "+") else if (b[1] == b[2]) b[1] else paste0(b[1], "-", b[2]),
        sum(k), tolower(lab), 100 * mean(k), sum(per_anc$n_prog[k]))
  }
  say("%s with progeny in 2+ flocks: %d (%.1f%%), accounting for %.1f%% of their (grand)progeny",
      lab, sum(multi), 100 * mean(multi), 100 * prog_multi / sum(per_anc$n_prog))
  say("Flocks with >=1 %s shared with another flock: %d of %d", ancestor, linked_flocks, n_flocks_total)
  say("Flock pairs directly linked by >=1 common %s: %d of %d possible",
      ancestor, n_pairs, choose(n_flocks_total, 2))
  say("Connected flock networks via common %s: %d; largest holds %d flocks / %.1f%% of animals",
      ancestor, comp$n, comp$largest_n,
      100 * n_distinct(recs$ANI_ID[recs[[flock]] %in% comp$largest]) / n_distinct(recs$ANI_ID))
  say("%s per flock: %s", lab, q(per_flock$n_anc))

  rows[[length(rows) + 1]] <<- data.frame(
    flock_field = flock, ancestor = ancestor, n_flocks = n_flocks_total,
    n_ancestors = nrow(per_anc),
    prog_mean = mean(per_anc$n_prog), prog_median = median(per_anc$n_prog), prog_max = max(per_anc$n_prog),
    flocks_per_anc_mean = mean(per_anc$n_flocks), flocks_per_anc_max = max(per_anc$n_flocks),
    n_anc_multi_flock = sum(multi), pct_anc_multi_flock = 100 * mean(multi),
    pct_prog_from_multi_flock_anc = 100 * prog_multi / sum(per_anc$n_prog),
    n_flocks_linked = linked_flocks, n_flock_pairs_linked = n_pairs,
    n_flock_pairs_possible = choose(n_flocks_total, 2),
    n_components = comp$n, largest_component_flocks = comp$largest_n,
    anc_per_flock_mean = mean(per_flock$n_anc), anc_per_flock_median = median(per_flock$n_anc))

  per_flock_rows[[length(per_flock_rows) + 1]] <<- data.frame(
    flock_field = flock, ancestor = ancestor, flock = per_flock$flk,
    n_animals = per_flock$n_animals, n_ancestors = per_flock$n_anc,
    n_ancestors_shared = per_flock$n_anc_shared,
    in_largest_network = per_flock$flk %in% comp$largest)

  if (flock == "source") {
    say("Per-flock breakdown (%s):", ancestor)
    pf <- per_flock %>% arrange(desc(n_animals))
    for (i in seq_len(nrow(pf)))
      say("  %-5s %5d animals, %4d %s, %4d shared with another flock",
          pf$flk[i], pf$n_animals[i], pf$n_anc[i], ancestor, pf$n_anc_shared[i])
  }
}

for (flock in c("source", "breeder"))
  for (anc in c("sire", "mgs")) summarise_link(anc, flock)

writeLines(out, "sire_mgs_across_flocks_summary.txt")
write.csv(do.call(rbind, rows), "sire_mgs_across_flocks.csv", row.names = FALSE)
write.csv(do.call(rbind, per_flock_rows), "sire_mgs_per_flock.csv", row.names = FALSE)
cat(out, sep = "\n")

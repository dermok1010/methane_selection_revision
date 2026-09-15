# Rebuilt pedigree for the ASReml revision analysis.
#
# Adapted from ped_maker.R
# (sheep-methane-genomics-microbiome/mix99_vm_context/scripts/pedigree/ped_maker.R,
# used previously to build the pedigree for the mix99 genomic-evaluation
# work) -- logic unchanged, only the three paths below are new. That
# script's own algorithm (ancestor expansion to closure, self/cross-sex
# parent-conflict resolution, parents-before-offspring topological sort,
# full structural validation) is preserved verbatim.
#
# Phenotype input: this repo's own verified PAC pipeline output
# (dermodkkelly/methane_selection_revision docs/manuscript_context.md /
# docs/asreml_legacy_map.md), NOT the legacy Paper_3 asreml_scripts
# P3_data.csv -- so this pedigree will legitimately be smaller than the
# one used in the submitted paper (fewer phenotyped animals feeding the
# ancestor expansion). That's expected and fine for now; it is not yet
# the ASReml rebuild itself, just the pedigree input for it.

library(haven)
library(dplyr)
library(data.table)

# ======================================================
# File paths
# ======================================================

phenotype_path <- paste0(
  "/home/dermodkkelly/PAC_data_pipeline/data/",
  "PAC_data_covariates_QC_NA_with_traits_plus_dam_parity.csv"
)

master_pedigree_path <- paste0(
  "/home/dermodkkelly/sheep-methane-genomics-microbiome/mix99_vm_context/",
  "input_data/pedigree/sheeppedweight.sas7bdat"
)

output_path <- paste0(
  "/home/dermodkkelly/methane_selection_revision/analysis/revision/",
  "pedigree/data/pedigree_full_2026-09-15.csv"
)

# ======================================================
# Helper functions
# ======================================================

# Convert identifiers to plain character strings.
# This avoids scientific notation and integer-conversion problems.
clean_id <- function(x) {

  if (inherits(x, "haven_labelled")) {
    x <- haven::zap_labels(x)
  }

  missing_x <- is.na(x)

  if (is.numeric(x)) {
    out <- format(
      x,
      scientific = FALSE,
      trim = TRUE,
      digits = 22
    )
  } else {
    out <- trimws(as.character(x))
  }

  out <- sub("\\.0+$", "", out)

  out[
    missing_x |
      is.na(out) |
      out %chin% c("", "NA", "NaN", ".", "*")
  ] <- "0"

  out
}

# Standardise sex coding to M, F or NA.
clean_sex <- function(x) {

  if (inherits(x, "haven_labelled")) {
    x <- haven::zap_labels(x)
  }

  x <- toupper(trimws(as.character(x)))

  fcase(
    x %chin% c("M", "MALE", "1"), "M",
    x %chin% c("F", "FEMALE", "2"), "F",
    default = NA_character_
  )
}

# ======================================================
# 1. Read phenotype data
# ======================================================

all_data <- fread(
  phenotype_path,
  na.strings = c("", "NA")
)

pheno <- all_data %>%
  select(
    ANI_ID,
    y = ch4_g_day2_1v3,
    SEX,
    weight,
    ch4_GroupNumber
  )

analysis_ids <- unique(clean_id(all_data$ANI_ID))
analysis_ids <- analysis_ids[analysis_ids != "0"]

cat(
  "Unique animals in phenotype data:",
  format(length(analysis_ids), big.mark = ","),
  "\n"
)

# ======================================================
# 2. Read and prepare the national master pedigree
# ======================================================

master_raw <- as.data.table(
  read_sas(master_pedigree_path)
)

master_rows <- master_raw[, .(
  techid = clean_id(ANI_ID),
  sires  = clean_id(ANI_ID_SIRE),
  dams   = clean_id(ANI_ID_DAM),
  sex    = clean_sex(SEX)
)]

# Remove records with no valid animal ID.
master_rows <- master_rows[techid != "0"]

# Remove exact duplicate rows.
master_rows <- unique(master_rows)

cat(
  "Rows in cleaned master pedigree:",
  format(nrow(master_rows), big.mark = ","),
  "\n"
)

# ======================================================
# 3. Check for conflicting pedigree definitions
# ======================================================

master_conflicts <- master_rows[, .(
  n_nonzero_sires = uniqueN(sires[sires != "0"]),
  n_nonzero_dams  = uniqueN(dams[dams != "0"]),
  n_known_sexes   = uniqueN(sex[!is.na(sex)])
), by = techid][
  n_nonzero_sires > 1 |
    n_nonzero_dams > 1 |
    n_known_sexes > 1
]

cat(
  "Animals with conflicting master records:",
  format(nrow(master_conflicts), big.mark = ","),
  "\n"
)

if (nrow(master_conflicts) > 0) {

  print(
    master_rows[
      techid %chin% master_conflicts$techid
    ][order(techid)][1:min(.N, 100)]
  )

  stop(
    "Conflicting pedigree definitions exist in the master pedigree."
  )
}

# Collapse compatible duplicate rows.
# For example, one record may contain a known sire and another may contain 0.
master_ped <- master_rows[, .(
  sires = {
    values <- unique(sires[sires != "0"])
    if (length(values) == 0) "0" else values[1]
  },
  dams = {
    values <- unique(dams[dams != "0"])
    if (length(values) == 0) "0" else values[1]
  },
  sex = {
    values <- unique(sex[!is.na(sex)])
    if (length(values) == 0) NA_character_ else values[1]
  }
), by = techid]

setkey(master_ped, techid)

cat(
  "Unique animals in master pedigree:",
  format(nrow(master_ped), big.mark = ","),
  "\n"
)

# ======================================================
# Extract all available ancestors until pedigree closure
# ======================================================

expand_all_ancestors <- function(
    start_ids,
    pedigree_lookup,
    max_generations = 100
) {

  pedigree_lookup <- copy(as.data.table(pedigree_lookup))

  wanted <- unique(as.character(start_ids))
  frontier <- wanted

  for (generation in seq_len(max_generations)) {

    current <- pedigree_lookup[
      techid %chin% frontier
    ]

    parents <- unique(c(
      current$sires[current$sires != "0"],
      current$dams[current$dams != "0"]
    ))

    new_ids <- setdiff(
      parents,
      wanted
    )

    cat(
      "Expansion round", generation,
      "- current animals:", format(length(wanted), big.mark = ","),
      "- new ancestors:", format(length(new_ids), big.mark = ","),
      "\n"
    )

    if (length(new_ids) == 0) {
      cat("Pedigree ancestry fully exhausted.\n")
      break
    }

    wanted <- unique(c(
      wanted,
      new_ids
    ))

    frontier <- new_ids
  }

  if (generation == max_generations &&
      length(new_ids) > 0) {
    stop(
      "Maximum expansion depth reached before pedigree closure."
    )
  }

  extracted <- pedigree_lookup[
    techid %chin% wanted
  ]

  # Add IDs that are referenced but do not have their own row
  missing_ids <- setdiff(
    wanted,
    extracted$techid
  )

  if (length(missing_ids) > 0) {

    extracted <- rbindlist(
      list(
        extracted,
        data.table(
          techid = missing_ids,
          sires = "0",
          dams = "0",
          sex = NA_character_
        )
      ),
      use.names = TRUE,
      fill = TRUE
    )
  }

  unique(
    extracted,
    by = "techid"
  )
}
# ======================================================
# 4. Extract all available ancestors
# ======================================================

ped_full <- expand_all_ancestors(
  start_ids = analysis_ids,
  pedigree_lookup = master_ped,
  max_generations = 100
)

cat(
  "Animals in ancestrally complete pedigree:",
  format(nrow(ped_full), big.mark = ","),
  "\n"
)
# ======================================================
# 5. Add boundary parents as founders
# ======================================================

# Animals at the fourth extracted generation may themselves have
# recorded parents. Add those parent IDs as boundary founders so
# every referenced parent has a row in the pedigree.

referenced_parents <- unique(c(
  ped_full$sires[ped_full$sires != "0"],
  ped_full$dams[ped_full$dams != "0"]
))

boundary_ids <- setdiff(
  referenced_parents,
  ped_full$techid
)

cat(
  "Boundary parents added as founders:",
  format(length(boundary_ids), big.mark = ","),
  "\n"
)

if (length(boundary_ids) > 0) {

  boundary_sex <- master_ped[
    match(boundary_ids, techid),
    sex
  ]

  boundary_founders <- data.table(
    techid = boundary_ids,
    sires = "0",
    dams = "0",
    sex = boundary_sex
  )

  ped_full <- rbindlist(
    list(ped_full, boundary_founders),
    use.names = TRUE,
    fill = TRUE
  )
}

ped_full <- unique(ped_full, by = "techid")

# ======================================================
# 6. Remove self-parent records
# ======================================================

n_self_sire <- ped_full[
  techid == sires & sires != "0",
  .N
]

n_self_dam <- ped_full[
  techid == dams & dams != "0",
  .N
]

cat("Animal entered as own sire:", n_self_sire, "\n")
cat("Animal entered as own dam:", n_self_dam, "\n")

ped_full[
  techid == sires,
  sires := "0"
]

ped_full[
  techid == dams,
  dams := "0"
]

# ======================================================
# 7. Attach sex of the sire and dam IDs
# ======================================================

sex_lookup <- master_ped[, .(
  parent_id = techid,
  parent_sex = sex
)]

ped_full[, sire_sex :=
           sex_lookup$parent_sex[
             match(sires, sex_lookup$parent_id)
           ]
]

ped_full[, dam_sex :=
           sex_lookup$parent_sex[
             match(dams, sex_lookup$parent_id)
           ]
]

# ======================================================
# 8. Correct parent-sex conflicts
# ======================================================

# These tests use the sex of the PARENT ID.
# They do not use the sex of the offspring.

female_as_sire <- ped_full[
  sires != "0" &
    sire_sex == "F"
]

male_as_dam <- ped_full[
  dams != "0" &
    dam_sex == "M"
]

cat(
  "Female parent IDs entered as sires:",
  format(nrow(female_as_sire), big.mark = ","),
  "\n"
)

cat(
  "Male parent IDs entered as dams:",
  format(nrow(male_as_dam), big.mark = ","),
  "\n"
)

if (nrow(female_as_sire) > 0) {
  cat("\nExamples of females entered as sires:\n")
  print(head(female_as_sire, 20))
}

if (nrow(male_as_dam) > 0) {
  cat("\nExamples of males entered as dams:\n")
  print(head(male_as_dam, 20))
}

# Remove only the invalid parent link.
ped_full[
  sires != "0" &
    sire_sex == "F",
  sires := "0"
]

ped_full[
  dams != "0" &
    dam_sex == "M",
  dams := "0"
]

# ======================================================
# 9. Resolve records where sire equals dam
# ======================================================

same_parent_before <- ped_full[
  sires != "0" &
    sires == dams
]

cat(
  "Records where sire initially equals dam:",
  format(nrow(same_parent_before), big.mark = ","),
  "\n"
)

# Known male parent: retain as sire.
ped_full[
  sires != "0" &
    sires == dams &
    sire_sex == "M",
  dams := "0"
]

# Known female parent: retain as dam.
ped_full[
  sires != "0" &
    sires == dams &
    sire_sex == "F",
  sires := "0"
]

# If sex is unknown, there is no defensible way to decide which
# parent field is correct. Code both as unknown and report them.
unresolved_same_parent <- ped_full[
  sires != "0" &
    sires == dams
]

cat(
  "Sire-equals-dam records with unknown parent sex:",
  format(nrow(unresolved_same_parent), big.mark = ","),
  "\n"
)

if (nrow(unresolved_same_parent) > 0) {

  print(head(unresolved_same_parent, 20))

  ped_full[
    sires != "0" &
      sires == dams,
    `:=`(
      sires = "0",
      dams = "0"
    )
  ]
}

# ======================================================
# 10. Check IDs used in both parental roles
# ======================================================

sire_ids <- unique(
  ped_full$sires[ped_full$sires != "0"]
)

dam_ids <- unique(
  ped_full$dams[ped_full$dams != "0"]
)

both_roles <- intersect(
  sire_ids,
  dam_ids
)

cat(
  "IDs remaining in both sire and dam columns:",
  format(length(both_roles), big.mark = ","),
  "\n"
)

if (length(both_roles) > 0) {

  role_check <- data.table(
    techid = both_roles
  )

  role_check[, sex :=
               master_ped$sex[
                 match(techid, master_ped$techid)
               ]
  ]

  print(role_check)

  stop(
    paste(
      "Some parent IDs remain in both sire and dam roles.",
      "Their sex is unknown or inconsistent and requires inspection."
    )
  )
}

# Parent-sex helper columns are no longer needed.
ped_full[, c("sire_sex", "dam_sex") := NULL]

# ======================================================
# 11. Ensure all referenced parents have pedigree rows
# ======================================================

all_parent_ids <- unique(c(
  ped_full$sires[ped_full$sires != "0"],
  ped_full$dams[ped_full$dams != "0"]
))

missing_parent_rows <- setdiff(
  all_parent_ids,
  ped_full$techid
)

cat(
  "Referenced parents absent from animal column:",
  format(length(missing_parent_rows), big.mark = ","),
  "\n"
)

if (length(missing_parent_rows) > 0) {

  missing_parent_founders <- data.table(
    techid = missing_parent_rows,
    sires = "0",
    dams = "0",
    sex = master_ped$sex[
      match(missing_parent_rows, master_ped$techid)
    ]
  )

  ped_full <- rbindlist(
    list(ped_full, missing_parent_founders),
    use.names = TRUE,
    fill = TRUE
  )
}

ped_full <- unique(ped_full, by = "techid")

# ======================================================
# 12. Parent completeness summaries
# ======================================================

cat("\nFULL PEDIGREE PARENT COMPLETENESS\n")

full_parent_summary <- ped_full[, .(
  n_animals = .N,
  both_parents = sum(sires != "0" & dams != "0"),
  sire_only = sum(sires != "0" & dams == "0"),
  dam_only = sum(sires == "0" & dams != "0"),
  neither_parent = sum(sires == "0" & dams == "0"),
  pct_both = 100 * mean(sires != "0" & dams != "0"),
  pct_any_parent = 100 * mean(sires != "0" | dams != "0")
)]

print(full_parent_summary)

cat("\nPHENOTYPED ANIMAL PARENT COMPLETENESS\n")

phenotyped_parent_summary <- ped_full[
  techid %chin% analysis_ids,
  .(
    n_animals = .N,
    both_parents = sum(sires != "0" & dams != "0"),
    sire_only = sum(sires != "0" & dams == "0"),
    dam_only = sum(sires == "0" & dams != "0"),
    neither_parent = sum(sires == "0" & dams == "0"),
    pct_both = 100 * mean(sires != "0" & dams != "0"),
    pct_any_parent = 100 * mean(sires != "0" | dams != "0")
  )
]

print(phenotyped_parent_summary)

# ======================================================
# 13. Final structural checks before sorting
# ======================================================

ped_order <- unique(
  ped_full[, .(techid, sires, dams)],
  by = "techid"
)

duplicate_animals <- ped_order[
  duplicated(techid) |
    duplicated(techid, fromLast = TRUE)
]

self_sire <- ped_order[
  techid == sires &
    sires != "0"
]

self_dam <- ped_order[
  techid == dams &
    dams != "0"
]

same_parent <- ped_order[
  sires == dams &
    sires != "0"
]

parent_ids <- unique(c(
  ped_order$sires[ped_order$sires != "0"],
  ped_order$dams[ped_order$dams != "0"]
))

missing_parents <- setdiff(
  parent_ids,
  ped_order$techid
)

cat("\nFINAL STRUCTURAL CHECKS\n")
cat("Duplicate animal IDs:", nrow(duplicate_animals), "\n")
cat("Animal equals sire:", nrow(self_sire), "\n")
cat("Animal equals dam:", nrow(self_dam), "\n")
cat("Sire equals dam:", nrow(same_parent), "\n")
cat("Missing parent rows:", length(missing_parents), "\n")

if (
  nrow(duplicate_animals) > 0 ||
  nrow(self_sire) > 0 ||
  nrow(self_dam) > 0 ||
  nrow(same_parent) > 0 ||
  length(missing_parents) > 0
) {
  stop(
    "Pedigree failed structural validation before sorting."
  )
}

# ======================================================
# 14. Sort parents before offspring
# ======================================================

left <- copy(ped_order)
ped_final <- left[0]

available_ids <- "0"
sorting_round <- 0L

repeat {

  sorting_round <- sorting_round + 1L

  ready <- left[
    sires %chin% available_ids &
      dams %chin% available_ids
  ]

  if (nrow(ready) == 0) {
    break
  }

  ped_final <- rbindlist(
    list(ped_final, ready),
    use.names = TRUE
  )

  available_ids <- unique(c(
    available_ids,
    ready$techid
  ))

  left <- left[
    !techid %chin% ready$techid
  ]

  cat(
    "Sorting round", sorting_round,
    "- added:", format(nrow(ready), big.mark = ","),
    "- remaining:", format(nrow(left), big.mark = ","),
    "\n"
  )
}

cat("\nSORTING SUMMARY\n")
cat(
  "Animals before sorting:",
  format(nrow(ped_order), big.mark = ","),
  "\n"
)
cat(
  "Animals successfully sorted:",
  format(nrow(ped_final), big.mark = ","),
  "\n"
)
cat(
  "Animals unresolved:",
  format(nrow(left), big.mark = ","),
  "\n"
)

if (nrow(left) > 0) {

  cat(
    "\nFirst unresolved pedigree records:\n"
  )

  print(head(left, 50))

  stop(
    paste(
      "Pedigree could not be completely sorted.",
      "This indicates a cycle or unresolved parent link."
    )
  )
}

# ======================================================
# 15. Confirm parents occur before offspring
# ======================================================

row_position <- setNames(
  seq_len(nrow(ped_final)),
  ped_final$techid
)

offspring_row <- seq_len(nrow(ped_final))

sire_row <- unname(
  row_position[ped_final$sires]
)

dam_row <- unname(
  row_position[ped_final$dams]
)

sire_after_offspring <- which(
  ped_final$sires != "0" &
    sire_row > offspring_row
)

dam_after_offspring <- which(
  ped_final$dams != "0" &
    dam_row > offspring_row
)

cat(
  "Sire-after-offspring links:",
  length(sire_after_offspring),
  "\n"
)

cat(
  "Dam-after-offspring links:",
  length(dam_after_offspring),
  "\n"
)

if (
  length(sire_after_offspring) > 0 ||
  length(dam_after_offspring) > 0
) {
  stop(
    "The pedigree is not correctly ordered."
  )
}

# ======================================================
# 16. Check that all phenotype animals are retained
# ======================================================

missing_analysis_animals <- setdiff(
  analysis_ids,
  ped_final$techid
)

cat(
  "Phenotype animals absent from final pedigree:",
  length(missing_analysis_animals),
  "\n"
)

if (length(missing_analysis_animals) > 0) {
  print(head(missing_analysis_animals, 50))
  stop(
    "Some phenotype animals are absent from the final pedigree."
  )
}

# ======================================================
# 17. Export for ASReml
# ======================================================

# Keep IDs as character strings.
# Do not convert them to integer.

fwrite(
  ped_final,
  file = output_path,
  sep = ",",
  quote = FALSE,
  col.names = FALSE,
  na = "0"
)

cat(
  "\nCorrected pedigree written to:\n",
  output_path,
  "\n"
)

cat(
  "Final pedigree rows:",
  format(nrow(ped_final), big.mark = ","),
  "\n"
)

# ======================================================
# 18. Remove stale ASReml-sorted pedigree
# ======================================================

srt_path <- paste0(
  output_path,
  ".SRT"
)

if (file.exists(srt_path)) {

  removed <- file.remove(srt_path)

  cat(
    "Removed old ASReml .SRT file:",
    removed,
    "\n"
  )
} else {
  cat(
    "No old ASReml .SRT file was present.\n"
  )
}

cat(
  "\nPedigree construction and validation complete.\n"
)

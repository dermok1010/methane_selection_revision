# Reviewer 1 follow-up: is ch4_GroupNumber (PAC contemporary group) itself
# confounded with physiological stage, i.e. are individual contemporary
# groups populated with a mix of young and mature animals? This is
# distinct from A3's existing stage-heterogeneity work (which asks whether
# the *residual variance* differs by stage) -- this asks whether *group
# membership* and *stage* are themselves separable, using the same
# within/total variance-ratio method already used for the breed-proportion
# confounding check above.
#
# Run via: ~/bin/micromamba run -p ~/envs/methane_selection_revision \
#   Rscript analysis/diagnostics/reviewer_a2_a3/04_cg_stage_confounding.R

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

data <- read_csv(
  "analysis/revision/asreml_pipeline/data/phenotype_asreml.csv",
  show_col_types = FALSE
)

sink("analysis/diagnostics/reviewer_a2_a3/cg_stage_confounding_summary.txt")

cat("n records:", nrow(data), "\n")
cat("n contemporary groups (ch4_GroupNumber):", n_distinct(data$ch4_GroupNumber), "\n\n")

# --- 1. Using the manuscript's own growing/mature 660-day split (stage_660) ---
cg_stage <- data %>%
  filter(!is.na(stage_660)) %>%
  group_by(ch4_GroupNumber) %>%
  summarise(
    n_records = n(),
    n_stages = n_distinct(stage_660),
    n_young = sum(stage_660 == "young"),
    n_mature = sum(stage_660 == "mature"),
    .groups = "drop"
  )

cat("=== stage_660 (growing <660d / mature) mixing within contemporary group ===\n")
cat("CGs entirely 'young':  ", sum(cg_stage$n_stages == 1 & cg_stage$n_young > 0), "\n")
cat("CGs entirely 'mature': ", sum(cg_stage$n_stages == 1 & cg_stage$n_mature > 0), "\n")
cat("CGs MIXED (both stages):", sum(cg_stage$n_stages == 2), "\n")
cat("Total CGs with stage_660 known:", nrow(cg_stage), "\n")
pct_mixed_cg <- mean(cg_stage$n_stages == 2) * 100
cat(sprintf("%% of CGs that are mixed: %.1f%%\n", pct_mixed_cg))

records_in_mixed <- sum(cg_stage$n_records[cg_stage$n_stages == 2])
total_records <- sum(cg_stage$n_records)
cat(sprintf("%% of records that sit in a mixed CG: %.1f%% (%d / %d)\n\n",
            100 * records_in_mixed / total_records, records_in_mixed, total_records))

mixed <- cg_stage %>% filter(n_stages == 2) %>%
  mutate(minority_frac = pmin(n_young, n_mature) / n_records)
cat("Among MIXED CGs, distribution of the minority-stage fraction (how 'balanced' the mixing is):\n")
print(summary(mixed$minority_frac))
cat("\n")

# --- 2. age_in_years within-CG vs total variance ratio, same method as the
#         existing breed-proportion confounding check (README.md A2 section) ---
age_data <- data %>% filter(!is.na(age_in_years))
grand_var <- var(age_data$age_in_years)
within_var <- age_data %>%
  group_by(ch4_GroupNumber) %>%
  summarise(v = var(age_in_years), n = n(), .groups = "drop") %>%
  filter(!is.na(v)) %>%
  summarise(wv = sum(v * (n - 1)) / sum(n - 1)) %>%
  pull(wv)

cat("=== age_in_years within-CG vs total variance ratio ===\n")
cat("(1.0 = age not related to CG at all; near 0 = age almost fully determined by which CG an animal is in)\n")
cat(sprintf("within/total variance ratio: %.3f\n\n", within_var / grand_var))

# --- 3. Per-CG age range ---
cg_age_range <- age_data %>%
  group_by(ch4_GroupNumber) %>%
  summarise(n = n(), min_age = min(age_in_years), max_age = max(age_in_years),
            range_age = max_age - min_age, .groups = "drop")

cat("=== Per-CG age range (age_in_years), all CGs ===\n")
print(summary(cg_age_range$range_age))
cat(sprintf("\nCGs spanning >1 year of age within the same group: %d / %d (%.1f%%)\n",
            sum(cg_age_range$range_age > 1), nrow(cg_age_range),
            100 * mean(cg_age_range$range_age > 1)))
cat(sprintf("CGs spanning >5 years of age within the same group: %d / %d (%.1f%%)\n",
            sum(cg_age_range$range_age > 5), nrow(cg_age_range),
            100 * mean(cg_age_range$range_age > 5)))

cat("\nWorst 10 CGs by age range (id, n, min, max, range):\n")
print(cg_age_range %>% arrange(desc(range_age)) %>% slice_head(n = 10))

sink()
cat("Done -- written to analysis/diagnostics/reviewer_a2_a3/cg_stage_confounding_summary.txt\n")

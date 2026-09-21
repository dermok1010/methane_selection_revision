#!/usr/bin/env Rscript
# Parse the per-cg_mean_cl-class residual variances out of the 5
# CONVERGED --set=cg_het univariate .pvc files (methane, ch4mbw,
# ch4ratio, ch4rmtmbw, ch4rmtmbwco2) and derive a per-class h2, closing
# the "never actually extracted" item in docs/revision_plan.md Section 4B
# point 2. Genetic (ped) and permanent-environment (ide) variances are
# shared scalars across classes (only the residual is heterogeneous by
# cg_mean_cl, matching the --set=cg_het model spec in
# 01_generate_models.R) -- so per-class h2 = VA / (VA + PE + resid_class),
# read directly off each model's own .pvc rather than assumed from
# position (same discipline as 03_parse_results.R's Model_Term
# recomputation, just for a residual structure that script doesn't yet
# handle).
#
# Input: run/<jobname>_cg_het/<jobname>_cg_het.pvc, rsynced back from HPC
# (analysis/revision/asreml_pipeline/run/ is gitignored -- see
# docs/revision_plan.md 21 Sep entry for provenance of this particular
# pull).
# Output: results/cg_het_class_summary.csv (one row per trait x class)
#         results/cg_het_summary.csv (one row per trait: homogeneous vs
#         heterogeneous aggregate + per-class h2 range)
#
# Usage: Rscript 05_parse_cg_het_classes.R

suppressPackageStartupMessages(library(dplyr))

script_dir <- dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)))
pipeline_root <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
if (!dir.exists(file.path(pipeline_root, "config"))) pipeline_root <- getwd()

traits <- c("methane", "ch4mbw", "ch4ratio", "ch4rmtmbw", "ch4rmtmbwco2")

parse_cg_het_pvc <- function(pvc_path) {
  lines <- readLines(pvc_path)

  va_line <- grep("^\\s*1\\s+ped\\(ANI_ID\\)", lines, value = TRUE)
  pe_line <- grep("^\\s*2\\s+ide\\(ANI_ID\\)", lines, value = TRUE)
  stopifnot(length(va_line) == 1, length(pe_line) == 1)
  num_tok <- function(ln) as.numeric(sub("E", "e", strsplit(trimws(ln), "\\s+")[[1]]))
  va <- num_tok(va_line)[length(num_tok(va_line)) - 1]
  pe <- num_tok(pe_line)[length(num_tok(pe_line)) - 1]

  header_idx <- grep("^ sat\\(cg_mean_cl,(\\d+)\\)\\.idv\\(units\\)\\s+\\d+ effects", lines)
  class_rows <- lapply(header_idx, function(i) {
    hdr <- lines[i]
    cls <- as.integer(sub(".*cg_mean_cl,(\\d+)\\).*", "\\1", hdr))
    n_eff <- as.integer(sub(".*\\)\\s+(\\d+) effects.*", "\\1", hdr))
    val_line <- lines[i + 1]
    toks <- strsplit(trimws(val_line), "\\s+")[[1]]
    resid <- as.numeric(toks[length(toks) - 1])
    resid_se <- as.numeric(toks[length(toks)])
    data.frame(cg_mean_cl = cls, n_records = n_eff,
               residual = resid, residual_se = resid_se)
  })
  classes <- bind_rows(class_rows) %>% arrange(cg_mean_cl)

  list(va = va, pe = pe, classes = classes)
}

all_class_rows <- list()
summary_rows <- list()

for (t in traits) {
  pvc_path <- file.path(pipeline_root, "run", paste0("a_uni_", t, "_cg_het"),
                         paste0("a_uni_", t, "_cg_het.pvc"))
  if (!file.exists(pvc_path)) {
    cat("SKIP (not found):", pvc_path, "\n")
    next
  }
  parsed <- parse_cg_het_pvc(pvc_path)
  cls <- parsed$classes %>%
    mutate(trait = t, va = parsed$va, pe = parsed$pe,
           phen = parsed$va + parsed$pe + residual,
           h2 = parsed$va / phen,
           t_repeat = (parsed$va + parsed$pe) / phen) %>%
    select(trait, cg_mean_cl, n_records, residual, residual_se, h2, t_repeat)
  all_class_rows[[t]] <- cls

  # Records-weighted mean h2/t across classes, as the single comparable
  # "aggregate under heterogeneity" figure against the homogeneous h2/t --
  # NOT itself an ASReml VPREDICT quantity (no formal SE), matching the
  # 2026-09-20 decision rule that this comparison stays qualitative.
  weighted_h2 <- with(cls, sum(h2 * n_records) / sum(n_records))
  weighted_t <- with(cls, sum(t_repeat * n_records) / sum(n_records))

  summary_rows[[t]] <- data.frame(
    trait = t,
    n_classes = nrow(cls),
    va = parsed$va, pe = parsed$pe,
    residual_min = min(cls$residual), residual_max = max(cls$residual),
    residual_ratio_max_min = max(cls$residual) / min(cls$residual),
    h2_class_min = min(cls$h2), h2_class_max = max(cls$h2),
    h2_class_weighted_mean = weighted_h2,
    t_class_weighted_mean = weighted_t
  )
}

class_df <- bind_rows(all_class_rows)
summary_df <- bind_rows(summary_rows)

results_dir <- file.path(pipeline_root, "results")
write.csv(class_df, file.path(results_dir, "cg_het_class_summary.csv"), row.names = FALSE)
write.csv(summary_df, file.path(results_dir, "cg_het_summary.csv"), row.names = FALSE)

cat("\n=== Per-trait cg_het heterogeneity summary ===\n")
print(summary_df, row.names = FALSE)
cat("\nWritten: results/cg_het_class_summary.csv (", nrow(class_df), "rows )\n")
cat("Written: results/cg_het_summary.csv (", nrow(summary_df), "rows )\n")

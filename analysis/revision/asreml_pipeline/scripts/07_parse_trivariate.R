#!/usr/bin/env Rscript
# Parse the CH4 x MBW x CO2 trivariate ASReml .pvc into a small tracked CSV
# (the raw .pvc/.asr are gitignored). Numbering (confirmed against the .pvc names):
# 1-6 residual, 7-12 genetic, 13-15 independent PE, then the VPREDICT block.
# Usage: Rscript 07_parse_trivariate.R <path/to/tri_methane_mbw_co2.pvc>
args <- commandArgs(trailingOnly = TRUE)
pvc <- if (length(args) >= 1) args[1] else stop("give the .pvc path")
out <- file.path("analysis/revision/asreml_pipeline/results", "trivariate_summary.csv")
num <- "[-+]?[0-9.]+(?:[Ee][-+]?[0-9]+)?"
L <- readLines(pvc); rows <- list()
for (l in L) {
  m <- regmatches(l, regexec(paste0("^\\s*([0-9]+)\\s+(\\S.*?)\\s+([VC])\\s+([0-9]+)(?:\\s+([0-9]+))?\\s+(", num, ")\\s+(", num, ")\\s*$"), l, perl = TRUE))[[1]]
  if (length(m) == 8 && as.integer(m[2]) <= 15)
    rows[[length(rows) + 1]] <- data.frame(id = as.integer(m[2]), block = sub(";.*", "", m[3]), type = m[4],
      i = as.integer(m[5]), j = ifelse(m[6] == "", as.integer(m[5]), as.integer(m[6])), est = as.numeric(m[7]), se = as.numeric(m[8]))
  m2 <- regmatches(l, regexec(paste0("^\\s*(h2_[123]|rg[0-9]+|re[0-9]+|rp[0-9]+)\\s+=.*=\\s+(", num, ")\\s+(", num, ")\\s*$"), l, perl = TRUE))[[1]]
  if (length(m2) == 4)
    rows[[length(rows) + 1]] <- data.frame(id = NA_integer_, block = "derived", type = m2[2], i = NA_integer_, j = NA_integer_, est = as.numeric(m2[3]), se = as.numeric(m2[4]))
}
d <- do.call(rbind, rows)
d$component <- with(d, ifelse(id <= 6, "residual", ifelse(id <= 12, "genetic", ifelse(id <= 15, "permanent_env", "derived"))))
d$component[is.na(d$id)] <- "derived"
stopifnot(sum(!is.na(d$id)) == 15, sum(is.na(d$id)) == 12)
write.csv(d, out, row.names = FALSE); print(d, digits = 5)

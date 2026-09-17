#!/usr/bin/env Rscript
# Reviewer action plan A2: "Tabulate the significance of the main fixed
# effects/covariates". Parses each univariate model's Wald F-inc table
# straight from its .asr (ASReml's own output -- not re-derived), and
# adds an approximate p-value via F(NumDF, residual_df), since ASReml's
# own table reports F-inc but not p directly. residual_df is read from
# the same .asr's "LogL= ... N df" line.
#
# ch4_GroupNumber (the 1435-level PAC contemporary group) is fitted but
# excluded from every Wald table by ASReml itself (too many levels --
# "Use !DENSE <n> to force ... into Wald F table"), so it cannot be
# reported here without a separate, much more expensive !DENSE rerun;
# noted as a limitation, not silently omitted.

asr_dir <- "~/hpc_incoming/methane_selection_revision_wald_2026-09-17/run"
asr_dir <- path.expand(asr_dir)
jobs <- c(methane = "a_uni_methane", co2 = "a_uni_co2", mbw = "a_uni_mbw",
          adg = "a_uni_adg", muscle = "a_uni_muscle", rumen = "a_uni_rumen",
          weight = "a_uni_weight")

parse_one <- function(trait, job) {
  path <- file.path(asr_dir, job, paste0(job, ".asr"))
  lines <- readLines(path, warn = FALSE)
  df_line <- grep("^\\s*1 LogL=.*df", lines, value = TRUE)[1]
  resid_df <- as.numeric(sub(".*?([0-9]+)\\s*df.*", "\\1", df_line))

  start <- grep("Wald F statistics", lines)
  end <- grep("effects fitted", lines)[1]  # first "N effects fitted" line ends the F table
  block <- lines[(start + 2):(end - 1)]
  block <- block[trimws(block) != ""]
  # format: "   8 SEX                               1               3.68"
  m <- regmatches(block, regexec("^\\s*\\d+\\s+(\\S+)\\s+(\\d+)\\s+([0-9.]+)\\s*$", block))
  m <- m[sapply(m, length) == 4]
  data.frame(
    trait = trait,
    term = sapply(m, `[`, 2),
    NumDF = as.numeric(sapply(m, `[`, 3)),
    F_inc = as.numeric(sapply(m, `[`, 4)),
    resid_df = resid_df,
    stringsAsFactors = FALSE
  )
}

all_rows <- do.call(rbind, Map(parse_one, names(jobs), jobs))
all_rows$p_value <- pf(all_rows$F_inc, all_rows$NumDF, all_rows$resid_df, lower.tail = FALSE)
all_rows$sig <- cut(all_rows$p_value, c(-Inf, 0.001, 0.01, 0.05, Inf), labels = c("***", "**", "*", ""))

write.csv(all_rows, "wald_fixed_effects.csv", row.names = FALSE)

cat("=== Wald F-test significance, all 7 component-trait univariate models ===\n")
cat("(ch4_GroupNumber excluded -- ASReml drops it from the Wald table by\n")
cat(" default given 1435 levels; a separate !DENSE rerun would be needed\n")
cat(" to test it formally.)\n\n")
wide <- reshape(all_rows[, c("trait", "term", "sig")], idvar = "term", timevar = "trait", direction = "wide")
names(wide) <- sub("^sig\\.", "", names(wide))
print(wide, row.names = FALSE)
cat("\nFull F-inc/p-values written to wald_fixed_effects.csv\n")

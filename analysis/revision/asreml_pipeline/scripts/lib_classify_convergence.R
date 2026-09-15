#!/usr/bin/env Rscript
# Classify an ASReml .asr file's convergence status from its own text,
# using exactly the message strings documented in
# ASReml-4.2-Functional-Specification.pdf Section 15.5 (Tables 15.1-15.3)
# -- not inferred/guessed wording.
#
# Usage: Rscript lib_classify_convergence.R path/to/job.asr
# Prints exactly one status keyword to stdout (nothing else) so callers
# (bash retry loop, R result parser) can branch on it directly:
#
#   CONVERGED               "LogL Converged" and no accompanying
#                            "Parameters Not Converged" warning.
#   CONVERGED_PARAMS_UNSTABLE  "Logl converged, parameters not converged"
#                            -- REML likelihood stable but variance
#                            parameters are, per the manual, "in fact,
#                            still changing". Treated as NOT safe to
#                            accept without a continuation attempt.
#   NOT_CONVERGED            "Logl not converged" -- max iterations hit.
#   CONVERGENCE_FAILED       "Convergence failed" -- oscillating REML;
#                            per the manual this needs a model change
#                            (simpler model / better starting values /
#                            fixed parameters), not just more iterations.
#                            Flagged separately so the retry loop does
#                            not burn attempts on a problem !CONTINUE
#                            cannot fix.
#   MISSING                  file does not exist (job has not run, or
#                            crashed before writing any .asr).
#   UNKNOWN                  .asr exists but none of the above patterns
#                            matched -- inspect the file by hand; this
#                            should not happen for a normally-completed
#                            or normally-failed run.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Usage: Rscript lib_classify_convergence.R path/to/job.asr")
asr_path <- args[1]

if (!file.exists(asr_path)) {
  cat("MISSING\n")
  quit(status = 0)
}

txt <- readLines(asr_path, warn = FALSE)
full <- paste(txt, collapse = "\n")

status <- if (grepl("Convergence failed", full, fixed = TRUE)) {
  "CONVERGENCE_FAILED"
} else if (grepl("Logl converged, parameters\\s*\\n?\\s*not converged", full, ignore.case = TRUE) ||
           grepl("Parameters Not Converged", full, fixed = TRUE)) {
  "CONVERGED_PARAMS_UNSTABLE"
} else if (grepl("LogL not converged|Logl not converged", full)) {
  "NOT_CONVERGED"
} else if (grepl("LogL Converged|Logl Converged", full)) {
  "CONVERGED"
} else {
  "UNKNOWN"
}

cat(status, "\n")

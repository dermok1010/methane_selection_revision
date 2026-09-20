#!/usr/bin/env Rscript
# Parse run/<jobname>/<jobname>.asr (+ .pvc where present) into tidy
# summary tables -- each job has its own working directory (see
# scripts/02_stage_run_dir.R's header for why: concurrent ASReml jobs
# sharing one directory race on files like ainverse.bin):
#   results/univariate_summary.csv
#   results/bivariate_summary.csv
#
# Design principle (see 01_generate_models.R's header comment on
# VPREDICT index provenance): never trust the VPREDICT/.pvc numbers
# alone. For every model, this script ALSO independently recomputes
# h2/t (univariate) or h2_1/h2_2/rg/re/rp (bivariate) directly from the
# Model_Term table's named rows (ped(ANI_ID)/ide(ANI_ID)/Residual,
# matched by NAME not position), and flags any row where the two
# disagree beyond a small numeric tolerance. A flagged row means the
# VPREDICT index assumption documented in 01_generate_models.R has
# broken down for that specific model and needs manual review before
# the number is used anywhere.
#
# Usage: Rscript 03_parse_results.R

suppressPackageStartupMessages(library(yaml))

script_dir <- dirname(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)))
pipeline_root <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
if (!dir.exists(file.path(pipeline_root, "config"))) pipeline_root <- getwd()

run_dir <- file.path(pipeline_root, "run")
results_dir <- file.path(pipeline_root, "results")
dir.create(results_dir, showWarnings = FALSE, recursive = TRUE)

classify_convergence <- function(asr_path) {
  if (!file.exists(asr_path)) return("MISSING")
  full <- paste(readLines(asr_path, warn = FALSE), collapse = "\n")
  if (grepl("Convergence failed", full, fixed = TRUE)) return("CONVERGENCE_FAILED")
  if (grepl("Parameters Not Converged", full, fixed = TRUE)) return("CONVERGED_PARAMS_UNSTABLE")
  if (grepl("LogL not converged|Logl not converged", full)) return("NOT_CONVERGED")
  if (grepl("LogL Converged|Logl Converged", full)) return("CONVERGED")
  "UNKNOWN"
}

# ---- Model_Term table parser ----
# Handles both univariate rows (Gamma Sigma Sigma/SE %C) and bivariate
# US rows (i j Sigma Sigma Sigma/SE %C), matched by column count, and
# returns a data.frame with one row per named term/component.
parse_model_terms <- function(asr_path) {
  lines <- readLines(asr_path, warn = FALSE)
  hdr <- grep("^\\s*Model_Term\\b", lines)
  if (length(hdr) == 0) return(NULL)
  hdr <- hdr[1]
  # Term rows continue until a blank line or a line that clearly starts a
  # new section (Covariance/Variance..., Wald F, Akaike, etc.)
  end <- hdr
  for (i in (hdr + 1):length(lines)) {
    ln <- lines[i]
    if (grepl("^\\s*$", ln) || grepl("^\\s*Covariance/Variance|^\\s*Wald F|^\\s*Akaike|^\\s*SLOPES|^\\s*Finished", ln)) {
      end <- i - 1
      break
    }
    end <- i
  }
  rows <- lines[(hdr + 1):end]
  rows <- rows[grepl("[0-9]", rows)]  # drop stray blank/continuation lines

  # Block tracking (added 2026-09-17): classic-syntax G-structure rows
  # repeat the full term identity on every data row (e.g.
  # "Trait.ANI_ID  US_V  1  1  ..."), but the functional us(Trait)
  # syntax (used for 4 component-set pairs with no legacy starting
  # values -- see 01_generate_models.R's uni_ped_sigma comment) prints
  # the identity ONCE on a preceding "N effects" header row
  # ("us(Trait).ped(ANI_ID)   72898 effects") and then bare "Trait ..."
  # data rows with no ANI_ID in them at all. Without this, get_sigma's
  # name-based match for the ped(ANI_ID) block silently returns NA for
  # those 4 pairs (confirmed: results/bivariate_summary.csv showed
  # sigma_ped_*/check_agree_* all NA for exactly methane_co2,
  # methane_adg, methane_rumen, mbw_co2 -- the h2/rg VPREDICT numbers
  # were hand-verified correct against the raw .asr regardless, this
  # only fixes the automated independent cross-check). A block header
  # is any row with exactly one numeric token whose line ends in
  # "effects"; its name_part is carried forward to every subsequent row
  # until the next block header.
  current_block <- NA_character_
  out <- lapply(rows, function(ln) {
    toks <- strsplit(trimws(ln), "\\s+")[[1]]
    # numeric-looking tokens from the right: Sigma/SE, %C are always
    # present; Gamma or two matrix indices precede Sigma depending on
    # structure. Identify the run of numeric tokens at the end.
    is_num <- suppressWarnings(!is.na(as.numeric(gsub("E", "e", toks))))
    if (!any(is_num)) return(NULL)
    first_num <- which(is_num)[1]
    name_part <- paste(toks[seq_len(first_num - 1)], collapse = " ")
    num_toks <- toks[is_num]
    is_block_header <- length(num_toks) == 1 && grepl("effects\\s*$", ln)
    if (is_block_header) current_block <<- name_part
    list(raw = ln, name_part = name_part, block = current_block, num_toks = list(num_toks))
  })
  out <- out[!sapply(out, is.null)]
  if (length(out) == 0) return(NULL)

  data.frame(
    raw = sapply(out, `[[`, "raw"),
    name_part = sapply(out, `[[`, "name_part"),
    block = sapply(out, function(x) if (is.null(x$block) || is.na(x$block)) "" else x$block),
    stringsAsFactors = FALSE
  ) -> df
  df$num_toks <- lapply(out, function(x) x$num_toks[[1]])
  df
}

get_sigma <- function(term_df, name_pattern, struct_pattern = NULL, ij = NULL, diag_idx = NULL) {
  # name_pattern matched against name_part (e.g. "ped(ANI_ID)", "ide(ANI_ID)",
  # "Residual", "Trait.ANI_ID") OR against the row's block header (see
  # parse_model_terms' block-tracking comment -- needed for functional
  # us(Trait).ped(ANI_ID) syntax, where individual data rows no longer
  # carry "ANI_ID" themselves); struct_pattern optionally matched against
  # the raw line (e.g. "US_V", "US_C", "IDV_V", "NRM_V", "SCA_V"); ij
  # optionally matches the two leading matrix-index tokens for US rows
  # (e.g. c("1","1"), c("2","1"), c("2","2")).
  #
  # diag_idx (added 2026-09-20, first exercised for real on the
  # key_bivariates HPC run): diag(Trait).ide(ANI_ID) -- the independent-PE
  # structure introduced 2026-09-18 -- prints as TWO separate rows sharing
  # one block header ("Trait DIAG_V 1 ...", "Trait DIAG_V 2 ..."), unlike
  # the classic single shared ide(ANI_ID) row this function was originally
  # written for. Without diag_idx, a name/block match against "ide(ANI_ID)"
  # found BOTH diag rows as candidates and silently returned only the
  # first (trait 1's PE variance) for any caller -- including calls meant
  # for trait 2 -- confirmed against a real converged bi_methane_ch4mbw.asr
  # (Trait DIAG_V 1 = 0.574393, Trait DIAG_V 2 = 0.00157833; the old code
  # would have returned 0.574393 for both). When more than one candidate
  # row matches, diag_idx filters to the row whose leading index token
  # equals it; when only one candidate matches (the classic shared-PE
  # case), diag_idx is a no-op and that row's value is returned regardless
  # -- correct, since a shared PE term applies to both traits identically.
  name_match <- grepl(name_pattern, term_df$name_part, fixed = TRUE) |
    grepl(name_pattern, term_df$block, fixed = TRUE)
  cand <- term_df[name_match, , drop = FALSE]
  if (!is.null(struct_pattern)) cand <- cand[grepl(struct_pattern, cand$raw), , drop = FALSE]
  if (nrow(cand) == 0) return(NA_real_)
  if (!is.null(diag_idx) && nrow(cand) > 1) {
    keep <- vapply(cand$num_toks, function(nt) length(nt) >= 1 && nt[1] == diag_idx, logical(1))
    cand <- cand[keep, , drop = FALSE]
    if (nrow(cand) == 0) return(NA_real_)
  }
  for (i in seq_len(nrow(cand))) {
    nt <- cand$num_toks[[i]]
    nt_num <- suppressWarnings(as.numeric(gsub("E", "e", nt)))
    if (!is.null(ij)) {
      # US rows: [idx_i, idx_j, sigma, sigma_se_or_dup, sigmaSE, pctC, ...]
      if (length(nt) < 4) next
      if (!identical(nt[1:2], ij)) next
      return(nt_num[3])
    } else {
      # Univariate rows: [Gamma, Sigma, SigmaSE, pctC, ...] OR IDV rows
      # in bivariate: [Sigma, SigmaSE_dup, SigmaSE, pctC, ...]
      if (length(nt) < 2) next
      return(nt_num[length(nt_num) - 2])  # Sigma is 3rd-from-last numeric token in both layouts
    }
  }
  NA_real_
}

parse_pvc <- function(pvc_path) {
  if (!file.exists(pvc_path)) return(list())
  lines <- readLines(pvc_path, warn = FALSE)
  out <- list()
  for (ln in lines) {
    m <- regmatches(ln, regexec("^\\s*(\\w+)\\s*=.*?=\\s*([-0-9.Ee+]+)\\s+([-0-9.Ee+]+)\\s*$", ln))[[1]]
    if (length(m) == 4) {
      out[[m[2]]] <- list(estimate = as.numeric(m[3]), se = as.numeric(m[4]))
    }
  }
  out
}

n_close <- function(a, b, tol = 1e-3) {
  if (is.na(a) || is.na(b)) return(NA)
  denom <- max(abs(a), abs(b), 1e-12)
  abs(a - b) / denom < tol
}

# ---- univariate ----

job_dirs <- list.dirs(run_dir, full.names = FALSE, recursive = FALSE)
uni_jobs <- job_dirs[grepl("^a_uni_", job_dirs)]
bi_jobs <- job_dirs[grepl("^bi_", job_dirs)]

uni_rows <- list()
for (jobname in uni_jobs) {
  code <- sub("^a_uni_", "", jobname)
  job_dir <- file.path(run_dir, jobname)
  asr_path <- file.path(job_dir, paste0(jobname, ".asr"))
  conv <- classify_convergence(asr_path)
  row <- list(trait_code = code, convergence = conv,
              sigma_ped = NA_real_, sigma_ide = NA_real_, sigma_residual = NA_real_,
              h2 = NA_real_, h2_se = NA_real_, t_repeat = NA_real_, t_se = NA_real_,
              h2_check = NA_real_, t_check = NA_real_, check_agree_h2 = NA, check_agree_t = NA)

  if (file.exists(asr_path)) {
    terms <- parse_model_terms(asr_path)
    if (!is.null(terms)) {
      row$sigma_ped <- get_sigma(terms, "ped(ANI_ID)")
      row$sigma_ide <- get_sigma(terms, "ide(ANI_ID)")
      row$sigma_residual <- get_sigma(terms, "Residual")
      phen <- sum(row$sigma_ped, row$sigma_ide, row$sigma_residual, na.rm = FALSE)
      row$h2_check <- row$sigma_ped / phen
      row$t_check <- (row$sigma_ped + row$sigma_ide) / phen
    }
  }
  pvc <- parse_pvc(file.path(job_dir, paste0(jobname, ".pvc")))
  if (!is.null(pvc$direct)) { row$h2 <- pvc$direct$estimate; row$h2_se <- pvc$direct$se }
  if (!is.null(pvc[["repeat"]])) { row$t_repeat <- pvc[["repeat"]]$estimate; row$t_se <- pvc[["repeat"]]$se }
  row$check_agree_h2 <- n_close(row$h2, row$h2_check)
  row$check_agree_t <- n_close(row$t_repeat, row$t_check)

  uni_rows[[length(uni_rows) + 1]] <- row
}

if (length(uni_rows) > 0) {
  uni_df <- do.call(rbind, lapply(uni_rows, as.data.frame, stringsAsFactors = FALSE))
  write.csv(uni_df, file.path(results_dir, "univariate_summary.csv"), row.names = FALSE)
  cat("Wrote", nrow(uni_df), "rows to results/univariate_summary.csv\n")
  if (any(!is.na(uni_df$check_agree_h2) & !uni_df$check_agree_h2)) {
    cat("*** WARNING: h2 mismatch between VPREDICT and independent Model_Term recomputation for:",
        paste(uni_df$trait_code[!is.na(uni_df$check_agree_h2) & !uni_df$check_agree_h2], collapse = ", "), "\n")
  }
} else {
  cat("No a_uni_* job directories found in", run_dir, "\n")
}

# ---- bivariate ----

bi_rows <- list()
for (jobname in bi_jobs) {
  code_pair <- sub("^bi_", "", jobname)
  job_dir <- file.path(run_dir, jobname)
  asr_path <- file.path(job_dir, paste0(jobname, ".asr"))
  conv <- classify_convergence(asr_path)
  row <- list(pair = code_pair, convergence = conv,
              sigma_ide = NA_real_, sigma_pe_1 = NA_real_, sigma_pe_2 = NA_real_,
              sigma_res_1 = NA_real_, sigma_res_c = NA_real_, sigma_res_2 = NA_real_,
              sigma_ped_1 = NA_real_, sigma_ped_c = NA_real_, sigma_ped_2 = NA_real_,
              h2_1 = NA_real_, h2_1_se = NA_real_, h2_2 = NA_real_, h2_2_se = NA_real_,
              rg = NA_real_, rg_se = NA_real_, re = NA_real_, re_se = NA_real_,
              rp = NA_real_, rp_se = NA_real_,
              h2_1_check = NA_real_, h2_2_check = NA_real_, rg_check = NA_real_,
              re_check = NA_real_, rp_check = NA_real_,
              check_agree_rg = NA, check_agree_rp = NA)

  if (file.exists(asr_path)) {
    terms <- parse_model_terms(asr_path)
    if (!is.null(terms)) {
      # sigma_pe_1/sigma_pe_2: each trait's OWN PE variance, correct for
      # both the classic shared ide(ANI_ID) term (where both come out
      # identical, since diag_idx is then a no-op -- see get_sigma) and
      # the independent-PE diag(Trait).ide(ANI_ID) term introduced
      # 2026-09-18 (where they differ). sigma_ide is kept only as a
      # display column matching pre-2026-09-20 output (== sigma_pe_1);
      # it must NOT be used for phenotypic-variance math below.
      row$sigma_pe_1 <- get_sigma(terms, "ide(ANI_ID)", diag_idx = "1")
      row$sigma_pe_2 <- get_sigma(terms, "ide(ANI_ID)", diag_idx = "2")
      row$sigma_ide <- row$sigma_pe_1
      row$sigma_res_1 <- get_sigma(terms, "Residual", ij = c("1", "1"))
      row$sigma_res_c <- get_sigma(terms, "Residual", ij = c("2", "1"))
      row$sigma_res_2 <- get_sigma(terms, "Residual", ij = c("2", "2"))
      row$sigma_ped_1 <- get_sigma(terms, "ANI_ID", "US", ij = c("1", "1"))
      row$sigma_ped_c <- get_sigma(terms, "ANI_ID", "US", ij = c("2", "1"))
      row$sigma_ped_2 <- get_sigma(terms, "ANI_ID", "US", ij = c("2", "2"))

      vp1 <- row$sigma_pe_1 + row$sigma_res_1 + row$sigma_ped_1
      vp2 <- row$sigma_pe_2 + row$sigma_res_2 + row$sigma_ped_2
      cp <- row$sigma_res_c + row$sigma_ped_c
      row$h2_1_check <- row$sigma_ped_1 / vp1
      row$h2_2_check <- row$sigma_ped_2 / vp2
      row$rg_check <- row$sigma_ped_c / sqrt(row$sigma_ped_1 * row$sigma_ped_2)
      row$re_check <- row$sigma_res_c / sqrt(row$sigma_res_1 * row$sigma_res_2)
      row$rp_check <- cp / sqrt(vp1 * vp2)
    }
  }

  pvc <- parse_pvc(file.path(job_dir, paste0(jobname, ".pvc")))
  if (!is.null(pvc$h2_1)) { row$h2_1 <- pvc$h2_1$estimate; row$h2_1_se <- pvc$h2_1$se }
  if (!is.null(pvc$h2_2)) { row$h2_2 <- pvc$h2_2$estimate; row$h2_2_se <- pvc$h2_2$se }
  if (!is.null(pvc$rg))   { row$rg   <- pvc$rg$estimate;   row$rg_se   <- pvc$rg$se }
  if (!is.null(pvc$re))   { row$re   <- pvc$re$estimate;   row$re_se   <- pvc$re$se }
  if (!is.null(pvc$cp))   { row$rp   <- pvc$cp$estimate;   row$rp_se   <- pvc$cp$se }

  row$check_agree_rg <- n_close(row$rg, row$rg_check)
  row$check_agree_rp <- n_close(row$rp, row$rp_check)

  bi_rows[[length(bi_rows) + 1]] <- row
}

if (length(bi_rows) > 0) {
  bi_df <- do.call(rbind, lapply(bi_rows, as.data.frame, stringsAsFactors = FALSE))
  write.csv(bi_df, file.path(results_dir, "bivariate_summary.csv"), row.names = FALSE)
  cat("Wrote", nrow(bi_df), "rows to results/bivariate_summary.csv\n")
  if (any(!is.na(bi_df$check_agree_rg) & !bi_df$check_agree_rg)) {
    cat("*** WARNING: rg mismatch between VPREDICT and independent Model_Term recomputation for:",
        paste(bi_df$pair[!is.na(bi_df$check_agree_rg) & !bi_df$check_agree_rg], collapse = ", "), "\n")
  }
} else {
  cat("No bi_* job directories found in", run_dir, "\n")
}

#!/usr/bin/env Rscript
# Reviewer 1, item 2: "what proportion of the variation do breed estimates
# account for". For each univariate model, the breed-composition effect of
# every record is sum_b(p_b * beta_b) over the seven breed-proportion terms
# (TX BR SU CL CV LY UN), with beta_b read from ASReml's own .sln (not
# re-estimated). The variance of that value across the trait's records is
# then expressed as a share of
#   (a) the observed phenotypic variance of those records, and
#   (b) breed variance + the model's random variance (sigma_ped +
#       sigma_ide + sigma_residual; homogeneous-residual models only).
# Heterosis/recombination (het, rec) are reported separately and together
# with breed, since the reviewer asked about breed estimates specifically.
#
# Records = rows of phenotype_asreml.csv with a non-missing response, the
# same set ASReml fits under !MVINCLUDE (missing covariates are read as 0).
# Breed proportions vary between animals but are constant within an animal,
# so repeated records weight each animal by its number of records.

sln_dir <- path.expand("~/hpc_incoming/methane_selection_revision_sln_2026-10-20/run")
pipe_dir <- path.expand("~/methane_selection_revision/analysis/revision/asreml_pipeline")
pheno <- read.csv(file.path(pipe_dir, "data/phenotype_asreml.csv"))
unisum <- read.csv(file.path(pipe_dir, "results/univariate_summary.csv"))

breeds <- c("TX", "BR", "SU", "CL", "CV", "LY", "UN")
xbred <- c("het", "rec")

read_sln <- function(path) {
  x <- read.table(path, header = FALSE, skip = 1, fill = TRUE,
                  col.names = c("term", "level", "effect", "se"),
                  stringsAsFactors = FALSE)
  x[x$level == "1", ]
}

response_of <- function(as_path) {
  f <- grep("~", readLines(as_path, warn = FALSE), value = TRUE)[1]
  trimws(sub("~.*", "", f))
}

jobs <- sort(list.files(sln_dir, pattern = "^a_uni_"))
rows <- lapply(jobs, function(job) {
  sln <- read_sln(file.path(sln_dir, job, paste0(job, ".sln")))
  resp <- response_of(file.path(sln_dir, job, paste0(job, ".as")))
  d <- pheno[!is.na(pheno[[resp]]), ]
  beta <- setNames(sln$effect, sln$term)
  X <- as.matrix(d[, c(breeds, xbred)])
  X[is.na(X)] <- 0
  breed_val <- drop(X[, breeds] %*% beta[breeds])
  xbred_val <- drop(X[, xbred] %*% beta[xbred])
  vp_obs <- var(d[[resp]])
  v_breed <- var(breed_val)
  v_both <- var(breed_val + xbred_val)

  code <- sub("^a_uni_", "", job)
  u <- unisum[unisum$trait_code == code, ]
  vp_model <- if (nrow(u) == 1 && !grepl("_het$", code))
    u$sigma_ped + u$sigma_ide + u$sigma_residual else NA
  data.frame(
    trait_code = code, response = resp, n_records = nrow(d),
    var_phen = vp_obs, var_breed = v_breed, var_breed_xbred = v_both,
    pct_breed_of_phen = 100 * v_breed / vp_obs,
    pct_breed_xbred_of_phen = 100 * v_both / vp_obs,
    pct_breed_of_model = 100 * v_breed / (v_breed + vp_model),
    stringsAsFactors = FALSE
  )
})
out <- do.call(rbind, rows)
write.csv(out, "breed_variance_explained.csv", row.names = FALSE)

cat("=== Share of variance explained by breed composition (%) ===\n")
print(transform(out[, c("trait_code", "n_records", "pct_breed_of_phen",
                        "pct_breed_xbred_of_phen", "pct_breed_of_model")],
                pct_breed_of_phen = round(pct_breed_of_phen, 1),
                pct_breed_xbred_of_phen = round(pct_breed_xbred_of_phen, 1),
                pct_breed_of_model = round(pct_breed_of_model, 1)),
      row.names = FALSE)
cat("\nWritten to breed_variance_explained.csv\n")

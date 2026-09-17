#!/usr/bin/env Rscript
# A3 sensitivity model input: the frozen phenotype_asreml.csv plus one
# derived "stage" column (young age_in_years<2 vs mature >=2, the same
# pre-specified rule used in 01_pedigree_connectedness.R's descriptive
# table). Written as a SEPARATE file, not an edit to the frozen input --
# this pipeline's own CLAUDE.md rule against silently altering inputs
# that everything else's checkpointed results depend on.

pipeline_dir <- "../../revision/asreml_pipeline"
pheno <- read.csv(file.path(pipeline_dir, "data", "phenotype_asreml.csv"))
pheno$stage <- ifelse(pheno$age_in_years < 2, "young", "mature")
out_dir <- file.path(pipeline_dir, "data")
write.csv(pheno, file.path(out_dir, "phenotype_asreml_stage.csv"), row.names = FALSE, na = "NA")
cat("Wrote", nrow(pheno), "rows to", file.path(out_dir, "phenotype_asreml_stage.csv"), "\n")
cat("stage counts:\n"); print(table(pheno$stage))

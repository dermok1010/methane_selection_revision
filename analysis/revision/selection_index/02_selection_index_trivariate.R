#!/usr/bin/env Rscript
# Smith-Hazel selection-index analysis for the revision, from the single CH4 x MBW x CO2
# trivariate animal model (results/trivariate_summary.csv, parsed by
# asreml_pipeline/scripts/07_parse_trivariate.R). Point estimates only (no Monte Carlo, by decision).
# Supersedes the pairwise-assembled 01_selection_index_co2.R, whose outputs are kept unchanged for comparison.
#
# Usage (repo root): Rscript analysis/revision/selection_index/02_selection_index_trivariate.R

root <- getwd()
tri_csv <- file.path(root, "analysis/revision/asreml_pipeline/results/trivariate_summary.csv")
pheno_csv <- file.path(root, "analysis/revision/asreml_pipeline/data/phenotype_asreml.csv")
out_dir <- file.path(root, "analysis/revision/selection_index/results")
old_csv <- file.path(out_dir, "index_responses_point_estimates.csv")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
I_REAL <- 1.7; GEN_INT <- 2.8
TR <- c("CH4", "MBW", "CO2")

# ---- matrices from the trivariate fit ------------------------------------------------------------
tri <- read.csv(tri_csv, stringsAsFactors = FALSE); tri <- tri[!is.na(tri$id), ]
sym <- function(rows) { M <- matrix(0, 3, 3, dimnames = list(TR, TR))
  for (k in seq_len(nrow(rows))) M[rows$i[k], rows$j[k]] <- M[rows$j[k], rows$i[k]] <- rows$est[k]; M }
G <- sym(tri[tri$component == "genetic", ])
E <- sym(tri[tri$component == "residual", ])
PE <- diag(tri$est[tri$component == "permanent_env"], 3); dimnames(PE) <- list(TR, TR)   # independent PE per trait, as fitted
P <- G + E + PE
stopifnot(all(eigen(G)$values > 0), all(eigen(E)$values > 0))
ph <- read.csv(pheno_csv)
mu <- c(CH4 = mean(ph$ch4_g_day2_1v3), MBW = mean(ph$Metabolic_BW), CO2 = mean(ph$co2_g_day2_1v3))

# ---- helpers -------------------------------------------------------------------------------------
# Smith-Hazel response to a linear breeding goal H = a'g (a: length-3), information traits `info`.
# `C` (3 x k) optionally imposes zero response in the trait combinations C'g (Kempthorne-Nordskog restricted index).
sh <- function(G, P, info, a, C = NULL) {
  Gx <- G[info, , drop = FALSE]; Pin <- solve(P[info, info, drop = FALSE]); a <- matrix(a, ncol = 1)
  lam <- if (is.null(C)) NULL else solve(t(C) %*% t(Gx) %*% Pin %*% Gx %*% C, t(C) %*% t(Gx) %*% Pin %*% Gx %*% a)
  b <- Pin %*% Gx %*% (if (is.null(C)) a else a - C %*% lam)
  sdI <- sqrt(drop(t(b) %*% P[info, info, drop = FALSE] %*% b))
  resp <- drop(t(Gx) %*% b) / sdI                    # per generation at i = 1
  list(b = drop(b), resp = setNames(resp, TR), r_IH = drop(t(b) %*% Gx %*% a) / (sdI * sqrt(drop(t(a) %*% G %*% a))))
}
a3 <- function(w) c(w, rep(0, 3 - length(w)))
a_ratio <- a3(c(-1 / mu["MBW"], mu["CH4"] / mu["MBW"]^2))   # decrease CH4/MBW, first-order Taylor at the means
beta_P <- P[1, 2] / P[2, 2]; beta_G <- G[1, 2] / G[2, 2]
a_res_P <- a3(c(-1, beta_P)); a_res_G <- a3(c(-1, beta_G))
I2 <- 1:2; I3 <- 1:3
unit <- function(k) { v <- c(0, 0, 0); v[k] <- 1; v }
Cm <- function(ks) sapply(ks, unit)

# ---- check: reproduce the submitted manuscript's ratio/residual responses from its own inputs ----
local({
  VA <- c(2.72527, 1.51857); VE <- c(10.7364, 0.964220); PEs <- 2.38080; muS <- c(17.90444, 21.96824)
  Gs <- matrix(c(VA[1], -0.033 * sqrt(prod(VA)), -0.033 * sqrt(prod(VA)), VA[2]), 2)
  Es <- matrix(c(VE[1], 0.2358 * sqrt(prod(VE)), 0.2358 * sqrt(prod(VE)), VE[2]), 2); Ps <- Gs + Es + diag(PEs, 2)
  r <- function(a) { b <- solve(Ps, Gs %*% a); drop(Gs %*% b / sqrt(drop(t(b) %*% Ps %*% b))) }
  rat <- r(c(-1 / muS[2], muS[1] / muS[2]^2)); res <- r(c(-1, Ps[1, 2] / Ps[2, 2]))
  stopifnot(all(abs(rat - c(-0.56, 0.48)) < 0.006), all(abs(res - c(-0.68, 0.19)) < 0.006))
  cat("legacy reproduction OK: ratio", round(rat, 2), "residual", round(res, 2), "\n")
})

cat("\n== Trivariate matrices ==\nh2:", round(diag(G) / diag(P), 3), "\nrg:\n"); print(round(cov2cor(G), 3))
cat("means (CH4 g/d, MBW, CO2 g/d):", round(mu, 2), "\nbeta_P =", round(beta_P, 4), " beta_G =", round(beta_G, 4), "\n")

# ---- Table 1: main strategies (info = CH4 + MBW) -----------------------------------------------------
strategies <- list(
  list("Ratio CH4/MBW", I2, a_ratio, NULL),
  list("Residual methane (phenotypic beta)", I2, a_res_P, NULL),
  list("Residual methane (genetic beta)", I2, a_res_G, NULL),
  list("CH4 only goal, no MBW constraint", I2, unit(1) * -1, NULL),
  list("CH4 goal, MBW response held at 0", I2, unit(1) * -1, Cm(2)))
t1 <- do.call(rbind, lapply(strategies, function(s) {
  o <- sh(G, P, s[[2]], s[[3]], s[[4]])
  data.frame(strategy = s[[1]], b_CH4 = o$b[1], b_MBW = o$b[2], r_IH = o$r_IH, t(o$resp), check.names = FALSE) }))
names(t1)[names(t1) %in% TR] <- paste0("d", TR)
# grid version of "largest CH4 cut with no MBW loss", kept for continuity with the earlier script
A_grid <- local({ g <- expand.grid(w_CH4 = seq(-10, 10, 0.5), w_MBW = seq(-10, 10, 0.5)); g[!(g$w_CH4 == 0 & g$w_MBW == 0), ] })
Rg <- t(sapply(seq_len(nrow(A_grid)), function(k) sh(G, P, I2, a3(unlist(A_grid[k, ])))$resp))
grid <- cbind(A_grid, dCH4 = Rg[, 1], dMBW = Rg[, 2], dCO2 = Rg[, 3]); rownames(grid) <- NULL
ok <- grid$dCH4 < 0 & grid$dMBW >= 0; gb <- grid[ok, ][which.min(grid$dCH4[ok]), ]
t1 <- rbind(t1, data.frame(strategy = "Grid search: largest CH4 cut with dMBW >= 0", b_CH4 = NA, b_MBW = NA, r_IH = NA,
                           dCH4 = gb$dCH4, dMBW = gb$dMBW, dCO2 = gb$dCO2))
for (tt in TR) { t1[[paste0("d", tt, "_i1.7")]] <- t1[[paste0("d", tt)]] * I_REAL
                 t1[[paste0("d", tt, "_per_yr")]] <- t1[[paste0("d", tt, "_i1.7")]] / GEN_INT }
write.csv(t1, file.path(out_dir, "tri_index_responses_point.csv"), row.names = FALSE)
write.csv(grid, file.path(out_dir, "tri_index_response_grid.csv"), row.names = FALSE)
cat("\n== Table 1: responses per generation at i = 1 (last columns: i = 1.7, per year at 2.8 y) ==\n"); print(t1, digits = 3, row.names = FALSE)

# ---- Table 2: what is measured (information set) x what is wanted ----------------------------------
info_sets <- list("CH4 only" = 1, "CH4 + MBW" = I2, "CH4 + MBW + CO2" = I3)
goals <- list("Reduce CH4 (no constraint)" = list(-unit(1), NULL),
              "Reduce CH4, MBW held constant" = list(-unit(1), Cm(2)),
              "Reduce CH4, MBW and CO2 held constant" = list(-unit(1), Cm(2:3)))
t2 <- do.call(rbind, lapply(names(info_sets), function(ni) do.call(rbind, lapply(names(goals), function(ng) {
  if (!is.null(goals[[ng]][[2]]) && !all(which(rowSums(abs(goals[[ng]][[2]])) > 0) %in% info_sets[[ni]])) return(NULL)
  o <- sh(G, P, info_sets[[ni]], goals[[ng]][[1]], goals[[ng]][[2]])
  data.frame(information = ni, goal = ng, r_IH = o$r_IH, dCH4 = o$resp[1], dMBW = o$resp[2], dCO2 = o$resp[3]) }))))
write.csv(t2, file.path(out_dir, "tri_information_sets.csv"), row.names = FALSE)
cat("\n== Table 2: information set x goal (i = 1) ==\n"); print(t2, digits = 3, row.names = FALSE)

# ---- Table 3: genetic independence of the phenotypic residual, and (CH4,MBW) <-> (R,MBW) equivalence ----
VA_R <- G[1, 1] - 2 * beta_P * G[1, 2] + beta_P^2 * G[2, 2]
cov_R_MBW <- G[1, 2] - beta_P * G[2, 2]; cov_R_CO2 <- G[1, 3] - beta_P * G[2, 3]
VP_R <- P[1, 1] - 2 * beta_P * P[1, 2] + beta_P^2 * P[2, 2]
t3 <- data.frame(quantity = c("beta_P = Cov_P(CH4,MBW)/Var_P(MBW)", "beta_G = Cov_G(CH4,MBW)/Var_G(MBW)",
                              "h2 of phenotypic residual R = CH4 - beta_P*MBW", "genetic correlation R with MBW",
                              "genetic correlation R with CH4", "genetic correlation R with CO2"),
                 value = c(beta_P, beta_G, VA_R / VP_R, cov_R_MBW / sqrt(VA_R * G[2, 2]),
                           (G[1, 1] - beta_P * G[1, 2]) / sqrt(VA_R * G[1, 1]), cov_R_CO2 / sqrt(VA_R * G[3, 3])))
# equivalence: index on (R, MBW) for goal R  ==  index on (CH4, MBW) for goal CH4 - beta_P*MBW
T <- matrix(c(1, -beta_P, 0, 1), 2, byrow = TRUE)               # (R, MBW)' = T (CH4, MBW)'
G2 <- T %*% G[I2, I2] %*% t(T); P2 <- T %*% P[I2, I2] %*% t(T)
b_R <- solve(P2, G2 %*% c(-1, 0)); resp_R <- drop(G[I2, I2] %*% t(T) %*% b_R) / sqrt(drop(t(b_R) %*% P2 %*% b_R))
o_res <- sh(G, P, I2, a_res_P)
t3 <- rbind(t3, data.frame(quantity = c("index weight on CH4 in (CH4,MBW) basis", "index weight on MBW in (CH4,MBW) basis",
                                        "index weight on R in (R,MBW) basis", "index weight on MBW in (R,MBW) basis",
                                        "max abs difference in dCH4/dMBW between the two bases"),
                           value = c(o_res$b, b_R[1], b_R[2], max(abs(resp_R - o_res$resp[1:2])))))
write.csv(t3, file.path(out_dir, "tri_residual_genetic_independence.csv"), row.names = FALSE)
cat("\n== Table 3 ==\n"); print(t3, digits = 4, row.names = FALSE)
stopifnot(max(abs(resp_R - o_res$resp[1:2])) < 1e-8)

# ---- Table 4: sensitivity of the ratio/residual/hold-MBW responses to the CH4-MBW genetic correlation ----
# (2-trait CH4 x MBW index, trivariate variances; -0.033 is the value used in the submitted paper)
sweep_rows <- lapply(c(-0.033, 0.2, 0.4, 0.6, cov2cor(G)[1, 2], 0.8), function(r) {
  G2 <- G[I2, I2]; G2[1, 2] <- G2[2, 1] <- r * sqrt(G[1, 1] * G[2, 2])
  E2 <- E[I2, I2]; P2 <- G2 + E2 + PE[I2, I2]
  f <- function(a, Cm2 = NULL) { Gx <- G2; Pin <- solve(P2); a <- matrix(a, ncol = 1)
    b <- if (is.null(Cm2)) Pin %*% Gx %*% a else { cc <- matrix(Cm2, ncol = 1); Pin %*% Gx %*% (a - cc %*% solve(t(cc) %*% Gx %*% Pin %*% Gx %*% cc, t(cc) %*% Gx %*% Pin %*% Gx %*% a)) }
    drop(Gx %*% b) / sqrt(drop(t(b) %*% P2 %*% b)) }
  bp <- P2[1, 2] / P2[2, 2]
  rbind(data.frame(rg_CH4_MBW = r, strategy = "Ratio CH4/MBW", t(setNames(f(c(-1 / mu["MBW"], mu["CH4"] / mu["MBW"]^2)), c("dCH4", "dMBW")))),
        data.frame(rg_CH4_MBW = r, strategy = "Residual methane", t(setNames(f(c(-1, bp)), c("dCH4", "dMBW")))),
        data.frame(rg_CH4_MBW = r, strategy = "CH4 goal, MBW held at 0", t(setNames(f(c(-1, 0), c(0, 1)), c("dCH4", "dMBW")))))
})
t4 <- do.call(rbind, sweep_rows)
write.csv(t4, file.path(out_dir, "tri_rg_sensitivity.csv"), row.names = FALSE)
cat("\n== Table 4: sensitivity to rg(CH4,MBW) (2-trait index) ==\n"); print(t4, digits = 3, row.names = FALSE)

# ---- Table 5: change from the earlier pairwise assembly (the superseded 01_ script, primary set) ----
if (file.exists(old_csv)) {
  old <- read.csv(old_csv); old <- old[old$param_set == "primary", c("strategy", "dCH4", "dMBW", "dCO2")]
  map <- c(ratio = "Ratio CH4/MBW", residual = "Residual methane (phenotypic beta)",
           best_CH4_cut_MBW_nonneg = "Grid search: largest CH4 cut with dMBW >= 0")
  t5 <- do.call(rbind, lapply(names(map), function(k) {
    n <- t1[t1$strategy == map[[k]], ]; o <- old[old$strategy == k, ]
    data.frame(strategy = map[[k]], pairwise_dCH4 = o$dCH4, tri_dCH4 = n$dCH4, pairwise_dMBW = o$dMBW, tri_dMBW = n$dMBW,
               pairwise_dCO2 = o$dCO2, tri_dCO2 = n$dCO2) }))
  write.csv(t5, file.path(out_dir, "tri_vs_pairwise_assembly.csv"), row.names = FALSE)
  cat("\n== Table 5: pairwise assembly vs trivariate (i = 1) ==\n"); print(t5, digits = 3, row.names = FALSE)
}
writeLines(capture.output(sessionInfo()), file.path(out_dir, "R_session_trivariate.txt"))

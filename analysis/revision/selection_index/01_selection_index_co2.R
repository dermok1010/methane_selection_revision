#!/usr/bin/env Rscript
# Smith-Hazel selection-index demonstration for methane traits, with CO2 (an
# intake proxy) as the unweighted correlated trait in place of ADG.
#
# Index information traits: CH4, MBW.  Correlated-response trait: CO2.
# G/P are assembled from the rebuilt pairwise ASReml fits in
# ../asreml_pipeline/results/bivariate_summary.csv (methane_mbw, methane_co2,
# mbw_co2), with trait-specific permanent-environment variances and no PE
# covariance. Responses are per generation at selection intensity i = 1
# (columns for i = 1.7 and per year at a 2.8-year generation interval are added).
#
# Usage (from the repo root): Rscript analysis/revision/selection_index/01_selection_index_co2.R

args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args) >= 1) args[1] else getwd()
res_dir <- file.path(root, "analysis/revision/asreml_pipeline/results")
pheno_csv <- file.path(root, "analysis/revision/asreml_pipeline/data/phenotype_asreml.csv")
out_dir <- file.path(root, "analysis/revision/selection_index/results")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

N_MC <- 1000L
set.seed(20260929)
I_REAL <- 1.7
GEN_INT <- 2.8
TR <- c("CH4", "MBW", "CO2")

biv <- read.csv(file.path(res_dir, "bivariate_summary.csv"), stringsAsFactors = FALSE)
pair <- function(nm) {
  r <- biv[biv$pair == nm, ]
  stopifnot(nrow(r) == 1, r$convergence == "CONVERGED")
  r
}
ph <- read.csv(pheno_csv)
mu <- c(CH4 = mean(ph$ch4_g_day2_1v3), MBW = mean(ph$Metabolic_BW), CO2 = mean(ph$co2_g_day2_1v3))

# variance components of one trait in one pair (slot 1 or 2)
comp <- function(r, slot) {
  s <- as.character(slot)
  c(VA = r[[paste0("sigma_ped_", s)]], PE = r[[paste0("sigma_pe_", s)]], E = r[[paste0("sigma_res_", s)]],
    h2se = r[[paste0("h2_", s, "_se")]])
}

# ---- parameter sets ---------------------------------------------------------
m_mbw <- pair("methane_mbw"); m_co2 <- pair("methane_co2"); mbw_co2 <- pair("mbw_co2")
param_sets <- list(
  primary = list(   # CH4/MBW variances from the CH4-MBW pair, CO2 from the CH4-CO2 pair
    var = list(CH4 = comp(m_mbw, 1), MBW = comp(m_mbw, 2), CO2 = comp(m_co2, 2))),
  alt_mbw_co2_pair = list(   # MBW/CO2 variances from the MBW-CO2 pair, CH4 from the CH4-MBW pair
    var = list(CH4 = comp(m_mbw, 1), MBW = comp(mbw_co2, 1), CO2 = comp(mbw_co2, 2))))
cor_pt <- list(
  rg = c(CH4_MBW = m_mbw$rg, CH4_CO2 = m_co2$rg, MBW_CO2 = mbw_co2$rg),
  rg_se = c(m_mbw$rg_se, m_co2$rg_se, mbw_co2$rg_se),
  re = c(CH4_MBW = m_mbw$re, CH4_CO2 = m_co2$re, MBW_CO2 = mbw_co2$re),
  re_se = c(m_mbw$re_se, m_co2$re_se, mbw_co2$re_se))

# ---- helpers ----------------------------------------------------------------
cor_mat <- function(r3) {
  R <- diag(3); R[1, 2] <- R[2, 1] <- r3[1]; R[1, 3] <- R[3, 1] <- r3[2]; R[2, 3] <- R[3, 2] <- r3[3]
  dimnames(R) <- list(TR, TR); R
}
make_PD <- function(M) {   # eigenvalue floor, rescaled to keep the diagonal
  e <- eigen(M, symmetric = TRUE)
  if (min(e$values) > 1e-8) return(M)
  v <- pmax(e$values, 1e-6); M2 <- e$vectors %*% diag(v) %*% t(e$vectors)
  d <- sqrt(diag(M) / diag(M2)); M2 <- M2 * outer(d, d); dimnames(M2) <- dimnames(M); M2
}
rfisher <- function(n, r, se) { r <- pmax(pmin(r, 0.999), -0.999); tanh(rnorm(n, atanh(r), se / (1 - r^2))) }

build_GP <- function(V, rg, re) {
  sdA <- sqrt(sapply(V, `[[`, "VA")); sdE <- sqrt(sapply(V, `[[`, "E")); PE <- sapply(V, `[[`, "PE")
  G <- make_PD(outer(sdA, sdA) * cor_mat(rg)); E <- make_PD(outer(sdE, sdE) * cor_mat(re))
  P <- G + E + diag(PE); dimnames(P) <- dimnames(G)
  list(G = G, P = P)
}

A_grid <- local({   # CH4 x MBW breeding-goal weights, -10..10 by 0.5, minus (0,0)
  g <- expand.grid(w_CH4 = seq(-10, 10, 0.5), w_MBW = seq(-10, 10, 0.5))
  g <- g[!(g$w_CH4 == 0 & g$w_MBW == 0), ]; rownames(g) <- NULL; g })

# response of all three traits to selection on the CH4+MBW index, for goal vectors a (2 x m)
resp3 <- function(G, P, A) {
  idx <- 1:2; B <- solve(P[idx, idx], G[idx, idx] %*% A)
  sdI <- sqrt(colSums(B * (P[idx, idx] %*% B)))
  t(sweep(t(G[, idx] %*% B), 1, sdI, "/"))   # 3 x m; rows CH4, MBW, CO2
}

a_ratio <- c(-1 / mu["MBW"], mu["CH4"] / mu["MBW"]^2)   # decrease CH4/MBW, first-order Taylor
special <- function(G, P) {
  beta_P <- P[1, 2] / P[2, 2]
  list(ratio = unname(a_ratio), residual = c(-1, beta_P))
}
# grid direction with the largest CH4 reduction subject to no loss in MBW
constrained_best <- function(R) {
  ok <- R["CH4", ] < 0 & R["MBW", ] >= 0
  if (!any(ok)) return(rep(NA_real_, 3))
  R[, which(ok)[which.min(R["CH4", ok])]]
}

point_table <- function(G, P) {
  sp <- special(G, P); rows <- list()
  for (nm in names(sp)) {
    r <- resp3(G, P, matrix(sp[[nm]], 2, 1)); rows[[nm]] <- c(r)
  }
  R <- resp3(G, P, t(as.matrix(A_grid)))
  rows[["best_CH4_cut_MBW_nonneg"]] <- constrained_best(R)
  out <- do.call(rbind, rows); colnames(out) <- paste0("d", TR)
  data.frame(strategy = rownames(out), out, row.names = NULL)
}

# ---- check: reproduce the submitted manuscript's ratio/residual responses from its own inputs ----
# (rg CH4-MBW = -0.033, shared PE scalar; expected -0.56/+0.48 and -0.68/+0.19 at i = 1)
local({
  VA <- c(2.72527, 1.51857); VE <- c(10.7364, 0.964220); PEs <- 2.38080; muS <- c(17.90444, 21.96824)
  G <- matrix(c(VA[1], -0.033 * sqrt(prod(VA)), -0.033 * sqrt(prod(VA)), VA[2]), 2)
  E <- matrix(c(VE[1], 0.2358 * sqrt(prod(VE)), 0.2358 * sqrt(prod(VE)), VE[2]), 2); P <- G + E + diag(PEs, 2)
  r <- function(a) { b <- solve(P, G %*% a); drop(G %*% b / sqrt(drop(t(b) %*% P %*% b))) }
  rat <- r(c(-1 / muS[2], muS[1] / muS[2]^2)); res <- r(c(-1, P[1, 2] / P[2, 2]))
  stopifnot(all(abs(rat - c(-0.56, 0.48)) < 0.006), all(abs(res - c(-0.68, 0.19)) < 0.006))
  cat("legacy reproduction OK: ratio", round(rat, 2), "residual", round(res, 2), "\n")
})

# ---- point estimates ---------------------------------------------------------
all_points <- list(); all_G <- list()
for (ps in names(param_sets)) {
  gp <- build_GP(param_sets[[ps]]$var, cor_pt$rg, cor_pt$re)
  pt <- point_table(gp$G, gp$P); pt$param_set <- ps; all_points[[ps]] <- pt
  all_G[[ps]] <- gp
  cat("\n== ", ps, ": h2 =", paste(TR, round(diag(gp$G) / diag(gp$P), 3), collapse = ", "), "\n")
  cat("genetic correlations:\n"); print(round(cov2cor(gp$G), 3))
  pr <- cov2cor(gp$G); pcor <- (pr[1, 3] - pr[1, 2] * pr[2, 3]) / sqrt((1 - pr[1, 2]^2) * (1 - pr[2, 3]^2))
  cat("partial genetic correlation CH4-CO2 given MBW:", round(pcor, 3), "\n")
  print(pt, digits = 3)
}
points <- do.call(rbind, all_points)
points$dCH4_i1.7 <- points$dCH4 * I_REAL; points$dMBW_i1.7 <- points$dMBW * I_REAL; points$dCO2_i1.7 <- points$dCO2 * I_REAL
points$dCH4_per_yr <- points$dCH4_i1.7 / GEN_INT; points$dMBW_per_yr <- points$dMBW_i1.7 / GEN_INT; points$dCO2_per_yr <- points$dCO2_i1.7 / GEN_INT
write.csv(points, file.path(out_dir, "index_responses_point_estimates.csv"), row.names = FALSE)

# full grid for the primary parameter set (frontier plots / supplement)
R0 <- resp3(all_G$primary$G, all_G$primary$P, t(as.matrix(A_grid)))
write.csv(cbind(A_grid, dCH4 = R0["CH4", ], dMBW = R0["MBW", ], dCO2 = R0["CO2", ]),
          file.path(out_dir, "index_response_grid_primary.csv"), row.names = FALSE)

# ---- Monte Carlo (correlations Fisher-z, heritabilities normal on h2 SE; VP and PE held at estimates) ----
mc_all <- list()
for (ps in names(param_sets)) {
  V0 <- param_sets[[ps]]$var
  draws <- vector("list", N_MC)
  for (k in seq_len(N_MC)) {
    V <- lapply(V0, function(v) {
      vp <- v[["VA"]] + v[["PE"]] + v[["E"]]
      h2 <- min(max(rnorm(1, v[["VA"]] / vp, v[["h2se"]]), 0.02), 0.95)
      va <- h2 * vp; e <- max(vp - va - v[["PE"]], 0.02 * vp)
      c(VA = va, PE = v[["PE"]], E = e, h2se = v[["h2se"]])
    })
    rg <- mapply(rfisher, 1, cor_pt$rg, cor_pt$rg_se); re <- mapply(rfisher, 1, cor_pt$re, cor_pt$re_se)
    gp <- build_GP(V, rg, re)
    draws[[k]] <- point_table(gp$G, gp$P)
  }
  d <- do.call(rbind, draws)
  mc <- do.call(rbind, lapply(split(d, d$strategy), function(x) {
    data.frame(strategy = x$strategy[1], n_draws = nrow(x),
               do.call(cbind, lapply(paste0("d", TR), function(cn) {
                 v <- x[[cn]]; setNames(data.frame(mean(v, na.rm = TRUE), sd(v, na.rm = TRUE), quantile(v, 0.025, na.rm = TRUE), quantile(v, 0.975, na.rm = TRUE)),
                                        paste0(cn, c("_mean", "_sd", "_lo95", "_hi95"))) })))
  }))
  mc$param_set <- ps; rownames(mc) <- NULL; mc_all[[ps]] <- mc
}
mc_out <- do.call(rbind, mc_all)
write.csv(mc_out, file.path(out_dir, "index_responses_monte_carlo.csv"), row.names = FALSE)
cat("\n== Monte Carlo (", N_MC, "draws) ==\n"); print(mc_out, digits = 3, row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out_dir, "R_session.txt"))

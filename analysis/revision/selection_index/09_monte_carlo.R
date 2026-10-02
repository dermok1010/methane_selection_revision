#!/usr/bin/env Rscript
# Monte Carlo propagation of sampling error in the trivariate CH4 x MBW x CO2 parameters into every selection-index
# quantity reported in the paper (author decision 2026-10-02, reversing the 2026-09-29 "no Monte Carlo" decision).
# All 15 variance parameters (6 residual, 6 genetic, 3 PE) are drawn jointly from MVN(estimate, V), V = ASReml's
# sampling (co)variance matrix (.vvp, inverse average information), so correlations between estimates are kept
# (the submitted analysis drew variances and correlations independently). Draws with a non-PD G, residual or P,
# or a negative PE variance, are rejected and counted. For each draw G, P are rebuilt and everything recomputed;
# coefficients defined from G or P (genetic and phenotypic residual) are recomputed per draw, ratio linearisations
# (trait means) are held fixed. Three-trait information throughout; i = 1 per generation.
#
# Inputs: analysis/revision/asreml_pipeline/results/trivariate_summary.csv (point estimates) and
#   trivariate_sampling_cov.csv (parsed from tri_methane_mbw_co2.vvp; rebuilt from VVP=<path> if absent).
# Usage (repo root): [VVP=path/to/tri_methane_mbw_co2.vvp] Rscript analysis/revision/selection_index/09_monte_carlo.R

local({ f <- readLines("analysis/revision/selection_index/02_selection_index_trivariate.R")
        f <- f[seq_len(grep("^# ---- Table 1", f)[1] - 1)]; eval(parse(text = f), envir = globalenv()) })
out <- "analysis/revision/selection_index/results"
N_DRAW <- 10000; SEED <- 20261002

# ---- sampling covariance of the 15 parameters ----------------------------------------------------
vcsv <- "analysis/revision/asreml_pipeline/results/trivariate_sampling_cov.csv"
if (!file.exists(vcsv)) {
  vvp <- Sys.getenv("VVP"); if (!nzchar(vvp)) stop("trivariate_sampling_cov.csv missing: set VVP=<path to tri_methane_mbw_co2.vvp>")
  x <- scan(vvp, what = "", quiet = TRUE); np <- as.integer(x[grep("components", x)[1] + 1])
  v <- as.numeric(x[-seq_len(grep("components", x)[1] + 1)]); stopifnot(length(v) == np * (np + 1) / 2)
  V <- matrix(0, np, np); V[upper.tri(V, diag = TRUE)] <- v; V <- t(V); V[upper.tri(V)] <- t(V)[upper.tri(V)]   # file is lower triangle by rows
  write.csv(V, vcsv, row.names = FALSE)
}
V <- as.matrix(read.csv(vcsv)); dimnames(V) <- NULL
th0 <- tri$est[order(tri$id)]
stopifnot(nrow(V) == 15, max(abs(sqrt(diag(V)) / tri$se[order(tri$id)] - 1)) < 1e-3)   # vvp order = .pvc numbering = id
build <- function(th) {
  s <- function(k) { M <- matrix(0, 3, 3, dimnames = list(TR, TR)); M[upper.tri(M, diag = TRUE)] <- th[k]
                     M[lower.tri(M)] <- t(M)[lower.tri(M)]; M }   # ids are (1,1),(2,1),(2,2),(3,1),(3,2),(3,3) = upper tri by columns
  E <- s(1:6); G <- s(7:12); PE <- diag(th[13:15], 3); dimnames(PE) <- list(TR, TR); list(G = G, E = E, PE = PE, P = G + E + PE) }
m0 <- build(th0); stopifnot(max(abs(m0$G - G)) < 1e-9, max(abs(m0$P - P)) < 1e-9)

# ---- every reported quantity as a function of (G, P) ---------------------------------------------
in_reg <- function(r, tol = 1e-9) r[1] < 0 & r[2] >= -tol & r[3] >= -tol
c_ratio_mbw <- unname(mu["CH4"] / mu["MBW"]); c_ratio_co2 <- unname(mu["CH4"] / mu["CO2"])
# max of k'D over the attainable ellipsoid {D: D' M^-1 D <= 1}, M = G P^-1 G, inside dCH4 <= 0, dMBW >= 0, dCO2 >= 0:
# enumerate which sign constraints bind (each binding one is an equality), keep the best feasible maximiser
max_in_region <- function(M, k) {
  sgn <- c(-1, 1, 1); best <- -Inf
  for (S in list(integer(0), 1, 2, 3, c(1, 2), c(1, 3), c(2, 3))) {
    if (length(S)) { A <- diag(3)[, S, drop = FALSE]; lam <- solve(t(A) %*% M %*% A, t(A) %*% M %*% k); u <- k - A %*% lam }
    else u <- k
    q <- drop(t(u) %*% M %*% u); if (q <= 1e-12) next
    D <- drop(M %*% u) / sqrt(q)
    if (all(sgn * D >= -1e-9)) best <- max(best, sum(k * D)) }
  best }
z_ball <- local({ set.seed(1); n <- 2e5; z <- matrix(rnorm(3 * n), 3); z <- sweep(z, 2, sqrt(colSums(z^2)), "/")
                  z * rep(runif(n)^(1/3), each = 3) })                 # common random points for the region share
goals <- list(abs_CH4 = c(0, 0), gen_res = NULL, phe_res = NULL, ratio_MBW = c(c_ratio_mbw, 0), ratio_CO2 = c(0, c_ratio_co2))

stats_of <- function(G, P) {
  M <- G %*% solve(P) %*% G
  ref <- sh(G, P, I3, -unit(1), Cm(2:3)); top <- sh(G, P, I3, -unit(1))
  a0 <- drop(solve(G, P %*% ref$b)); a0 <- a0 * -1 / a0[1]          # reference goal, CH4 weight -1
  cc <- goals; cc$gen_res <- unname(solve(G[2:3, 2:3], G[2:3, 1])); cc$phe_res <- unname(solve(P[2:3, 2:3], P[2:3, 1]))
  alone <- lapply(cc, function(c2) sh(G, P, I3, c(-1, c2))$resp)
  extra <- lapply(cc, function(c2) a0[2:3] - c2)                       # Table 6: weights added on top of the methane term
  D <- t(t(chol(M)) %*% z_ball)
  c(ref_dCH4 = ref$resp[[1]], max_cut = top$resp[[1]], ref_pct_of_max = 100 * ref$resp[[1]] / top$resp[[1]],
    region_share = mean(D[, 1] < 0 & D[, 2] >= 0 & D[, 3] >= 0),
    max_dMBW_reg = max_in_region(M, c(0, 1, 0)), max_dCO2_reg = max_in_region(M, c(0, 0, 1)),
    econ_lo = max(M[2, 1] / M[2, 2], M[3, 1] / M[3, 2]), econ_hi = M[1, 1] / M[1, 2],   # goal (-1, m, 0): region iff lo <= m < hi
    unlist(lapply(names(alone), function(n) setNames(c(alone[[n]], in_reg(alone[[n]])),
                                                     paste0(n, c("_dCH4", "_dMBW", "_dCO2", "_in_region"))))),
    unlist(lapply(names(extra), function(n) setNames(extra[[n]], paste0("t6_", n, c("_wMBW", "_wCO2"))))),
    gen_res_cMBW = cc$gen_res[1], gen_res_cCO2 = cc$gen_res[2], phe_res_cMBW = cc$phe_res[1], phe_res_cCO2 = cc$phe_res[2])
}
pt <- stats_of(G, P)
stopifnot(abs(pt[["ref_dCH4"]] - (-0.6106)) < 1e-3, pt[["econ_lo"]] < pt[["econ_hi"]])   # as reported (-0.61)

# ---- draws ---------------------------------------------------------------------------------------
set.seed(SEED); L <- t(chol(V)); keep <- list(); n_rej <- 0; n_try <- 0
while (length(keep) < N_DRAW) {
  n_try <- n_try + 1; th <- th0 + drop(L %*% rnorm(15)); m <- build(th)
  ok <- all(th[13:15] > 0) && all(eigen(m$G, TRUE, TRUE)$values > 0) && all(eigen(m$E, TRUE, TRUE)$values > 0)
  if (!ok) { n_rej <- n_rej + 1; next }
  keep[[length(keep) + 1]] <- stats_of(m$G, m$P) }
D <- do.call(rbind, keep)
write.csv(D, file.path(out, "tri_monte_carlo_draws.csv"), row.names = FALSE)

q <- function(x) quantile(x, c(0.025, 0.975), names = FALSE)
summ <- data.frame(quantity = colnames(D), point = unname(pt[colnames(D)]), mc_mean = colMeans(D),
                   mc_sd = apply(D, 2, sd), lo95 = apply(D, 2, q)[1, ], hi95 = apply(D, 2, q)[2, ], row.names = NULL)
summ[grepl("_in_region$", summ$quantity), c("mc_sd", "lo95", "hi95")] <- NA   # these are proportions of draws (mc_mean)
write.csv(summ, file.path(out, "tri_monte_carlo_summary.csv"), row.names = FALSE)
cat(sprintf("draws kept %d of %d tried (%d rejected: non-PD G/E or negative PE); seed %d\n\n", N_DRAW, n_try, n_rej, SEED))
print(summ, digits = 3, row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "R_session_monte_carlo.txt"))

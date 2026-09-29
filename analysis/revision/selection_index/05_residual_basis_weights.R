#!/usr/bin/env Rscript
# Three-trait index written in residual coordinates: R = CH4 - b1*MBW - b2*CO2 (phenotypic or genetic betas), MBW, CO2.
# (R, MBW, CO2) is an invertible linear transform T of (CH4, MBW, CO2), so Smith-Hazel responses are unchanged; only weights change.
# Goal in residual coordinates: -R + x_MBW*MBW + x_CO2*CO2, with x = (goal weight in CH4 coordinates) - (residual betas).
# Usage (repo root): Rscript analysis/revision/selection_index/05_residual_basis_weights.R
local({ f <- readLines("analysis/revision/selection_index/02_selection_index_trivariate.R")
        f <- f[seq_len(grep("^# ---- Table 1", f)[1] - 1)]; eval(parse(text = f), envir = globalenv()) })
out_dir <- "analysis/revision/selection_index/results"
in_region <- function(r, tol = 1e-9) r[1] < 0 & r[2] >= -tol & r[3] >= -tol

bP <- solve(P[2:3, 2:3], P[2:3, 1]); bG <- solve(G[2:3, 2:3], G[2:3, 1])
# goal in CH4 coordinates that reaches the region with the largest CH4 cut (MBW response held at 0, from 04_favourable_region.R)
o0 <- sh(G, P, I3, -unit(1), Cm(2)); stopifnot(in_region(o0$resp))
a0 <- drop(solve(G, P %*% o0$b)); a0 <- a0 * -1 / a0[1]

rows <- list()
for (nm in c("phenotypic", "genetic")) {
  b <- if (nm == "phenotypic") bP else bG
  Tm <- rbind(c(1, -b), c(0, 1, 0), c(0, 0, 1)); Ti <- solve(Tm)
  GT <- Tm %*% G %*% t(Tm); PT <- Tm %*% P %*% t(Tm)
  aT <- drop(t(Ti) %*% a0); bT <- drop(solve(PT, GT %*% aT))
  respT <- drop(GT %*% bT / sqrt(drop(t(bT) %*% PT %*% bT)))
  stopifnot(max(abs(drop(Tm %*% o0$resp) - respT)) < 1e-8)   # same responses in both coordinate systems
  cat(sprintf("\n%s residual  R = CH4 - %.4f MBW - %.6f CO2\n", nm, b[1], b[2]))
  cat("  genetic correlation of R with (MBW, CO2):", round(cov2cor(GT)[1, 2:3], 3), "; h2 of R:", round(GT[1, 1] / PT[1, 1], 3), "\n")
  cat("  goal weights in CH4 coordinates (CH4=-1):", signif(a0, 4), "\n")
  cat("  goal weights in residual coordinates (R=-1):", signif(aT, 4), "\n")
  cat("  index weights, CH4 coordinates:", signif(o0$b, 4), "; residual coordinates:", signif(bT, 4), "\n")
  rows[[nm]] <- data.frame(residual = nm, beta_MBW = b[1], beta_CO2_per100 = b[2] * 100,
    goal_R = aT[1], goal_MBW = aT[2], goal_CO2_per100 = aT[3] * 100, index_R = bT[1], index_MBW = bT[2], index_CO2 = bT[3],
    goal_CH4coord_MBW = a0[2], goal_CH4coord_CO2_per100 = a0[3] * 100, dR = respT[1], dCH4 = drop(Ti %*% respT)[1], dMBW = respT[2], dCO2 = respT[3],
    gen_cor_R_MBW = cov2cor(GT)[1, 2], gen_cor_R_CO2 = cov2cor(GT)[1, 3], h2_R = GT[1, 1] / PT[1, 1])
}
tab <- do.call(rbind, rows); rownames(tab) <- NULL
write.csv(tab, file.path(out_dir, "tri_residual_basis_weights.csv"), row.names = FALSE)
print(t(signif(tab[, -1], 4)))


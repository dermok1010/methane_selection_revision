#!/usr/bin/env Rscript
# Headline favourable index restricted to zero response in BOTH MBW and CO2 (author decision 2026-09-30):
# CO2 is treated as a safeguard against methane cuts that come from lower intake, not as a trait to increase,
# so the reference goal is CH4 reduced with MBW and CO2 held at zero (supersedes 07's MBW-only reference,
# which gave CO2 +10 g/d). Writes the paper's Table 7 reference row, Table 8 index weights (same index written
# around CH4, the genetic residual and the phenotypic residual) and the S2 i = 1.7 / per-year values.
# Three-trait (CH4, MBW, CO2) information; point estimates; i = 1 per generation.
# Usage (repo root): Rscript analysis/revision/selection_index/08_restricted_mbw_co2_weights.R
local({ f <- readLines("analysis/revision/selection_index/02_selection_index_trivariate.R")
        f <- f[seq_len(grep("^# ---- Table 1", f)[1] - 1)]; eval(parse(text = f), envir = globalenv()) })
out <- "analysis/revision/selection_index/results"

o1 <- sh(G, P, I3, -unit(1), Cm(2:3))
stopifnot(o1$resp[1] < 0, abs(o1$resp[2]) < 1e-9, abs(o1$resp[3]) < 1e-9)
o0 <- sh(G, P, I3, -unit(1))                                        # unconstrained CH4 goal, for the % of response

bP <- solve(P[2:3, 2:3], P[2:3, 1]); bG <- solve(G[2:3, 2:3], G[2:3, 1])
cons <- list("Three traits (CH4, MBW, CO2 as themselves)" = c(0, 0),
             "Genetic residual (CH4 on MBW + CO2)"        = unname(bG),
             "Phenotypic residual (CH4 on MBW + CO2)"     = unname(bP))
tab <- do.call(rbind, lapply(names(cons), function(nm) {
  cc <- cons[[nm]]; Ti <- solve(rbind(c(1, -cc), c(0, 1, 0), c(0, 0, 1)))
  bT <- drop(t(Ti) %*% o1$b)
  data.frame(construction = nm, index_R = bT[1], index_MBW = bT[2], index_CO2 = bT[3],
             ref_dCH4 = o1$resp[1], ref_dMBW = o1$resp[2], ref_dCO2 = o1$resp[3], r_IH = o1$r_IH,
             pct_of_unconstrained = 100 * o1$resp[1] / o0$resp[1])
}))
# every coordinate system must describe the same index: re-derive responses from the transformed weights
for (k in seq_len(nrow(tab))) {
  cc <- cons[[k]]; Tm <- rbind(c(1, -cc), c(0, 1, 0), c(0, 0, 1))
  stopifnot(max(abs(drop(t(Tm) %*% unlist(tab[k, c("index_R", "index_MBW", "index_CO2")])) - o1$b)) < 1e-12)
}
write.csv(tab, file.path(out, "tri_restricted_mbw_co2_index_weights.csv"), row.names = FALSE)
s2 <- data.frame(dCH4 = o1$resp[1], dMBW = o1$resp[2], dCO2 = o1$resp[3],
                 dCH4_i1.7 = 1.7 * o1$resp[1], dCH4_per_yr = 1.7 / 2.8 * o1$resp[1])
write.csv(s2, file.path(out, "tri_restricted_mbw_co2_s2.csv"), row.names = FALSE)
print(tab); print(s2)

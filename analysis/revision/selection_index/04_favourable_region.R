#!/usr/bin/env Rscript
# Favourable-region framing: which indices reach the region dCH4 < 0, dMBW >= 0, dCO2 >= 0, and at what weights.
# Same trivariate G/E/PE as 02_selection_index_trivariate.R (its setup and helpers are sourced); point estimates.
# Usage (repo root): Rscript analysis/revision/selection_index/04_favourable_region.R
suppressMessages(library(ggplot2))
local({ f <- readLines("analysis/revision/selection_index/02_selection_index_trivariate.R")
        f <- f[seq_len(grep("^# ---- Table 1", f)[1] - 1)]; eval(parse(text = f), envir = globalenv()) })
out_dir <- "analysis/revision/selection_index/results"
in_region <- function(r, tol = 1e-9) r[1] < 0 & r[2] >= -tol & r[3] >= -tol

# effective goal weights (CH4 normalised to -1) of an index with information set `info`: b = P^-1 G a  =>  a = G^-1 P b
w_of <- function(o, info) {
  a <- drop(solve(G[info, info, drop = FALSE], P[info, info, drop = FALSE] %*% o$b))
  a <- a * -1 / a[1]; setNames(c(a, rep(NA, 3 - length(info))), TR) }

rows <- list()
add <- function(label, info, a, C = NULL) {
  o <- sh(G, P, info, a, C); w <- w_of(o, info)
  rows[[length(rows) + 1]] <<- data.frame(index = label, information = paste(TR[info], collapse = "+"),
    w_CH4 = w[1], w_MBW = w[2], w_CO2_per100 = w[3] * 100,
    b_CH4 = o$b[1], b_MBW = if (length(info) > 1) o$b[2] else NA, b_CO2 = if (length(info) > 2) o$b[3] else NA, dCH4 = o$resp[1], dMBW = o$resp[2], dCO2 = o$resp[3], r_IH = o$r_IH,
    in_region = in_region(o$resp)) }

# residual traits: CH4 regressed on MBW (and CO2), phenotypic and genetic coefficients
bP2 <- solve(P[2:3, 2:3], P[2:3, 1]); bG2 <- solve(G[2:3, 2:3], G[2:3, 1])
add("Ratio CH4/MBW (weight on MBW fixed by the means)", I2, a_ratio)
add("Residual on MBW, phenotypic beta", I2, a_res_P)
add("Residual on MBW, genetic beta", I2, a_res_G)
add("Residual on MBW+CO2, phenotypic betas", I3, c(-1, bP2))
add("Residual on MBW+CO2, genetic betas", I3, c(-1, bG2))

# best point inside the region for the 3-trait index: enumerate which constraints bind
cand <- list("none" = NULL, "MBW = 0" = Cm(2), "CO2 = 0" = Cm(3), "MBW = 0 and CO2 = 0" = Cm(2:3))
res <- lapply(names(cand), function(n) { o <- sh(G, P, I3, -unit(1), cand[[n]]); list(n = n, o = o, ok = in_region(o$resp)) })
cat("binding-constraint sets, CH4+MBW+CO2 information:\n")
for (r in res) cat(sprintf("  %-20s dCH4 %.3f dMBW %.3f dCO2 %.2f  in region: %s\n", r$n, r$o$resp[1], r$o$resp[2], r$o$resp[3], r$ok))
feas <- Filter(function(r) r$ok, res); best <- feas[[which.min(sapply(feas, function(r) r$o$resp[1]))]]
add(paste0("Best in region, CH4+MBW+CO2 information (binding: ", best$n, ")"), I3, -unit(1), cand[[best$n]])
add("Best in region, CH4+MBW information (binding: MBW = 0)", I2, -unit(1), Cm(2))
tab <- do.call(rbind, rows); rownames(tab) <- NULL
write.csv(tab, file.path(out_dir, "tri_region_weights_responses.csv"), row.names = FALSE)
cat("\n"); print(tab, digits = 3, row.names = FALSE)

# range of relative MBW weight (goal a = (-1, beta), CH4+MBW information) that lands in the region
bs <- seq(0, 3, 0.005); rb <- t(sapply(bs, function(b) sh(G, P, I2, c(-1, b, 0))$resp))
ok <- rb[, 1] < 0 & rb[, 2] >= 0 & rb[, 3] >= 0
cat("\nbeta range in region (CH4+MBW information): [", min(bs[ok]), ",", max(bs[ok]), "]; ratio beta =",
    round(mu["CH4"] / mu["MBW"], 3), "; genetic beta =", round(beta_G, 3), "; phenotypic beta =", round(beta_P, 3), "\n")
write.csv(data.frame(beta = bs, dCH4 = rb[, 1], dMBW = rb[, 2], dCO2 = rb[, 3], in_region = ok),
          file.path(out_dir, "tri_region_beta_scan.csv"), row.names = FALSE)

# figure: responses attainable by any linear index of CH4, MBW and CO2 (solid ellipsoid: intensity up to i = 1),
# favourable region shaded (no named strategies). Delta = t(chol(G P^-1 G)) z, z uniform in the unit ball.
set.seed(1); n <- 2e6; Mx <- G %*% solve(P) %*% G; Lm <- t(chol(Mx))
z <- matrix(rnorm(3 * n), 3); z <- sweep(z, 2, sqrt(colSums(z^2)), "/") * rep(runif(n)^(1/3), each = 3)
R <- t(Lm %*% z)
d <- data.frame(dCH4 = R[, 1], dMBW = R[, 2], dCO2 = R[, 3]); d$fav <- d$dCH4 < 0 & d$dMBW >= 0 & d$dCO2 >= 0
stopifnot(abs(max(-d$dCH4) - sqrt(Mx[1, 1])) < 0.02)
hull <- d[chull(d$dMBW, d$dCH4), ]; fh <- d[d$fav, ]; fh <- fh[chull(fh$dMBW, fh$dCH4), ]
g <- ggplot() + geom_polygon(data = hull, aes(dMBW, dCH4), fill = "grey92", colour = "grey55") +
  geom_polygon(data = fh, aes(dMBW, dCH4), fill = "#4daf4a", alpha = 0.55, colour = "#2b7a29") +
  geom_hline(yintercept = 0, linewidth = 0.3) + geom_vline(xintercept = 0, linewidth = 0.3) +
  labs(x = "Response in MBW (kg^0.75)", y = "Response in CH4 (g/d)",
       caption = "Grey: responses per generation (i = 1 or less) attainable by any linear index of CH4, MBW and CO2.\nGreen: CH4 decreases while MBW and CO2 do not.") +
  theme_bw()
ggsave(file.path(out_dir, "tri_favourable_region.png"), g, width = 6.5, height = 5, dpi = 200)
cat("\nfavourable region extent: dMBW", round(range(fh$dMBW), 3), "; dCH4", round(range(fh$dCH4), 3), "; share of attainable set:", round(mean(d$fav), 4), "\n")

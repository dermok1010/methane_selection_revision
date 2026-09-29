#!/usr/bin/env Rscript
# Simplified favourable-region analysis, recreating the original frontier figure (CH4 v MBW response, arc coloured by the
# correlated response of a third trait) with CO2 in place of ADG, then one table of how each goal construction does or does not reach it.
# Three-trait (CH4, MBW, CO2) information throughout; point estimates; i = 1 per generation.
# Usage (repo root): Rscript analysis/revision/selection_index/07_frontier_region_simple.R
suppressMessages({library(ggplot2)})
local({ f <- readLines("analysis/revision/selection_index/02_selection_index_trivariate.R")
        f <- f[seq_len(grep("^# ---- Table 1", f)[1] - 1)]; eval(parse(text = f), envir = globalenv()) })
out <- "analysis/revision/selection_index/results"
in_region <- function(r, tol = 1e-9) r[1] < 0 & r[2] >= -tol & r[3] >= -tol

# ---- frontier: goals with weight on CH4 and MBW only (CO2 weight 0); these trace the boundary of the projected response set ----
th <- seq(0, 2 * pi, length.out = 7201)
fr <- t(sapply(th, function(t) sh(G, P, I3, c(cos(t), sin(t), 0))$resp))
fr <- data.frame(ch4 = fr[, 1], mbw = fr[, 2], co2 = fr[, 3])
# efficient arc: walk the ellipse from the CH4-only point (largest cut) in the direction of increasing MBW until CH4 reaches 0
n <- nrow(fr); i0 <- which.min(fr$ch4); dir <- if (fr$mbw[(i0 %% n) + 1] > fr$mbw[i0]) 1 else -1
idx <- ((i0 - 1 + dir * (0:(n - 1))) %% n) + 1; run <- fr[idx, ]; stop_at <- which(run$ch4 > 0)[1] - 1
arc <- run[seq_len(stop_at), ]
stopifnot(all(diff(arc$mbw) >= -1e-9))
lr <- arc[arc$mbw >= 0, ]
top_mbw <- max(arc$mbw)
# favourable region = area inside the attainable ellipse with MBW >= 0 and CH4 < 0 (the whole region has CO2 >= 0 attainable; checked below)
ch4_at_0 <- approx(arc$mbw[arc$mbw < 0.05 & arc$mbw > -0.05], arc$ch4[arc$mbw < 0.05 & arc$mbw > -0.05], xout = 0)$y
poly <- rbind(c(0, 0), c(0, ch4_at_0), as.matrix(lr[lr$mbw > 0, c("mbw", "ch4")]), c(lr$mbw[which.max(lr$ch4)], 0))
poly <- data.frame(mbw = poly[, 1], ch4 = poly[, 2])
stopifnot(all(lr$co2 >= 0))                                       # CO2 response is non-negative along the whole favourable arc

lims <- range(arc$co2); lims_pad <- lims + c(-1, 1) * diff(lims) * 0.02
pal <- c("#8B0000", "#CC3300", "#FF6644", "#FAEBD7", "#88CC88", "#2E8B2E", "#145214")
vals <- scales::rescale(c(lims[1], lims[1] * 0.5, lims[1] * 0.1, 0, lims[2] * 0.1, lims[2] * 0.5, lims[2]), from = lims)
g <- ggplot() +
  geom_polygon(data = poly, aes(mbw, ch4), fill = "#4daf4a", alpha = 0.18, colour = NA) +
  geom_path(data = arc, aes(mbw, ch4, colour = co2), linewidth = 2.2, lineend = "round") +
  scale_colour_gradientn(colours = pal, values = vals, limits = lims, breaks = c(lims[1], 0, lims[2]),
                         labels = sprintf("%.0f", c(lims[1], 0, lims[2])), name = expression("CO"[2]*" correlated response (g day"^{-1}*")")) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60", linewidth = 0.35) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey60", linewidth = 0.35) +
  annotate("text", x = 0.17, y = -0.12, label = "Favourable region\nCH4 falls;\nMBW and CO2 do not", colour = "#1f5f1d", fontface = "bold", size = 3.4, hjust = 0.5) +
  labs(x = "Predicted response in metabolic body weight (kg^0.75)", y = expression("Predicted response in CH"[4]*" production (g day"^{-1}*")")) +
  guides(colour = guide_colourbar(barwidth = 18, barheight = 0.9, title.position = "top")) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", legend.title = element_text(size = 9), panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "grey93"))
ggsave(file.path(out, "tri_frontier_co2.png"), g, width = 8, height = 8, dpi = 300, bg = "white")
cat(sprintf("frontier: dMBW %.3f..%.3f; region corner points CH4 at MBW=0 %.3f, MBW at CH4=0 %.3f; CO2 along favourable arc %.1f..%.1f\n",
            min(arc$mbw), top_mbw, ch4_at_0, lr$mbw[which.max(lr$ch4)], min(lr$co2), max(lr$co2)))
write.csv(arc, file.path(out, "tri_frontier_co2_arc.csv"), row.names = FALSE)

# ---- constructions: each is a "methane term" R = CH4 - c1*MBW - c2*CO2 (its own fixed coefficients) plus optional weights on MBW and CO2 ----
bP <- solve(P[2:3, 2:3], P[2:3, 1]); bG <- solve(G[2:3, 2:3], G[2:3, 1])
cons <- list(
  "Three traits (CH4, MBW, CO2 as themselves)" = c(0, 0),
  "Genetic residual (CH4 on MBW + CO2)"        = unname(bG),
  "Phenotypic residual (CH4 on MBW + CO2)"     = unname(bP),
  "Ratio CH4 / MBW (linearised)"               = c(unname(mu["CH4"] / mu["MBW"]), 0),
  "Ratio CH4 / CO2 (linearised)"               = c(0, unname(mu["CH4"] / mu["CO2"])))
# reference in-region goal: largest methane cut with MBW response held at 0 (CO2 free), CH4 = -1 normalisation
o0 <- sh(G, P, I3, -unit(1), Cm(2)); stopifnot(in_region(o0$resp))
a0 <- drop(solve(G, P %*% o0$b)); a0 <- a0 * -1 / a0[1]
# region window in the MBW goal weight (CH4 = -1) at the reference CO2 goal weight
ws <- seq(-1, 3, 0.001); ok <- sapply(ws, function(m) in_region(sh(G, P, I3, c(-1, m, a0[3]))$resp)); win <- range(ws[ok])

rows <- lapply(names(cons), function(nm) {
  cc <- cons[[nm]]; Tm <- rbind(c(1, -cc), c(0, 1, 0), c(0, 0, 1)); Ti <- solve(Tm)
  aD <- c(-1, cc)                                                  # goal "as defined": weight only on the methane term R
  oD <- sh(G, P, I3, aD)
  aT <- drop(t(Ti) %*% a0); bT <- drop(t(Ti) %*% o0$b)            # reference in-region goal / index in this construction's coordinates
  data.frame(construction = nm, coef_MBW = cc[1], coef_CO2_per100 = cc[2] * 100,
    asdef_dCH4 = oD$resp[1], asdef_dMBW = oD$resp[2], asdef_dCO2 = oD$resp[3], asdef_r_IH = oD$r_IH, asdef_in_region = in_region(oD$resp),
    need_extra_MBW = aT[2], need_extra_CO2_per100 = aT[3] * 100, need_MBW_lo = win[1] - cc[1], need_MBW_hi = win[2] - cc[1],
    index_R = bT[1], index_MBW = bT[2], index_CO2 = bT[3], ref_dCH4 = o0$resp[1], ref_dMBW = o0$resp[2], ref_dCO2 = o0$resp[3])
})
tab <- do.call(rbind, rows); rownames(tab) <- NULL
write.csv(tab, file.path(out, "tri_frontier_table.csv"), row.names = FALSE)
cat(sprintf("\nreference in-region goal (CH4 = -1): MBW %.4f, CO2 %.5f per g/d (%.3f per 100); MBW window at that CO2 weight %.3f-%.3f\n", a0[2], a0[3], a0[3] * 100, win[1], win[2]))
print(t(signif(tab[, -1], 4)))

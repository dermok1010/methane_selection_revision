#!/usr/bin/env Rscript
# Response frontier for the CH4 x MBW index (trivariate parameters): all goal directions on the grid,
# their convex hull, and the named strategies. Reads outputs of 02_selection_index_trivariate.R.
# Usage (repo root): Rscript analysis/revision/selection_index/03_frontier_figure.R
library(ggplot2)
d <- "analysis/revision/selection_index/results"
grid <- read.csv(file.path(d, "tri_index_response_grid.csv")); pts <- read.csv(file.path(d, "tri_index_responses_point.csv"))
pts <- pts[pts$strategy %in% c("Ratio CH4/MBW", "Residual methane (phenotypic beta)", "CH4 goal, MBW response held at 0", "CH4 only goal, no MBW constraint"), ]
pts$strategy <- factor(pts$strategy)
panel <- function(y, ylab) {
  g <- data.frame(x = grid$dMBW, y = grid[[y]]); h <- g[chull(g$x, g$y), ]
  p <- data.frame(x = pts$dMBW, y = pts[[y]], strategy = pts$strategy)
  list(hull = cbind(h, panel = ylab), pts = cbind(p, panel = ylab))
}
a <- panel("dCH4", "CH4 (g/d)"); b <- panel("dCO2", "CO2 (g/d)")
hull <- rbind(a$hull, b$hull); pp <- rbind(a$pts, b$pts)
g <- ggplot() + geom_polygon(data = hull, aes(x, y), fill = "grey90", colour = "grey50") +
  geom_hline(yintercept = 0, linewidth = 0.2) + geom_vline(xintercept = 0, linewidth = 0.2) +
  geom_point(data = pp, aes(x, y, colour = strategy, shape = strategy), size = 3) +
  facet_wrap(~panel, scales = "free_y") +
  labs(x = "Response in MBW (kg^0.75)", y = "Response per generation at i = 1", colour = NULL, shape = NULL) +
  theme_bw() + theme(legend.position = "bottom", legend.direction = "vertical")
ggsave(file.path(d, "tri_response_frontier.png"), g, width = 8, height = 5, dpi = 200)

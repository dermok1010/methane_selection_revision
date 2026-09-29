#!/usr/bin/env Rscript
# Figures and tables for the favourable-region framing, three-trait (CH4, MBW, CO2) information throughout.
# Same G/P as 02_selection_index_trivariate.R (point estimates, i = 1 per generation; i = 1.7 and per-year columns added).
# Goals are written in three coordinate systems that give identical responses: CH4 (raw traits), phenotypic residual
# (R_P = CH4 - bP1*MBW - bP2*CO2) and genetic residual (R_G = CH4 - bG1*MBW - bG2*CO2), each with MBW and CO2.
# Usage (repo root): Rscript analysis/revision/selection_index/06_region_figures_tables.R
suppressMessages(library(ggplot2))
local({ f <- readLines("analysis/revision/selection_index/02_selection_index_trivariate.R")
        f <- f[seq_len(grep("^# ---- Table 1", f)[1] - 1)]; eval(parse(text = f), envir = globalenv()) })
out <- "analysis/revision/selection_index/results"
I_REAL <- 1.7; GEN <- 2.8
in_region <- function(r, tol = 1e-9) r[1] < 0 & r[2] >= -tol & r[3] >= -tol
bP <- solve(P[2:3, 2:3], P[2:3, 1]); bG <- solve(G[2:3, 2:3], G[2:3, 1])
Tm <- list(CH4 = diag(3),
           phenotypic = rbind(c(1, -bP), c(0, 1, 0), c(0, 0, 1)),
           genetic    = rbind(c(1, -bG), c(0, 1, 0), c(0, 0, 1)))

# one goal a (CH4 coordinates) -> weights and responses in every coordinate system
describe <- function(label, a, note = "") {
  o <- sh(G, P, I3, a); a <- unname(a)
  r_IH <- sqrt(drop(t(o$b) %*% G %*% a) / drop(t(a) %*% G %*% a))
  d <- data.frame(construction = label, note = note, in_region = in_region(o$resp),
                  dCH4 = o$resp[1], dMBW = o$resp[2], dCO2 = o$resp[3],
                  dCH4_i1.7 = o$resp[1] * I_REAL, dMBW_i1.7 = o$resp[2] * I_REAL, dCO2_i1.7 = o$resp[3] * I_REAL,
                  dCH4_per_yr = o$resp[1] * I_REAL / GEN, dMBW_per_yr = o$resp[2] * I_REAL / GEN, dCO2_per_yr = o$resp[3] * I_REAL / GEN,
                  r_IH = r_IH)
  for (cs in names(Tm)) {           # goal a_T = T^-T a ; index b_T = P_T^-1 G_T a_T (= T^-T b)
    Ti <- solve(Tm[[cs]]); aT <- drop(t(Ti) %*% a); PT <- Tm[[cs]] %*% P %*% t(Tm[[cs]]); GT <- Tm[[cs]] %*% G %*% t(Tm[[cs]])
    bT <- drop(solve(PT, GT %*% aT)); stopifnot(max(abs(bT - drop(t(Ti) %*% o$b))) < 1e-9)
    first <- if (cs == "CH4") "CH4" else paste0("R_", substr(cs, 1, 1))
    nm <- c(first, "MBW", "CO2")
    d[paste0("goal_", cs, "_", nm)] <- aT * c(1, 1, 100)   # CO2 goal weight per 100 g/d
    d[paste0("index_", cs, "_", nm)] <- bT
  }
  d
}
names(bP) <- names(bG) <- c("MBW", "CO2")
w <- function(m, c = 0) c(-1, m, c)                                  # goal in CH4 coordinates, CH4 = -1, CO2 weight per g/d

# ---------------- Table 1: parameters ----------------
tri <- read.csv("analysis/revision/asreml_pipeline/results/trivariate_summary.csv", stringsAsFactors = FALSE)
h2 <- diag(G) / diag(P)
par_tab <- data.frame(trait = TR, mean = mu, VA = diag(G), VP = diag(P), h2 = h2)
par_tab$r_g_CH4 <- cov2cor(G)[, 1]; par_tab$r_g_MBW <- cov2cor(G)[, 2]; par_tab$r_g_CO2 <- cov2cor(G)[, 3]
par_tab$r_p_CH4 <- cov2cor(P)[, 1]; par_tab$r_p_MBW <- cov2cor(P)[, 2]; par_tab$r_p_CO2 <- cov2cor(P)[, 3]
write.csv(par_tab, file.path(out, "tri_table1_parameters.csv"), row.names = FALSE)
resid_tab <- do.call(rbind, lapply(c("phenotypic", "genetic"), function(cs) {
  T <- Tm[[cs]]; GT <- T %*% G %*% t(T); PT <- T %*% P %*% t(T); b <- if (cs == "phenotypic") bP else bG
  data.frame(residual = cs, coef_MBW = b[1], coef_CO2_per100 = b[2] * 100, VA = GT[1, 1], VP = PT[1, 1], h2 = GT[1, 1] / PT[1, 1],
             rg_with_CH4 = (T %*% G)[1, 1] / sqrt(GT[1, 1] * G[1, 1]),
             rg_with_MBW = cov2cor(GT)[1, 2], rg_with_CO2 = cov2cor(GT)[1, 3],
             rp_with_MBW = cov2cor(PT)[1, 2], rp_with_CO2 = cov2cor(PT)[1, 3]) }))
write.csv(resid_tab, file.path(out, "tri_table1b_residual_traits.csv"), row.names = FALSE)

# ---------------- Table 2: constructions as defined (zero extra weight) ----------------
t2 <- rbind(
  describe("Free three-trait index, CH4 only in the goal", w(0), "goal = -CH4"),
  describe("Ratio CH4/MBW (linearised)", a_ratio / -a_ratio[1], "MBW weight fixed = mean CH4 / mean MBW"),
  describe("Phenotypic residual on MBW", c(-1, beta_P, 0), "R = CH4 - bP*MBW, goal -R"),
  describe("Genetic residual on MBW", c(-1, beta_G, 0), "R = CH4 - bG*MBW, goal -R"),
  describe("Phenotypic residual on MBW + CO2", c(-1, bP), "goal -R"),
  describe("Genetic residual on MBW + CO2", c(-1, bG), "goal -R"))
write.csv(t2, file.path(out, "tri_table2_constructions_as_defined.csv"), row.names = FALSE)

# ---------------- Table 3: the weight ladder inside the region ----------------
o0 <- sh(G, P, I3, -unit(1), Cm(2)); a0 <- drop(solve(G, P %*% o0$b)); a0 <- a0 * -1 / a0[1]
t3 <- do.call(rbind, c(list(describe("Largest CH4 cut with MBW held at 0 (restricted index)", a0, "boundary point of the region")),
  lapply(c(0.86, 0.90, 0.95, 1.00, 1.05, 1.10), function(m) describe(sprintf("Goal weight on MBW %.2f, CO2 0", m), w(m), "ladder"))))
write.csv(t3, file.path(out, "tri_table3_weight_ladder.csv"), row.names = FALSE)

# ---------------- goal-weight scan (CH4 coordinates) ----------------
g <- expand.grid(w_MBW = seq(-0.5, 3, 0.005), w_CO2 = seq(-3, 3, 0.02) / 100)
R <- t(mapply(function(m, c) sh(G, P, I3, w(m, c))$resp, g$w_MBW, g$w_CO2))
g$dCH4 <- R[, 1]; g$dMBW <- R[, 2]; g$dCO2 <- R[, 3]; g$in_region <- R[, 1] < 0 & R[, 2] >= 0 & R[, 3] >= 0
write.csv(g[g$in_region, ], file.path(out, "tri_region_goal_weight_cells_in_region.csv"), row.names = FALSE)   # full grid not stored (15 MB)
# ---------------- Table 4: extra weight needed, by CO2 weight ----------------
rr <- g[g$in_region, ]; cs_vals <- round(seq(-1.2, 1.2, 0.2), 2)
t4 <- do.call(rbind, lapply(cs_vals, function(v) { s <- rr[abs(rr$w_CO2 * 100 - v) < 1e-9, ]
  lo <- if (nrow(s)) min(s$w_MBW) else NA; hi <- if (nrow(s)) max(s$w_MBW) else NA
  data.frame(goal_w_CO2_per100 = v, goal_w_MBW_min = lo, goal_w_MBW_max = hi,
             extra_MBW_phenotypic_min = lo - bP["MBW"], extra_MBW_phenotypic_max = hi - bP["MBW"],
             extra_CO2_phenotypic_per100 = v - bP["CO2"] * 100,
             extra_MBW_genetic_min = lo - bG["MBW"], extra_MBW_genetic_max = hi - bG["MBW"],
             extra_CO2_genetic_per100 = v - bG["CO2"] * 100) }))
rownames(t4) <- NULL; write.csv(t4, file.path(out, "tri_table4_weight_windows.csv"), row.names = FALSE)

# ---------------- Figure 1: the favourable region in response space (three projections, no strategies) ----------------
set.seed(1); n <- 2e6; Mx <- G %*% solve(P) %*% G; Lm <- t(chol(Mx))
z <- matrix(rnorm(3 * n), 3); z <- sweep(z, 2, sqrt(colSums(z^2)), "/") * rep(runif(n)^(1/3), each = 3)
S <- t(Lm %*% z); d <- data.frame(dCH4 = S[, 1], dMBW = S[, 2], dCO2 = S[, 3]); d$fav <- d$dCH4 < 0 & d$dMBW >= 0 & d$dCO2 >= 0
stopifnot(abs(max(-d$dCH4) - sqrt(Mx[1, 1])) < 0.02)
proj <- function(xv, yv, lab) { h <- d[chull(d[[xv]], d[[yv]]), ]; f <- d[d$fav, ]; f <- f[chull(f[[xv]], f[[yv]]), ]
  rbind(data.frame(x = h[[xv]], y = h[[yv]], set = "all", panel = lab), data.frame(x = f[[xv]], y = f[[yv]], set = "fav", panel = lab)) }
pj <- rbind(proj("dMBW", "dCH4", "A. CH4 v MBW"), proj("dCO2", "dCH4", "B. CH4 v CO2"), proj("dCO2", "dMBW", "C. MBW v CO2"))
pj$panel <- factor(pj$panel)
gg <- ggplot() +
  geom_polygon(data = pj[pj$set == "all", ], aes(x, y), fill = "grey92", colour = "grey55") +
  geom_polygon(data = pj[pj$set == "fav", ], aes(x, y), fill = "#4daf4a", alpha = 0.6, colour = "#2b7a29") +
  geom_hline(yintercept = 0, linewidth = 0.3) + geom_vline(xintercept = 0, linewidth = 0.3) +
  facet_wrap(~panel, scales = "free") + theme_bw() +
  labs(x = "Response in the horizontal-axis trait", y = "Response in the vertical-axis trait",
       caption = paste0("Grey: responses per generation (i = 1 or less) attainable by any linear index of CH4 (g/d), MBW (kg^0.75) and CO2 (g/d).\n",
                        "Green: CH4 decreases while MBW and CO2 do not (", round(100 * mean(d$fav), 1), "% of the attainable set). Projections of one 3-D region."))
ggsave(file.path(out, "tri_fig1_favourable_region_projections.png"), gg, width = 12, height = 4.6, dpi = 200)
fav_ext <- data.frame(quantity = c("dCH4 min (largest cut)", "dMBW max", "dCO2 max", "share of attainable set"),
  value = c(min(d$dCH4[d$fav]), max(d$dMBW[d$fav]), max(d$dCO2[d$fav]), mean(d$fav)))
write.csv(fav_ext, file.path(out, "tri_fig1_region_extent.csv"), row.names = FALSE)

# ---------------- Figure 2: the region in goal-weight space ----------------
wrap <- function(x, n = 110) paste(strwrap(x, n), collapse = "\n")
pts <- data.frame(label = c("Ratio (linearised)", "Phenotypic residual, MBW", "Genetic residual, MBW", "Phenotypic residual, MBW + CO2",
                            "Genetic residual, MBW + CO2", "Reference in-region goal (MBW held at 0)"),
                  w_MBW = c(unname(a_ratio[2] / -a_ratio[1]), beta_P, beta_G, bP["MBW"], bG["MBW"], a0[2]),
                  w_CO2 = c(0, 0, 0, bP["CO2"], bG["CO2"], a0[3]) * 100)
pts$label <- factor(pts$label, levels = pts$label)
g2 <- g; g2$w_CO2 <- g2$w_CO2 * 100
g2$cat <- ifelse(g2$in_region, "In region", ifelse(g2$dCH4 < 0 & g2$dMBW >= 0, "CH4 down, MBW ok, CO2 falls",
          ifelse(g2$dCH4 < 0 & g2$dCO2 >= 0, "CH4 down, CO2 ok, MBW falls", "Outside (MBW and CO2 fall, or CH4 up)")))
f2 <- ggplot(g2, aes(w_MBW, w_CO2)) + geom_raster(aes(fill = cat)) +
  scale_fill_manual(values = c("In region" = "#4daf4a", "CH4 down, MBW ok, CO2 falls" = "#fdd0a2", "CH4 down, CO2 ok, MBW falls" = "#c6dbef",
                               "Outside (MBW and CO2 fall, or CH4 up)" = "grey90"), name = "Response of the goal") +
  geom_point(data = pts, aes(shape = label, colour = label), size = 3.4, stroke = 1.1) +
  scale_shape_manual(values = c(15, 16, 1, 17, 2, 4), name = "Goal weights of") +
  scale_colour_manual(values = c("#d95f02", "#7570b3", "#7570b3", "#e7298a", "#e7298a", "black"), name = "Goal weights of") +
  coord_cartesian(xlim = c(0, 1.5), ylim = c(-1, 1.5), expand = FALSE) + theme_bw() + theme(plot.caption = element_text(hjust = 0), legend.box = "vertical") +
  labs(x = "Goal weight on MBW relative to CH4 (CH4 = -1)", y = "Goal weight on CO2 (per 100 g/d)",
       caption = wrap("Each cell is a breeding goal -CH4 + w_MBW x MBW + w_CO2 x CO2 evaluated with a three-trait Smith-Hazel index (i = 1); colour shows where its response falls. A residual trait used on its own sits at its own regression coefficients (open/filled symbols). In residual coordinates the goal has extra weights on MBW and CO2 equal to the horizontal and vertical distance from that symbol."))
ggsave(file.path(out, "tri_fig2_goal_weight_map.png"), f2, width = 10.5, height = 6, dpi = 200)

# ---------------- Figure 3: responses along the MBW goal weight (CO2 goal weight 0) ----------------
prof <- g[abs(g$w_CO2) < 1e-12 & g$w_MBW >= -0.5 & g$w_MBW <= 3, ]
lg <- rbind(data.frame(w_MBW = prof$w_MBW, resp = prof$dCH4, trait = "CH4 (g/d)"), data.frame(w_MBW = prof$w_MBW, resp = prof$dMBW, trait = "MBW (kg^0.75)"),
            data.frame(w_MBW = prof$w_MBW, resp = prof$dCO2, trait = "CO2 (g/d)"))
win <- range(prof$w_MBW[prof$in_region])
vl <- data.frame(w = c(beta_P, unname(a_ratio[2] / -a_ratio[1]), beta_G), lab = c("Phenotypic residual (bP)", "Ratio (mean CH4 / mean MBW)", "Genetic residual (bG)"))
f3 <- ggplot(lg, aes(w_MBW, resp)) + annotate("rect", xmin = win[1], xmax = win[2], ymin = -Inf, ymax = Inf, fill = "#4daf4a", alpha = 0.25) +
  geom_hline(yintercept = 0, linewidth = 0.3) + geom_line() + geom_vline(data = vl, aes(xintercept = w, colour = lab), linetype = 2, linewidth = 0.7) +
  scale_colour_manual(values = c("#7570b3", "#d95f02", "#1b9e77"), name = "Weight imposed on MBW by") + guides(colour = guide_legend(nrow = 3, title.position = "top")) + coord_cartesian(xlim = c(0, 2), expand = FALSE) +
  facet_wrap(~trait, scales = "free_y", ncol = 1, strip.position = "left") + theme_bw() + theme(strip.placement = "outside", plot.caption = element_text(hjust = 0), legend.position = "bottom") +
  labs(x = "Goal weight on MBW relative to CH4 (CO2 goal weight 0; three-trait information)", y = "Response per generation (i = 1)",
       caption = wrap(sprintf("Green band: goal weights whose response is in the favourable region (%.3f to %.3f); the response of MBW and CO2 must be at or above zero and of CH4 below zero.", win[1], win[2]), 100))
ggsave(file.path(out, "tri_fig3_response_by_mbw_weight.png"), f3, width = 7.5, height = 8.5, dpi = 200)
write.csv(prof, file.path(out, "tri_fig3_profile.csv"), row.names = FALSE)

# ---------------- markdown of all tables ----------------
md <- function(df, dg = 3) {
  f <- function(x) if (is.numeric(x)) { x[!is.na(x) & abs(x) < 1e-9] <- 0; ifelse(is.na(x), "", formatC(signif(x, dg + 1), format = "fg", digits = dg + 1)) } else as.character(x)
  c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
    vapply(seq_len(nrow(df)), function(i) paste0("| ", paste(vapply(df[i, ], f, ""), collapse = " | "), " |"), ""))
}
L <- c("# Favourable-region tables (i = 1 per generation unless a column says otherwise; three-trait information)", "",
  "CO2 goal weights and CO2 residual coefficients are per 100 g/d; index weights are per record unit. Coordinates: CH4 = raw traits;",
  "phenotypic / genetic = residual R = CH4 - beta_MBW*MBW - beta_CO2*CO2 with MBW and CO2 alongside. Responses are identical in all coordinate systems.", "",
  "## Table 1. Genetic parameters (trivariate model) and residual traits", "", md(par_tab), "", md(resid_tab), "",
  "## Table 2. Constructions as defined (no additional weight on MBW/CO2)", "", md(t2[, c("construction", "in_region", "dCH4", "dMBW", "dCO2", "r_IH", "goal_CH4_MBW", "goal_CH4_CO2")]), "",
  "## Table 3. Weight ladder inside the region: goals and index weights in each coordinate system", "",
  md(t3[, c("construction", "in_region", "dCH4", "dMBW", "dCO2", "dCH4_i1.7", "dMBW_i1.7", "dCO2_i1.7", "dCH4_per_yr", "dMBW_per_yr", "dCO2_per_yr", "r_IH")]), "",
  md(t3[, c("construction", grep("^goal_", names(t3), value = TRUE))]), "", md(t3[, c("construction", grep("^index_", names(t3), value = TRUE))]), "",
  "## Table 4. Weight windows: goal weight on MBW that reaches the region for a given goal weight on CO2", "", md(t4), "")
writeLines(L, file.path(out, "tri_region_tables.md"))
cat("region extent:\n"); print(fav_ext)
cat("\nTable 2\n"); print(t2[, c("construction", "in_region", "dCH4", "dMBW", "dCO2", "r_IH")], digits = 3)
cat("\nTable 3\n"); print(t3[, c("construction", "in_region", "dCH4", "dMBW", "dCO2")], digits = 3)
cat("\nTable 4\n"); print(round(t4, 3))

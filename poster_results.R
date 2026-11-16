# Visualize the six reported model scores in Figure 6 of the
# team's Fall 2024 poster.
# Rscript poster_results.R outputs
library(ggplot2)
args <- commandArgs(trailingOnly = TRUE); out <- if (length(args)) args[1] else "outputs"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
scores <- data.frame(
  approach = rep(c("Variable selection", "Text mining", "Predictive modeling"), each = 2),
  model = c("M10", "M17", "M3", "M5", "M7", "M8"),
  kaggle_score = c(.821, .799, .812, .815, .889, .888))
scores$approach <- factor(scores$approach, levels = c("Variable selection", "Text mining", "Predictive modeling"))
write.csv(scores, file.path(out, "poster-model-comparison.csv"), row.names = FALSE)
ggsave(file.path(out, "taps-comparison.svg"), ggplot(scores, aes(model, kaggle_score, fill = approach)) +
  geom_col(width = .6) + geom_text(aes(label = sprintf("%.3f", kaggle_score)), vjust = -.5, size = 4) +
  facet_grid(~ approach, scales = "free_x", space = "free_x") +
  scale_fill_manual(values = c("#a2a69c", "#b38c50", "#2a5663")) + scale_y_continuous(limits = c(0, 1)) +
  labs(title = "Comparing the approaches", x = "Model identifier in original poster", y = "Reported Kaggle score",
    caption = "Transcribed from the team's 2024 poster (Figure 6). No new model training or independent replication.") +
  theme_minimal(base_size = 12) + theme(legend.position = "none", panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#faf9f6", colour = NA)), width = 9, height = 5, device = grDevices::svg)

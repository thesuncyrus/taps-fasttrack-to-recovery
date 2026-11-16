args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "outputs"
d <- read.csv(file.path(out, "test-metrics.csv"))
svg(file.path(out, "computed-model-comparison.svg"), width = 12, height = 7)
par(mar = c(12, 4, 3, 1))
barplot(d$macro_f1, names.arg = d$model, las = 2, ylim = c(0, 1),
        col = ifelse(d$selected_by_cv, "#116466", "#86b3b4"),
        ylab = "Held-out macro F1", main = "Local reconstructed evaluation")
dev.off()

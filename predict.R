source("pipeline.R")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) stop("Usage: Rscript predict.R model.rds test.csv submission.csv")
d <- read_surveys(args[2], labelled = FALSE)
bundle <- readRDS(args[1])
p <- score_bundle(bundle, d)
dir.create(dirname(args[3]), recursive = TRUE, showWarnings = FALSE)
write.csv(data.frame(Id = d$Id, Prediction = stage_levels[max.col(p, ties.method = "first")]),
          args[3], row.names = FALSE)
# Confirm the competition's required target header before submitting externally.

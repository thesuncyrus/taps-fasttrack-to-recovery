# Training-only descriptive summaries. Text counts stay local in ignored outputs.
source("pipeline.R")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Usage: Rscript eda.R examples.csv outputs [target-column]")
d <- read_surveys(args[1], if (length(args) > 2) args[3] else "y")
out <- args[2]; dir.create(out, recursive = TRUE, showWarnings = FALSE)
s <- split_surveys(d$y); tr <- d[s$train, ]
write.csv(as.data.frame(table(stage = tr$y)), file.path(out, "training-stage-counts.csv"), row.names = FALSE)
question_tables <- lapply(paste0("q", 1:20), function(nm)
  cbind(question = nm, as.data.frame(table(answer = tr[[nm]], stage = tr$y, useNA = "ifany"))))
write.csv(do.call(rbind, question_tables), file.path(out, "training-question-profiles.csv"), row.names = FALSE)
terms <- survey_tokens(tr)
counts <- lapply(stage_levels, function(stage) {
  freq <- sort(table(unlist(terms[tr$y == stage], use.names = FALSE)), decreasing = TRUE)
  data.frame(stage = stage, term = names(freq), count = as.integer(freq))
})
write.csv(do.call(rbind, counts), file.path(out, "private-training-token-counts.csv"), row.names = FALSE)
svg(file.path(out, "training-stage-counts.svg"), width = 8, height = 5)
barplot(table(tr$y), col = "#116466", xlab = "Stage label", ylab = "Training responses",
        main = "Stage distribution in the training partition")
dev.off()

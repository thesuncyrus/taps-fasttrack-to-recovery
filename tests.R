source("pipeline.R")
fails <- function(x) inherits(tryCatch({force(x); NULL}, error = identity), "error")
set.seed(91)
n <- 180L
d <- data.frame(Id = paste0("synthetic-", seq_len(n)))
for (j in 1:22) d[[paste0("q", j)]] <- if (j <= 2) sample(letters[1:4], n, TRUE) else
  if (j <= 6) sample(0:2, n, TRUE) else if (j <= 8) sample(0:4, n, TRUE) else
  if (j <= 20) sample(0:3, n, TRUE) else sample(c("family support grief", "familia ayuda esperanza", "new community purpose"), n, TRUE)
d$y <- factor(rep(stage_levels, each = n/6), levels = stage_levels)
d$q3[1] <- NA_real_
csv <- tempfile(fileext = ".csv"); write.csv(d, csv, row.names = FALSE)
parsed <- read_surveys(csv)
stopifnot(nrow(parsed) == n, identical(levels(parsed$y), stage_levels))
bad <- d; bad$q3[1] <- 99; write.csv(bad, csv, row.names = FALSE)
stopifnot(fails(read_surveys(csv)))
bad <- d; bad$Id[1] <- bad$Id[2]; write.csv(bad, csv, row.names = FALSE)
stopifnot(fails(read_surveys(csv)))
s <- split_surveys(d$y)
stopifnot(!length(intersect(s$train, s$test)), length(s$train) + length(s$test) == n)
fold <- make_folds(d$y[s$train]); stopifnot(all(table(fold, d$y[s$train]) > 0))
tr <- d[s$train, ]; te <- d[s$test, ]; te$q21 <- "heldoutsecret"
enc <- fit_encoder(tr, "combined")
stopifnot(!any(grepl("heldoutsecret", enc$vocabulary)))
te$q1 <- "unseen category"; te$q3 <- NA_real_
x <- transform_encoder(te, enc)
stopifnot(all(is.finite(as.matrix(x))), identical(names(x), enc$keep))
p <- diag(6); m <- multiclass_metrics(factor(stage_levels, levels=stage_levels), p)
stopifnot(m$summary["accuracy"] == 1, m$summary["macro_f1"] == 1)
wrong <- p[, 6:1]; stopifnot(multiclass_metrics(stage_levels, wrong)$summary["accuracy"] == 0)
# Full synthetic-data integration: all feature routes, folds, classifiers and exports.
# These scores test code execution only and are never published as research results.
out <- tempfile("taps-synthetic-")
scores <- run_experiment(d, out, trees = 15, max_terms = 40)
stopifnot(nrow(scores) == 10, sum(scores$selected_by_cv) == 1,
          all(is.finite(scores$accuracy)), all(scores$accuracy >= 0 & scores$accuracy <= 1))
bundle <- readRDS(file.path(out, "evaluation-model.rds"))
stopifnot(identical(dim(score_bundle(bundle, d[1, ])), c(1L, 6L)))
write.csv(d, csv, row.names = FALSE)
rscript <- file.path(R.home("bin"), "Rscript")
stopifnot(system2(rscript, shQuote(c("eda.R", csv, out))) == 0,
          system2(rscript, shQuote(c("plot.R", out))) == 0,
          system2(rscript, shQuote(c("predict.R", file.path(out, "evaluation-model.rds"), csv,
                                      file.path(out, "submission.csv")))) == 0)
submitted <- read.csv(file.path(out, "submission.csv"))
stopifnot(identical(submitted$Id, d$Id), nrow(submitted) == n,
          file.exists(file.path(out, "computed-model-comparison.svg")))
unlink(c(csv, out), recursive = TRUE)
cat("Passed: input contract, split isolation, fold coverage, train-only vocabulary/schema, metrics, nine model pipelines, serialization and one-row inference.\n")

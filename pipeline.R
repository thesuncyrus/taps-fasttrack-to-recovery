# Runnable reconstruction based on the retained survey schema and model families.
# Historical Kaggle scores are never read by this pipeline.
stage_levels <- as.character(1:6)
question_names <- paste0("q", 1:22)

read_surveys <- function(path, target = "y", labelled = TRUE) {
  d <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE,
                na.strings = c("", "NA"), fileEncoding = "UTF-8")
  if (!all(c("Id", question_names) %in% names(d)))
    stop("Required columns: Id, q1 through q22, and the configured target for training.")
  if (anyNA(d$Id) || anyDuplicated(d$Id)) stop("Id must be complete and unique.")
  for (nm in c("q1", "q2", "q21", "q22")) {
    d[[nm]] <- trimws(as.character(d[[nm]]))
    d[[nm]][!is.na(d[[nm]]) & !nzchar(d[[nm]])] <- NA_character_
  }
  for (j in 3:20) {
    nm <- paste0("q", j); raw <- d[[nm]]
    value <- suppressWarnings(as.numeric(raw))
    upper <- if (j <= 6) 2 else if (j <= 8) 4 else 3
    if (any(!is.na(raw) & (is.na(value) | !is.finite(value) |
               value != floor(value) | value < 0 | value > upper)))
      stop(paste("Invalid ordinal response in", nm))
    d[[nm]] <- value
  }
  if (labelled) {
    if (!target %in% names(d)) stop("Target column missing; set --target to its exact name.")
    if (anyNA(d[[target]]) || any(!as.character(d[[target]]) %in% stage_levels))
      stop("Target must contain only stages 1 through 6.")
    d$y <- factor(d[[target]], levels = stage_levels)
  }
  d
}

split_surveys <- function(y, fraction = .8, seed = 2024L) {
  if (!is.finite(fraction) || fraction <= 0 || fraction >= 1) stop("Invalid split fraction.")
  if (any(table(factor(y, levels = stage_levels)) < 5))
    stop("At least five labelled responses per stage are required.")
  set.seed(seed)
  tr <- sort(unlist(lapply(split(seq_along(y), y), function(ids)
    ids[sample.int(length(ids), floor(length(ids) * fraction))]), use.names = FALSE))
  list(train = tr, test = setdiff(seq_along(y), tr))
}

make_folds <- function(y, k = 3L, seed = 2024L) {
  if (k < 2 || any(table(y) < k)) stop("Insufficient class counts for CV.")
  set.seed(seed); fold <- integer(length(y))
  for (ids in split(seq_along(y), y)) {
    shuffled <- ids[sample.int(length(ids))]
    fold[shuffled] <- rep(seq_len(k), length.out = length(ids))
  }
  fold
}

# Local bilingual tokenization; no survey text is sent to a translation service.
# Preserve accents and question identity. The short stop list is explicit and reviewable.
stop_words <- strsplit(paste(
  "a an the and or but to of in on for with from is are was were be been being",
  "i me my we our you your he she it they them this that these those not as at",
  "el la los las un una unos unas y o de del en por para con sin que es son",
  "fue era ser yo mi mis tu sus su se lo al como pero esta este estoy"), " ")[[1]]
tokens <- function(x, prefix) {
  x[is.na(x)] <- ""
  lapply(strsplit(tolower(enc2utf8(x)), "[^\\p{L}]+", perl = TRUE), function(v) {
    v <- v[nchar(v) >= 2 & !v %in% stop_words]
    paste0(prefix, v)
  })
}
survey_tokens <- function(d) Map(c, tokens(d$q21, "q21:"), tokens(d$q22, "q22:"))

fit_encoder <- function(d, mode = "structured", max_terms = 1000L, min_df = 2L) {
  if (!mode %in% c("structured", "text", "combined")) stop("Unknown feature mode.")
  enc <- list(mode = mode)
  if (mode != "text") {
    nums <- paste0("q", 3:20)
    enc$median <- vapply(d[nums], function(v) if (all(is.na(v))) 0 else median(v, na.rm = TRUE), 0.)
    enc$levels <- lapply(d[c("q1", "q2")], function(v)
      sort(unique(c(v[!is.na(v)], "__MISSING__", "__OTHER__"))))
  }
  if (mode != "structured") {
    docs <- survey_tokens(d)
    freq <- table(unlist(lapply(docs, unique), use.names = FALSE))
    freq <- freq[freq >= min_df]
    freq <- freq[order(-as.numeric(freq), names(freq))]
    freq <- head(freq, max_terms)
    if (length(freq) < 2) stop("Fewer than two usable training text terms.")
    enc$vocabulary <- names(freq)
    enc$idf <- log((1 + nrow(d)) / (1 + as.numeric(freq))) + 1
  }
  x <- transform_encoder(d, enc, scale = FALSE)
  # Remove constants using only the current training fold.
  enc$keep <- names(x)[vapply(x, function(v) sd(v) > 0, TRUE)]
  if (length(enc$keep) < 2) stop("Fewer than two varying predictors.")
  enc$center <- vapply(x[enc$keep], mean, 0.)
  enc$spread <- vapply(x[enc$keep], sd, 0.)
  enc
}

transform_encoder <- function(d, enc, scale = TRUE) {
  blocks <- list()
  if (enc$mode != "text") {
    x <- d[paste0("q", 3:20)]
    for (nm in names(x)) x[[nm]][is.na(x[[nm]])] <- enc$median[[nm]]
    for (nm in c("q1", "q2")) {
      v <- as.character(d[[nm]]); v[is.na(v)] <- "__MISSING__"
      v[!v %in% enc$levels[[nm]]] <- "__OTHER__"
      for (i in seq_along(enc$levels[[nm]]))
        x[[paste0(nm, "_", i)]] <- as.numeric(v == enc$levels[[nm]][i])
    }
    blocks[[1]] <- x
  }
  if (enc$mode != "structured") {
    docs <- survey_tokens(d)
    mat <- matrix(0, nrow(d), length(enc$vocabulary))
    for (i in seq_along(docs)) {
      idx <- match(docs[[i]], enc$vocabulary); idx <- idx[!is.na(idx)]
      if (length(idx)) mat[i, ] <- tabulate(idx, nbins = ncol(mat))
    }
    mat <- log1p(mat) * rep(enc$idf, each = nrow(mat))
    norm <- sqrt(rowSums(mat^2)); norm[norm == 0] <- 1
    mat <- mat / norm
    colnames(mat) <- paste0("term_", seq_len(ncol(mat)))
    blocks[[length(blocks) + 1]] <- as.data.frame(mat)
  }
  x <- do.call(cbind, blocks)
  if (scale) {
    x <- x[, enc$keep, drop = FALSE]
    x <- as.data.frame(sweep(sweep(as.matrix(x), 2, enc$center, "-"), 2, enc$spread, "/"))
  }
  if (any(!is.finite(as.matrix(x)))) stop("Non-finite encoded features.")
  x
}

fit_classifier <- function(x, y, method, seed, trees = 500L) {
  set.seed(seed)
  switch(method,
    forest = randomForest::randomForest(x, y, ntree = trees,
                 mtry = max(1L, floor(sqrt(ncol(x)))), importance = TRUE),
    tree = rpart::rpart(y ~ ., data = data.frame(y = y, x), method = "class",
                       control = rpart::rpart.control(cp = .01, minsplit = 10)),
    multinomial = glmnet::glmnet(as.matrix(x), y, family = "multinomial",
                     alpha = .5, lambda = .01, standardize = FALSE),
    naive_bayes = e1071::naiveBayes(x, y, laplace = 1),
    neural_net = nnet::nnet(as.matrix(x), nnet::class.ind(y), size = 8,
                   softmax = TRUE, decay = .1, maxit = 200, trace = FALSE,
                   MaxNWts = 100000),
    knn = list(x = as.matrix(x), y = y, k = 5L),
    stop("Unsupported classifier."))
}

predict_probabilities <- function(fit, x, method) {
  p <- switch(method,
    forest = predict(fit, x, type = "prob"),
    tree = predict(fit, x, type = "prob"),
    multinomial = predict(fit, as.matrix(x), type = "response", s = .01)[, , 1, drop = FALSE],
    naive_bayes = predict(fit, x, type = "raw", threshold = .001),
    neural_net = predict(fit, as.matrix(x), type = "raw"),
    knn = t(vapply(seq_len(nrow(x)), function(i) {
      dist <- rowSums(sweep(fit$x, 2, as.numeric(x[i, ]), "-")^2)
      ids <- order(dist, seq_along(dist))[seq_len(min(fit$k, length(dist)))]
      as.numeric(table(factor(fit$y[ids], levels = stage_levels))) / length(ids)
    }, numeric(6))), stop("Unsupported classifier."))
  if (length(dim(p)) == 3) p <- matrix(p, nrow = nrow(x), ncol = 6)
  p <- matrix(p, nrow = nrow(x), ncol = 6,
              dimnames = list(NULL, stage_levels))
  if (any(!is.finite(p)) || any(p < 0) || any(rowSums(p) <= 0)) stop("Invalid probabilities.")
  p / rowSums(p)
}

multiclass_metrics <- function(y, p) {
  predicted <- factor(stage_levels[max.col(p, ties.method = "first")], levels = stage_levels)
  cm <- table(actual = factor(y, levels = stage_levels), predicted = predicted)
  tp <- diag(cm); actual_n <- rowSums(cm); pred_n <- colSums(cm)
  recall <- ifelse(actual_n > 0, tp / actual_n, NA_real_)
  precision <- ifelse(pred_n > 0, tp / pred_n, 0)
  f1 <- ifelse(actual_n + pred_n > 0, 2 * tp / (actual_n + pred_n), NA_real_)
  index <- cbind(seq_along(y), match(as.character(y), stage_levels))
  list(summary = c(accuracy = sum(tp) / sum(cm), macro_f1 = mean(f1, na.rm = TRUE),
       balanced_accuracy = mean(recall, na.rm = TRUE), log_loss = -mean(log(pmax(p[index], 1e-15)))),
       per_class = data.frame(stage = stage_levels, support = as.integer(actual_n),
                             recall = recall, precision = precision, f1 = f1),
       confusion = cm, predicted = predicted)
}

model_specs <- function() data.frame(
  name = c("structured_rf", "structured_tree", "structured_elastic_net",
           "structured_nb", "structured_knn", "structured_nn", "text_elastic_net", "text_rf", "combined_elastic_net"),
  mode = c(rep("structured", 6), "text", "text", "combined"),
  method = c("forest", "tree", "multinomial", "naive_bayes", "knn", "neural_net", "multinomial", "forest", "multinomial"))

train_bundle <- function(d, spec, seed, trees = 500L, max_terms = 1000L) {
  enc <- fit_encoder(d, spec$mode, max_terms = max_terms)
  x <- transform_encoder(d, enc)
  list(encoder = enc, model = fit_classifier(x, d$y, spec$method, seed, trees),
       method = spec$method, name = spec$name, stage_levels = stage_levels)
}
score_bundle <- function(bundle, d)
  predict_probabilities(bundle$model, transform_encoder(d, bundle$encoder), bundle$method)

run_experiment <- function(d, out, seed = 2024L, folds = 3L, trees = 500L, max_terms = 1000L) {
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  split <- split_surveys(d$y, seed = seed)
  tr <- d[split$train, ]; te <- d[split$test, ]
  stopifnot(!length(intersect(tr$Id, te$Id)))
  fold <- make_folds(tr$y, folds, seed)
  specs <- model_specs(); cv <- list()
  for (i in seq_len(nrow(specs))) for (k in seq_len(folds)) {
    fit <- train_bundle(tr[fold != k, ], specs[i, ], seed + k, trees, max_terms)
    score <- score_bundle(fit, tr[fold == k, ])
    cv[[length(cv) + 1]] <- cbind(model = specs$name[i], fold = k,
      as.data.frame(as.list(multiclass_metrics(tr$y[fold == k], score)$summary)))
  }
  cv <- do.call(rbind, cv)
  cvmean <- aggregate(cv[c("accuracy", "macro_f1", "balanced_accuracy", "log_loss")], list(model = cv$model), mean)
  cvmean <- cvmean[order(-cvmean$macro_f1, cvmean$model), ]
  chosen <- cvmean$model[1] # selection is frozen before any outer-test scoring
  write.csv(cv, file.path(out, "cv-fold-metrics.csv"), row.names = FALSE)
  write.csv(cvmean, file.path(out, "cv-model-comparison.csv"), row.names = FALSE)
  test_metrics <- list(); class_metrics <- list(); confusion <- list()
  for (i in seq_len(nrow(specs))) {
    fit <- train_bundle(tr, specs[i, ], seed, trees, max_terms)
    score <- score_bundle(fit, te); m <- multiclass_metrics(te$y, score)
    test_metrics[[i]] <- cbind(model = specs$name[i], selected_by_cv = specs$name[i] == chosen,
                             as.data.frame(as.list(m$summary)))
    class_metrics[[i]] <- cbind(model = specs$name[i], m$per_class)
    confusion[[i]] <- cbind(model = specs$name[i], as.data.frame(m$confusion))
    if (specs$name[i] == chosen) {
      saveRDS(fit, file.path(out, "evaluation-model.rds"))
      write.csv(data.frame(Id = te$Id, actual = te$y, predicted = m$predicted, score),
                file.path(out, "private-test-predictions.csv"), row.names = FALSE)
    }
  }
  counts <- as.numeric(table(tr$y)); baseline <- matrix(counts / sum(counts), nrow(te), 6, byrow = TRUE)
  test_metrics[[length(test_metrics) + 1]] <- cbind(model = "training_prior_baseline", selected_by_cv = FALSE,
    as.data.frame(as.list(multiclass_metrics(te$y, baseline)$summary)))
  write.csv(do.call(rbind, test_metrics), file.path(out, "test-metrics.csv"), row.names = FALSE)
  write.csv(do.call(rbind, class_metrics), file.path(out, "per-stage-metrics.csv"), row.names = FALSE)
  write.csv(do.call(rbind, confusion), file.path(out, "confusion-matrices.csv"), row.names = FALSE)
  write.csv(data.frame(partition = c("train", "test"), n = c(nrow(tr), nrow(te))),
            file.path(out, "split-audit.csv"), row.names = FALSE)
  write.csv(data.frame(Id = tr$Id, fold = fold), file.path(out, "private-cv-folds.csv"), row.names = FALSE)
  write.csv(data.frame(field = question_names, missing = vapply(d[question_names], function(x) sum(is.na(x)), 0L)),
            file.path(out, "missingness.csv"), row.names = FALSE)
  writeLines(c(paste("Selected by training CV macro-F1:", chosen), paste("Seed:", seed),
    paste("Folds:", folds, "Trees:", trees, "Max terms:", max_terms),
    "Held-out scores are from a reconstructed local evaluation, not Kaggle scores.",
    "Saved model uses outer-training rows only; no automatic full-data refit.",
    capture.output(sessionInfo())), file.path(out, "run-info.txt"))
  invisible(do.call(rbind, test_metrics))
}

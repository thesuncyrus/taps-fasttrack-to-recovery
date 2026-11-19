# Fixed survey predictor scope and reversible model-label encoding.
source("config.R")
survey_predictors <- taps_config$predictors
stage_label_map <- setNames(taps_config$labels, make.names(taps_config$labels))

encode_stage_labels <- function(labels) {
  labels <- as.character(labels)
  if(anyNA(labels) || any(!labels %in% unname(stage_label_map)))
    stop("Expected six grief-stage labels 1-6.")
  factor(make.names(labels), levels=names(stage_label_map), ordered=TRUE)
}

decode_stage_labels <- function(labels) {
  decoded <- unname(stage_label_map[as.character(labels)])
  if(anyNA(decoded)) stop("Model produced an unknown stage label.")
  decoded
}

fit_stage_classifier <- function(d, method, control) {
  if(!all(c("y", survey_predictors) %in% names(d)))
    stop("Missing stage outcome or q4-q20 survey predictors.")
  # caret fits the zero-variance filter and transformations inside each fold.
  caret::train(x=d[,survey_predictors,drop=FALSE], y=d$y,
    method=method, trControl=control, metric=taps_config$metric,
    preProcess=taps_config$preprocess)
}

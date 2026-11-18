# Fixed survey predictor scope and reversible model-label encoding.
survey_predictors <- paste0("q", 4:20)
stage_label_map <- setNames(as.character(1:6), make.names(as.character(1:6)))

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
    method=method, trControl=control, metric="Accuracy",
    preProcess=c("zv","YeoJohnson","range"))
}

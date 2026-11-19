# Existing structured-classification experiment; loading does not set the seed.
taps_config <- list(
  predictors = paste0("q", 4:20), labels = as.character(1:6),
  seed = 111, default_method = "glmnet", resampling = "LOOCV", metric = "Accuracy",
  preprocess = c("zv", "YeoJohnson", "range"),
  correlation_diagnostic_cutoff = .85,
  test_sheet = "test", test_range = "A1:W2951"
)
# Correlation remains a diagnostic. The separate text exploration has no classifier.

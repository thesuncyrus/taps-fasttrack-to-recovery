packages <- c("randomForest", "rpart", "glmnet", "e1071", "nnet", "ggplot2")
missing <- packages[!vapply(packages, requireNamespace, TRUE, quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
cat("All runtime dependencies available.\n")

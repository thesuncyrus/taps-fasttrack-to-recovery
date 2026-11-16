source("pipeline.R")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Usage: Rscript run.R examples.csv outputs [target-column]")
for (pkg in c("randomForest", "rpart", "glmnet", "e1071", "nnet"))
  if (!requireNamespace(pkg, quietly = TRUE)) stop(paste("Run setup.R; missing", pkg))
target <- if (length(args) >= 3) args[3] else "y"
d <- read_surveys(args[1], target)
print(run_experiment(d, args[2]))
writeLines(paste("Input MD5:", tools::md5sum(args[1])), file.path(args[2], "input-checksum.txt"))

# Synthetic survey cases exercise predictor filtering and exported stage labels.
source("src/classification_helpers.R")
stopifnot(identical(decode_stage_labels(encode_stage_labels(c(6,1,3,2))),c("6","1","3","2")))
stopifnot(inherits(try(decode_stage_labels("X7"),silent=TRUE),"try-error"))
set.seed(111)
n <- 60L
d <- as.data.frame(matrix(sample(1:5,n*17,replace=TRUE),nrow=n))
names(d) <- survey_predictors
d$q4 <- 3L
d$q5 <- c(2L,rep(1L,n-1L))
d$y <- encode_stage_labels(rep(1:6,length.out=n))
# One fold excludes the only distinct q5 record: q5 becomes constant in that fold.
index <- list(first=2:n,second=c(1:20,41:60),third=1:40)
ctrl <- caret::trainControl(method="cv",number=3,index=index,allowParallel=FALSE)
for(method in c("rf","glmnet")) {
  fit <- fit_stage_classifier(d,method,ctrl)
  predictions <- decode_stage_labels(predict(fit,d))
  stopifnot(length(predictions)==n,all(predictions %in% as.character(1:6)),
            "q4" %in% fit$preProcess$method$remove)
}
cat("Constant-predictor, fold filtering and stage-label checks passed.\n")

# Structured survivor-survey classification.
# Select regularized logistic regression or Random Forest through caret.
args <- commandArgs(trailingOnly=TRUE)
if(length(args)<2) stop("Usage: Rscript src/grief_stage_classification.R examples.csv test.xlsx [glmnet|rf] [outputs]")
method <- if(length(args)>2) args[3] else "glmnet"
if(!method %in% c("glmnet","rf")) stop("Choose a model method: glmnet or rf.")
out <- if(length(args)>3) args[4] else "outputs"
for(pkg in c("caret","readxl","MLmetrics",if(method=="rf") "randomForest" else "glmnet"))
 if(!requireNamespace(pkg,quietly=TRUE)) stop(paste("Install",pkg))
d <- read.table(args[1],header=TRUE,sep=",")
test <- as.data.frame(readxl::read_xlsx(args[2],sheet="test",col_names=TRUE,range="A1:W2951"))
if(!all(paste0("q",1:22) %in% names(d)) || !"Id" %in% names(test)) stop("Unexpected survey schema.")
d$Id <- NULL
if(ncol(d)!=23) stop("Expected 22 questions followed by the target column.")
d <- d[,c(23,1:22)];names(d)[1] <- "y"
for(n in c("q21","q22")) {
 d[[n]] <- trimws(d[[n]]);d[[n]][!is.na(d[[n]]) & nchar(d[[n]])==0] <- NA
 test[[n]] <- trimws(test[[n]]);test[[n]][!is.na(test[[n]]) & nchar(test[[n]])==0] <- NA
}
d$y <- factor(d$y,ordered=TRUE,levels=as.character(1:6))
if(anyNA(d$y)) stop("Expected six grief-stage labels 1–6.")
for(n in c("q1","q2")) {d[[n]]<-as.factor(d[[n]]);test[[n]]<-as.factor(test[[n]])}
# Predictor diagnostics: correlation counted, zero-variance columns removed.
descrCor <- cor(d[,4:21]);print(sum(abs(descrCor[upper.tri(descrCor)])>.85))
nzv <- caret::nearZeroVar(d,saveMetrics=TRUE)
d <- d[,c(TRUE,!nzv$zeroVar[2:ncol(d)])]
# caret fits Yeo-Johnson and range transforms within resampling and reuses
# the final training transforms when predict() receives new survey records.
levels(d$y) <- make.names(levels(factor(d$y)))
set.seed(111)
ctrl <- caret::trainControl(method="LOOCV",classProbs=TRUE,
 summaryFunction=caret::multiClassSummary,allowParallel=TRUE)
fit <- caret::train(y ~ q4+q5+q6+q7+q8+q9+q10+q11+q12+q13+q14+q15+q16+q17+q18+q19+q20,
 data=d,method=method,trControl=ctrl,metric="Accuracy",
 preProcess=c("YeoJohnson","range"))
dir.create(out,recursive=TRUE,showWarnings=FALSE)
write.csv(fit$results,file.path(out,"resampling-results.csv"),row.names=FALSE)
# Source confusion matrix is training/resubstitution, not held-out accuracy.
cm <- caret::confusionMatrix(predict(fit,d),d$y)
write.csv(as.data.frame(cm$table),file.path(out,"training-confusion.csv"),row.names=FALSE)
write.csv(data.frame(Id=test$Id,label=predict(fit,test)),file.path(out,"kaggle-predictions.csv"),row.names=FALSE)
saveRDS(fit,file.path(out,"model.rds"))
writeLines(c(paste("Method:",method),"Yeo-Johnson and range preprocessing; leave-one-out cross-validation.",capture.output(sessionInfo())),file.path(out,"run-info.txt"))

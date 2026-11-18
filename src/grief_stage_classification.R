# Structured survivor-survey classification.
# Select regularized logistic regression or Random Forest through caret.
source("src/classification_helpers.R")
args <- commandArgs(trailingOnly=TRUE)
if(length(args)<2) stop("Usage: Rscript src/grief_stage_classification.R examples.csv test.xlsx [glmnet|rf] [outputs]")
method <- if(length(args)>2) args[3] else "glmnet"
if(!method %in% c("glmnet","rf")) stop("Choose a model method: glmnet or rf.")
out <- if(length(args)>3) args[4] else "outputs"
for(pkg in c("caret","readxl","MLmetrics",if(method=="rf") "randomForest" else "glmnet"))
 if(!requireNamespace(pkg,quietly=TRUE)) stop(paste("Install",pkg))
d <- read.table(args[1],header=TRUE,sep=",")
test <- as.data.frame(readxl::read_xlsx(args[2],sheet="test",col_names=TRUE,range="A1:W2951"))
if(!all(paste0("q",1:22) %in% names(d)) ||
   !all(c("Id",paste0("q",1:22)) %in% names(test))) stop("Unexpected survey schema.")
d$Id <- NULL
if(ncol(d)!=23) stop("Expected 22 questions followed by the target column.")
d <- d[,c(23,1:22)];names(d)[1] <- "y"
for(n in c("q21","q22")) {
 d[[n]] <- trimws(d[[n]]);d[[n]][!is.na(d[[n]]) & nchar(d[[n]])==0] <- NA
 test[[n]] <- trimws(test[[n]]);test[[n]][!is.na(test[[n]]) & nchar(test[[n]])==0] <- NA
}
d$y <- encode_stage_labels(d$y)
for(n in c("q1","q2")) {d[[n]]<-as.factor(d[[n]]);test[[n]]<-as.factor(test[[n]])}
# Correlation diagnostic on nonconstant numeric survey items.
numeric_items <- d[,paste0("q",3:20),drop=FALSE]
varying <- vapply(numeric_items,function(x) length(unique(x[!is.na(x)]))>1,logical(1))
if(sum(varying)>1) {
 descrCor <- cor(numeric_items[,varying,drop=FALSE])
 print(sum(abs(descrCor[upper.tri(descrCor)])>.85,na.rm=TRUE))
}
set.seed(111)
ctrl <- caret::trainControl(method="LOOCV",classProbs=TRUE,
 summaryFunction=caret::multiClassSummary,allowParallel=TRUE)
fit <- fit_stage_classifier(d, method, ctrl)
dir.create(out,recursive=TRUE,showWarnings=FALSE)
write.csv(fit$results,file.path(out,"resampling-results.csv"),row.names=FALSE)
# Source confusion matrix is training/resubstitution, not held-out accuracy.
cm <- caret::confusionMatrix(predict(fit,d),d$y)
write.csv(as.data.frame(cm$table),file.path(out,"training-confusion.csv"),row.names=FALSE)
write.csv(data.frame(Id=test$Id,label=decode_stage_labels(predict(fit,test))),file.path(out,"kaggle-predictions.csv"),row.names=FALSE)
write.csv(data.frame(model_label=names(stage_label_map),stage_label=unname(stage_label_map)),
 file.path(out,"label-map.csv"),row.names=FALSE)
saveRDS(fit,file.path(out,"model.rds"))
writeLines(c(paste("Method:",method),"Zero-variance filtering, Yeo-Johnson and range preprocessing; leave-one-out cross-validation.",capture.output(sessionInfo())),file.path(out,"run-info.txt"))

# Separate exploratory text branch; text tokens do not feed the saved classifier.
args <- commandArgs(trailingOnly=TRUE)
if(!length(args)) stop("Supply an authorized survey CSV. Optional flag: --translate-authorized")
library(dplyr);library(tidytext);library(textcat)
d <- read.csv(args[1],stringsAsFactors=FALSE)
for(n in c("q21","q22")) {d[[n]]<-trimws(d[[n]]);d[[n]][!is.na(d[[n]]) & nchar(d[[n]])==0]<-NA}
d$lang <- vapply(seq_len(nrow(d)),function(i) {
 text<-if(!is.na(d$q21[i])) d$q21[i] else d$q22[i]
 if(is.na(text)) "english" else textcat::textcat(text)
},character(1))
# The original branch sends text to Google Translate. Require explicit local authorization.
if("--translate-authorized" %in% args) {
 if(!requireNamespace("polyglotr",quietly=TRUE)) stop("Install polyglotr.")
 for(n in c("q21","q22")) {
  d[[n]]<-polyglotr::google_translate(text=d[[n]],target_language="en",source_language="auto")
  d[[n]][!is.na(d[[n]]) & d[[n]]=="THAT"]<-""
 }
} else message("External translation skipped. Counts may mix languages; no equivalence is claimed.")
dir.create("outputs",showWarnings=FALSE)
for(n in c("q21","q22")) {
 # seq_len fixes the original hard-coded 1:50 row vector; tokenization unchanged.
 tokens<-tibble(line=seq_len(nrow(d)),text=as.character(d[[n]])) %>%
  unnest_tokens(word,text) %>% anti_join(tidytext::stop_words,by="word") %>% count(word,sort=TRUE)
 write.csv(tokens,file.path("outputs",paste0(n,"-word-counts.csv")),row.names=FALSE)
}

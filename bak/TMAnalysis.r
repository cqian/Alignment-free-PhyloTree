rm(list=ls())
library(topicmodels)
data("AssociatedPress", package = "topicmodels")

# read input files
setwd("~/Cloud/Dropbox/Fall2015/GM-STATG6509/Proj/src")
docFile = "../Tools/ap/ap.txt";
vocabFile = "../Tools/ap/vocab.txt";

k=5
lda <- LDA(AssociatedPress[1:20,], control = list(alpha = 0.1), k)
gammaDF <- as.data.frame(lda@gamma) 
names(gammaDF) <- c(1:k)
# inspect...
gammaDF

toptopics <- as.data.frame(cbind(document = row.names(gammaDF), 
                                 topic = apply(gammaDF,1,function(x) names(gammaDF)[which(x==max(x))])))
# inspect...
toptopics   



## Rscript to call LDA R package 
# Some code is from LDA demo by Prof. Blei
# Chenzhe Qian
# Dec 2015 

library(lda);
require("ggplot2")
require("reshape2")

# read input files
setwd(getwd())
args <- commandArgs(TRUE);

## Data
docFile <- args[1];
vocabFile <- paste(docFile, '', sep='Vocab')
# docFile <- 'output/data';
# vocabFile <- 'output/dataVocab.txt'

vocabs = read.vocab(vocabFile);
conn <- file(docFile,open="r")
doclines <-readLines(conn)
close(conn)

# construct proper format
docs = lexicalize(doclines, sep = " ", lower = FALSE, 
			count = 1L, vocab = vocabs);

## Parameters
K <- as.numeric(args[3]);
alpha <- as.numeric(args[4]);
eta <- as.numeric(args[5]);
maxIter <- as.numeric(args[6]);
output <- args[2]

# K <- 10
# alpha <- 0.1;
# eta <- 1;
# maxIter <- 1000;

# run analysis
result <- lda.collapsed.gibbs.sampler(
			docs, K, vocabs, maxIter, alpha, eta,
			compute.log.likelihood=TRUE);

N <- length(doclines)
topic.proportions <- t(result$document_sums) / colSums(result$document_sums);
write(topic.proportions, file=output, ncolumns=K, append=FALSE, sep="\t")



# ## Get the top words in the cluster
# top.words <- top.topic.words(result$topics, 5, by.score=TRUE);
# top.topics <- top.topic.documents(result$document_sums, 
#                                   num.documents = 20, alpha = 0.1)
# 
# ## Statistical output
# wc <- word.counts(docs,vocab=vocabs);
# dl <- document.lengths(docs);

# ## Plot
# topic.proportions <- topic.proportions[sample(1:dim(topic.proportions)[1], N),];
# topic.proportions[is.na(topic.proportions)] <-  1/K;
# colnames(topic.proportions) <- apply(top.words, 2, paste, collapse=" ");
#
# topic.proportions.df <- melt(cbind(data.frame(topic.proportions),
#                                    document=factor(1:N)),
#                              variable.name="topic",
#                              id.vars = "document")  
# 
# qplot(topic, value, fill=document, ylab="proportion",
#       data=topic.proportions.df, geom="bar", stat="identity") +
#   theme(axis.text.x = element_text(angle=90, hjust=1)) +
#   coord_flip() +
#   facet_wrap(~ document, ncol=5)

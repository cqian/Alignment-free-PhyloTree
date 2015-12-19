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

# Data
docFile <- args[1];
vocabFile <- paste(docFile, '', sep='Vocab')
output <- args[2]

# # Data for debug
# docFile <- 'output/LDArData';
# vocabFile <- 'output/LDArDataVocab'
# output <- 'output/model'
# eta <- 1;
# maxIter <- 1000;

vocabs = read.vocab(vocabFile);
conn <- file(docFile,open="r")
doclines <-readLines(conn)
close(conn)

# construct proper format
docs = lexicalize(doclines, sep = " ", lower = FALSE, 
			count = 1L, vocab = vocabs);

# select K using Rule of Thumb
K <- round(log(length(vocabs)))
alpha <- 50.0/K
eta <- as.numeric(args[4]);
maxIter <- as.numeric(args[5]);

# run analysis
result <- lda.collapsed.gibbs.sampler(
			docs, K, vocabs, maxIter, alpha, eta,
			compute.log.likelihood=TRUE);

# output topic proportions
N <- length(doclines)
topic.proportions <- t(result$document_sums) / colSums(result$document_sums);
write(topic.proportions, file=output, ncolumns=K, append=FALSE, sep="\t")

# output model complete log-likelihood
ll <- result$log.likelihoods
write(ll[1,], file=paste(output,'LnL',sep=''), append=FALSE, sep=" ")
pdf(paste(output,'LnL.pdf',sep=''))
qplot(1:maxIter, ll[1,], xlab='Iteration', ylab='Log likelihood')
dev.off()


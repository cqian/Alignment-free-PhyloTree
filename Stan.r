## Rscript to call Stan (RStan)
# Chenzhe Qian
# Dec 2015 

# Allow commandline arguments
args<-commandArgs(TRUE)

# load rstan lib
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# get path
setwd(getwd())

# load data and model
if (args[1] == 'LDA') {
	file <- "LDA.stan"
} else if (args[1] == 'CTM') {
	file <- "CTM.stan"
} else if (args[1] == 'fbCTM') {
	file <- "fbCTM.stan"
} else{ 
	stop("Cannot find Stan Model") 
}

# print(args[2])
input <- read_rdump(args[2])
output <- args[3]
maxIter <- as.numeric(args[4])
numChains <- as.numeric(args[5])

# # Data for debug
# file <- "LDA.stan"
# input <- read_rdump('output/StanData');
# output <- 'output/StanTopic'
# numChains <- 1;
# maxIter <- 5;

# run stan to fit the model
fit <- stan(file=file, data=input, iter=maxIter, chains=numChains)

# extract result
post_mean_theta <- get_posterior_mean(fit,'theta')
write(rowMeans(post_mean_theta), file=output, ncolumns=input$K, append=FALSE, sep="\t")

# get the log-posterior for all chains
log_post_model <- get_logposterior(fit)
write(unlist(log_post_model), file=paste(output,'LnL',sep=''), append=FALSE, sep=" ")
pdf(paste(output,'LnL.pdf',sep=''))
qplot(x=1:maxIter, y=unlist(log_post_model), xlab='Iteration', ylab='Log likelihood')
dev.off()

# print run time
get_elapsed_time(fit)



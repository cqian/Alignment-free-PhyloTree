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

print(args[2])
input <- read_rdump(args[2])
output <- args[3]
maxIter <- as.numeric(args[4])
numChains <- as.numeric(args[5])


# run stan to fit the model
fit <- stan(file=file, data=input, iter=maxIter, chains=numChains)

# extract result
# theta <- extract(fit, 'theta', permuted = TRUE)
post_mean_theta <- get_posterior_mean(fit,'theta')
write(rowMeans(post_mean_theta), file=output, ncolumns=input$K, append=FALSE, sep="\t")

# # get the log-posterior for all chains
# log_post_model <- get_logposterior(fit)
# lp <- extract(fit, 'lp__', permuted = TRUE)

# # print result
# print(fit)
# plot(fit) 
# 
# # plot result
# plot(fit, pars = c("theta"))
# theta <- extract(fit, 'theta')
# theta <- unlist(theta, use.names=FALSE)
# plot(density(theta),
#      xlab=expression(theta), col=grey(0, 0.8),
#      main="Parameter distribution")
# 
# plot(fit, pars=c("phi")) 
# phi <- extract(fit, 'phi')
# phi <- unlist(phi, use.names=FALSE)
# plot(density(phi),
#      xlab=expression(phi), col=grey(0, 0.8),
#      main="Parameter distribution")
#
# plot(fit, pars = c("eta"))
# eta <- extract(fit, 'eta')
# eta <- unlist(eta, use.names=FALSE)
# plot(density(eta),
#      xlab=expression(eta), col=grey(0, 0.8),
#      main="Parameter distribution")


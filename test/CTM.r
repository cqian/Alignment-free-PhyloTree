library(rstan)

setwd(getwd())

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

CTMdata <- read_rdump('CTM.data.r')
fit <- stan(file="CTM.stan", data = CTMdata, iter = 50, chains = 1,
	algorithm = c("NUTS", "HMC", "Fixed_param"))

fit1 <- stan(fit=fit, data = CTMdata, iter = 50, chains = 1, algorithm = "NUTS")

# fit1 <- stan(fit=fit, data = CTMdata, iter = 1000, chains = 4)

# X11()
print(fit)
plot(fit)
plot(fit, pars=c("phi")) 
plot(fit, pars = c("eta"))
plot(fit, pars = c("theta"))

la <- extract(fit, permuted = TRUE) 
a <- extract(fit, permuted = FALSE) 



theta <- extract(fit, 'theta')
theta <- unlist(theta, use.names=FALSE)
plot(density(theta),
     xlab=expression(theta), col=grey(0, 0.8),
     main="Parameter distribution")

phi <- extract(fit, 'phi')
phi <- unlist(phi, use.names=FALSE)
plot(density(phi),
     xlab=expression(phi), col=grey(0, 0.8),
     main="Parameter distribution")

eta <- extract(fit, 'eta')
eta <- unlist(eta, use.names=FALSE)
plot(density(eta),
     xlab=expression(eta), col=grey(0, 0.8),
     main="Parameter distribution")

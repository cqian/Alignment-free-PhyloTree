## Full Bayes Correlated Topic Model in Stan
# most of the code are from Stan Manual
# http://mc-stan.org/documentation/ 

data {
	int<lower=2> K;
	int<lower=2> V;
	int<lower=1> M;
	int<lower=1> N;
	int<lower=1,upper=V> w[N];
	int<lower=1,upper=M> doc[N];  // doc ID for word n
	vector<lower=0>[V] beta;      // word prior
}

parameters {
	vector[K] mu;              // topic mean
	corr_matrix[K] Omega;      // correlation matrix
	vector<lower=0>[K] sigma;  // scales
	vector[K] eta[M];           // logit topic dist for doc m
	simplex[V] phi[K];         // word dist for topic k
}

transformed parameters {
	simplex[K] theta[M];       // simplex topic dist for doc m
	cov_matrix[K] Sigma;       // covariance matrix
	for (m in 1:M)
		theta[m] <- softmax(eta[m]);

	for (m in 1:K)
		Sigma[m,m] <- sigma[m] * sigma[m] * Omega[m,m];
	for (m in 1:(K-1)) {
		for (n in (m+1):K) {
			Sigma[m,n] <- sigma[m] * sigma[n] * Omega[m,n];
			Sigma[n,m] <- Sigma[m,n];
		} 
	}
}

model {
	// priors
	// topic dist for doc m
	// word dist for topic k
	mu ~ normal(0,5);       // vectorized, diffuse
	Omega ~ lkj_corr(2.0);  // regularize to unit correlation
	sigma ~ cauchy(0,5);  
	for (k in 1:K)  
		phi[k] ~ dirichlet(beta);
	
	// topic distribution for docs
	for (m in 1:M)
		eta[m] ~ multi_normal(mu,Sigma);
	for (n in 1:N) {
		real gamma[K];
		for (k in 1:K)
			gamma[k] <- log(theta[doc[n],k]) + log(phi[k,w[n]]);
		increment_log_prob(log_sum_exp(gamma));
	}
}

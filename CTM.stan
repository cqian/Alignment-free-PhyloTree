## Fixed Hyperparameter Correlated Topic Model in Stan
# most of the code are from Stan Manual
# http://mc-stan.org/documentation/ 

data {
	int<lower=2> K; // K topics
	int<lower=2> V; // Vocabulary
	int<lower=1> M; // M docs
	int<lower=1> N; // total N instnaces of words
	int<lower=1,upper=V> w[N];
	int<lower=1,upper=M> doc[N];  // doc ID for word n

	vector<lower=0>[V] beta;      // word prior
	vector[K] mu;          // topic mean
	cov_matrix[K] Sigma;   // topic covariance
}

parameters {
	simplex[V] phi[K];  // word dist for topic k
	vector[K] eta[M];   // topic dist for doc m
} 

transformed parameters {
	simplex[K] theta[M];
	for (m in 1:M)
		theta[m] <- softmax(eta[m]);
}

model {
	// topic dist for doc m
	// word dist for topic k
	for (m in 1:M)
		eta[m] ~ multi_normal(mu, Sigma);
	for (k in 1:K)
		phi[k] ~ dirichlet(beta);     // prior
	for (n in 1:N) {
		real gamma[K];
		for (k in 1:K)
			gamma[k] <- log(theta[doc[n],k]) + log(phi[k,w[n]]);
		increment_log_prob(log_sum_exp(gamma));  // likelihood
	}
}

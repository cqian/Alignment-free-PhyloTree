##################
#	Project for STAT/CS 6509 Foundations of Graphical Models
#	LDA-based Alignment-free clustering
#	Author: Chenzhe Qian
# 	Date: Dec 2015
##################

import sys
import numpy as np
from Bio import SeqIO


## Function that reads sequence file 
#	and convert to LDA-c format
def fasta2LDA(input, output, maxSeq):
	seqObj = list(SeqIO.parse(input, 'fasta'))
	vocabDict = {}
	names = {}

	# compute lenght of k-mer by log(max(seq))
	# log base 4
	K = (int)(np.log(min(maxSeq, max(len(doc.seq) for doc in seqObj)))/np.log(4))

	# N = sum(len(doc.seq)-K+1 for doc in seqObj)

	wordId = 0
	newDoc = ''
	n_index = v_index = 1
	for doc in seqObj:
		seqLen = min(maxSeq, len(doc.seq))-K+1
		names[doc.name] = n_index
		for w in range(seqLen):
			kmer = str(doc.seq[w:w+K])
			if kmer not in vocabDict:
				vocabDict[kmer] = wordId = v_index
				v_index += 1
			else:
				wordId = vocabDict[kmer]
			newDoc += str(wordId)+' '

		newDoc += '\n'
		n_index += 1

	fout = open(output,'w')
	fout.write(newDoc)
	fout.close()

	fout = open(output+'Vocab', 'w')
	fout.write('\n'.join(str(v) for k,v in vocabDict.items() ))
	fout.write('\n')
	fout.close()

	# fout = open(output+'VocabCount', 'w')
	# fout.write('\n'.join("{}: {}".format(v, val) for (v, val) in vocabDict.items()) )
	# fout.write('\n')
	# fout.close()
	
	return names


## Function that reads sequence file 
#	and convert to Rstan format
def fasta2Stan(input, output, maxSeq):
	seqObj = list(SeqIO.parse(input, 'fasta'))
	vocabDict = {} 
	names = {}

	# compute lenght of k-mer by log(max(seq))
	K = (int)(np.log(min(maxSeq, max(len(doc.seq) for doc in seqObj)))/np.log(4))
	N = sum(min(maxSeq, len(doc.seq))-K+1 for doc in seqObj)

	# build vocabulary, documents, words and names
	words = [0]*N # word n 
	docID = [0]*N  # doc id for word n
	w_index = 0
	v_index = n_index = 1

	# for each sequence (document)
	for doc in seqObj:
		seqLen = min(maxSeq, len(doc.seq))-K+1
		names[doc.name] = n_index
		# for each word (kmer)	
		for w in range(seqLen):
			docID[w_index] = n_index
			kmer = str(doc.seq[w:w+K])
			if kmer not in vocabDict:
				vocabDict[kmer] = v_index
				words[w_index] = v_index
				v_index += 1
			else:
				words[w_index] = vocabDict[kmer]
			w_index += 1
		n_index += 1

	# Output RStan data
	V = len(vocabDict)
	words = str(words).replace('[','c(').replace(']',')')
	docID = str(docID).replace('[','c(').replace(']',')')
	rstan = open(output, 'w')
	rstan.write("V <- " + str(V) +\
		"\nM <- " + str(n_index-1) + \
		"\nN <- " + str(N) + "\n\n")
	rstan.write("w <- " + words + "\n\n")
	rstan.write("doc <- " + docID + "\n\n")
	rstan.close()

	return V, names


## Function print organisms names
def printNames(fname, names):
	# Output names
	print fname
	fout = open(fname, 'w')
	for n in names:
		fout.write(n+'\n');
	fout.close()


## Function that builds parameteres 
#	for Stan Model
def RStanModelParam(K, V, model, output, Alpha, Eta):
	K = int(K) # number of topics
	K = int(np.log(V)) # compute proper number of topics
	Alpha = 50.0/K

	rdata = open(output, 'a')
	beta = np.random.dirichlet([Eta]*V).tolist();
	beta = str(beta).replace('[','c(').replace(']',')')
		
	rdata.write("K <- " + str(K)+"\n")
	rdata.write("beta <- " + beta + "\n")
	
	if model == 'LDA':
		alpha = np.random.dirichlet([Alpha]*K).tolist();
		alpha = str(alpha).replace('[','c(').replace(']',')')
		rdata.write("alpha <- " + alpha + "\n\n")

	if model == 'CTM':
		mu = np.random.uniform(0.0, 1.0, K).tolist()
		mu = str(mu).replace('[','c(').replace(']',')')
		
		# generate covariance matrix as fixed hyperparameter 
		sigma = []
		for i in range(K):
			sigma += np.fabs(np.random.normal(0, 1, K)).tolist()
		
		# symmetrize sigma matrix
		for i in range(K):
			for j in range(i+1,K):
				sigma[j*K+i] = sigma[i*K+j];
		sigma = str(sigma).replace('[','c(').replace(']',')')
		rdata.write("mu <- " + mu + "\n")
		rdata.write("Sigma <- matrix(" + sigma + ", nrow=" + str(K) + 
						", ncol=" + str(K) + ")\n\n")

	rdata.close()


def main():
	# K is the number of topics input by user
	K = sys.argv[1]

	# Stan or LDAr
	method = sys.argv[2]
	model = sys.argv[3]
	input = sys.argv[4]
	output = sys.argv[5]
	Alpha = float(sys.argv[6])
	Eta = float(sys.argv[7])
	maxSeq = int(sys.argv[8])
	fname = sys.argv[9]

	names = []
	if method == 'LDAr':
		names = fasta2LDA(input, output, maxSeq)
	else:
		V, names = fasta2Stan(input, output, maxSeq)
		RStanModelParam(K, V, model, output, Alpha, Eta)

	printNames(fname, names)


if __name__ == '__main__':
	main()


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
def fasta2LDA(input, output):
	seqObj = list(SeqIO.parse(input, 'fasta'))
	document = open(output,'w')
	vocabOutput = open(output+'Vocab.txt', 'w')
	vocabDict = {}
	vocabs = []
	names = {}
	K = (int)(np.log(max(len(doc.seq) for doc in seqObj)))
	newDoc = ''
	n_index = 1
	for seq_record in seqObj:
		N = len(seq_record.seq)-K+1
		kmerList = [];
		names[seq_record.name] = n_index
		for x in range(N):
			kmer = str(seq_record.seq[x:x+K])
			kmerList.append(kmer)
			newDoc = ''.join(newDoc+kmer+' ')
			if kmer in vocabDict:
				vocabDict[kmer] += 1
			else:
				vocabDict[kmer] = 1

		newDoc = ''.join(newDoc+'\n')
		vocabs = list(set(vocabs+kmerList))
		n_index += 1

	document.write(newDoc)
	document.close()

	vocabOutput.write('\n'.join(v for v in vocabs))
	vocabOutput.write('\n')
	vocabOutput.close()

	# vocabCount = open(output+'VocabCount.txt', 'w')
	# vocabCount.write('\n'.join("{}: {}".format(v, val) for (v, val) in vocabDict.items()) )
	# vocabCount.write('\n')
	# vocabCount.close()
	
	return names


## Function that reads sequence file 
#	and convert to Rstan format
def fasta2Stan(input, output):
	seqObj = list(SeqIO.parse(input, 'fasta'))
	vocabDict = {} 
	names = {}

	# compute lenght of k-mer by log(max(seq))
	K = (int)(np.log(max(len(doc.seq) for doc in seqObj)))
	N = sum(len(doc.seq)-K+1 for doc in seqObj)

	# build vocabulary, documents, words and names
	words = [0]*N # word n 
	docID = [0]*N  # doc id for word n
	w_index = 0
	v_index = n_index = 1

	# for each sequence (document)
	for doc in seqObj:
		seqLen = len(doc.seq)-K+1
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

	## for debug
	# print len(seqObj), n_index
	# print N, w_index
	# vocabDict = sorted(vocabDict.items(), key=lambda item: item[1])
	# print L, N, w_index, n_index, v_index
	# print vocabDict;
	# print names
	# print words
	# print docID

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
def printNames(output, names):
	# Output names
	fnames = open(output[0:output.rfind('/')+1]+'names.txt', 'w')
	for n in names:
		fnames.write(n+'\n');
	fnames.close()


## Function that builds parameteres 
#	for Stan Model
def RStanModelParam(K, V, model, output, Alpha, Eta):
	K = int(K)
	rstan = open(output, 'a')

	beta = np.random.dirichlet([Eta]*V).tolist();
	beta = str(beta).replace('[','c(').replace(']',')')
		
	rstan.write("K <- " + str(K)+"\n")
	rstan.write("beta <- " + beta + "\n")
	
	if model == 'LDA':
		alpha = np.random.dirichlet([Alpha]*K).tolist();
		alpha = str(alpha).replace('[','c(').replace(']',')')
		rstan.write("alpha <- " + alpha + "\n\n")

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
		rstan.write("mu <- " + mu + "\n")
		rstan.write("Sigma <- matrix(" + sigma + ", nrow=" + str(K) + 
						", ncol=" + str(K) + ")\n\n")

	rstan.close()


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

	names = []
	if method == 'LDAr':
		names = fasta2LDA(input, output)
	else:
		V, names = fasta2Stan(input, output)
		RStanModelParam(K, V, model, output, Alpha, Eta)

	printNames(output, names)


if __name__ == '__main__':
	main()


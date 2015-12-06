import sys
import numpy as np
from Bio import SeqIO

def fasta2LDA(input, output):
	seqObj = list(SeqIO.parse(input, 'fasta'))
	doc = open(output+'.txt','w')
	vocabOutput = open(output+'Vocab.txt', 'w')
	vocabDict = {}
	vocabs = [];
	scount = 0;
	L = (int)(np.log(max(len(doc.seq) for doc in seqObj)))
	for seq_record in seqObj:
		# doc.write("<DOC>\n<DOCNO> ")
		# doc.write(seq_record.id)
		# doc.write(" </DOCNO>\n<TEXT>\n")
		N = len(seq_record.seq)-L+1
		kmerList = [];
		for x in range(N):
			kmer = str(seq_record.seq[x:x+L])
			kmerList.append(kmer)
			doc.write(kmer+" ")
			if kmer in vocabDict:
				vocabDict[kmer] += 1
			else:
				vocabDict[kmer] = 1
		# doc.write("\n</TEXT>\n</DOC>\n")
		doc.write("\n")
		vocabs = list(set(vocabs+kmerList))
		scount += 1;
	doc.close()

	print "The number of Species is " + str(scount) 
	vocabOutput.write('\n'.join(v for v in vocabs))
	vocabOutput.write('\n')
	vocabOutput.close()

	vocabCount = open(output+'VocabCount.txt', 'w')
	vocabCount.write('\n'.join("{}: {}".format(v, val) for (v, val) in vocabDict.items()) )
	vocabCount.write('\n')
	vocabCount.close()


def fasta2Stan(input, output):
	seqObj = list(SeqIO.parse(input, 'fasta'))
	vocabDict = {} 
	names = {}

	# compute lenght of l-mer by log(max(seq))
	L = (int)(np.log(max(len(doc.seq) for doc in seqObj)))
	N = sum(len(doc.seq)-L+1 for doc in seqObj)

	# build vocabulary, documents, words and names
	words = [0]*N # word n 
	docID = [0]*N  # doc id for word n
	w_index = 0
	v_index = n_index = 1

	# for each sequence (document)
	for doc in seqObj:
		seqLen = len(doc.seq)-L+1
		names[doc.name] = n_index
		
		# for each word (kmer)	
		for w in range(seqLen):
			docID[w_index] = n_index
			kmer = str(doc.seq[w:w+L])
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

	# initialized hyperparameters
	K = 10 # number of topics
	V = len(vocabDict)
	alpha = np.random.dirichlet([1]*K).tolist();
	beta = np.random.dirichlet([1]*V).tolist();
	alpha = str(alpha).replace('[','c(').replace(']',')')
	beta = str(beta).replace('[','c(').replace(']',')')
	words = str(words).replace('[','c(').replace(']',')')
	docID = str(docID).replace('[','c(').replace(']',')')

	# output R format data
	data = open(output+'.r', 'w')
	data.write("K <- " + str(K) + \
		"\nV <- " + str(V) +\
		"\nM <- " + str(n_index-1) + \
		"\nN <- " + str(N) + "\n\n")
	data.write("alpha <- " + alpha + "\n\n")
	data.write("beta <- " + beta + "\n\n")
	data.write("w <- " + words + "\n\n")
	data.write("doc <- " + docID + "\n\n")
	data.close()


def main():
	input = sys.argv[1]
	output = sys.argv[2]

 	# fasta2LDA(input, output)
 	fasta2Stan(input, output)


if __name__ == '__main__':
	main()



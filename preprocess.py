import sys
import numpy as np
from Bio import SeqIO


def fasta2LDA(K, input, output):
	seqObj = SeqIO.parse(input, "fasta")
	doc = open(output+'.txt','w')
	vocabOutput = open(output+'Vocab.txt', 'w')
	vocabDict = {}
	vocabs = [];
	scount = 0;
	for seq_record in seqObj:
		doc.write("<DOC>\n<DOCNO>")
		doc.write(seq_record.id)
		doc.write("<\DOCNO>\n<TEXT>")
		N = len(seq_record.seq)-K+1
		kmerList = [];
		for x in range(N):
			kmer = str(seq_record.seq[x:x+K])
			kmerList.append(kmer)
			doc.write(kmer+" ")
			vocabDict[kmer]=1
		doc.write("\n<\TEST>\n<\DOC>\n")
		vocabs = list(set(vocabs+kmerList))
		scount += 1;
	doc.close()

	print "The number of Species is " + str(scount) 
	vocabOutput.write('\n'.join(v for v in vocabs))
	vocabOutput.write('\n')
	vocabOutput.close()

def main():
	K = int(sys.argv[1])
	input = sys.argv[2]
	output = sys.argv[3]
 	fasta2LDA(K, input, output)


if __name__ == '__main__':
	main()
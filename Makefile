.PHONY: clean

KMER = 5
# DATA = ~/Desktop/Data/SquamateMTCDs/seq.fasta
DATA = ~/Desktop/Data/sample.fasta
OUTPUT = seq

fasta2LDA:
	python preprocess.py $(DATA) $(OUTPUT) $(KMER)

fasta2Stan:
	python preprocess.py $(DATA) $(OUTPUT)

clean:
	rm *.*~ *~

.PHONY: clean

# DATA = ~/Desktop/Data/SquamateMTCDs/seq.fasta
DATA = ~/Desktop/Data/sample.fasta
OUTPUT = output/data

TOPIC = output/topic_proportion.txt
MATRIX = output/JSDMatrix.txt

fasta2LDA:
	python preprocess.py $(DATA) $(OUTPUT) $(KMER)

fasta2Stan:
	python preprocess.py $(DATA) $(OUTPUT)

jsd:
	python JSD.py $(TOPIC) $(MATRIX)



clean:
	rm *.*~ *~

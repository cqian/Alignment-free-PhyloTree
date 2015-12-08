K = 10
ETA = 0.1
ALPHA = $$((50 / $(K) ))
MAXITER = 1000

METHOD = LDAr#{Stan, LDAr}
MODEL = LDA #{LDA, CTM, fbCTM}

DATA = ~/Desktop/Data/SquamateMTCDs/seq.fasta
# DATA = ~/Desktop/Data/sample.fasta
PREFIX = output/
OUTPUT = $(PREFIX)$(METHOD)Data
TOPIC = $(PREFIX)$(METHOD)Topic_proportion
MATRIX = $(PREFIX)$(METHOD)JSDMatrix


jsd:
	python JSD.py $(TOPIC) $(MATRIX)
	./ffptree -p $(MATRIX) > $(PREFIX)$(METHOD)NeighborTree
	./ffptree -n $(MATRIX) > $(PREFIX)$(METHOD)UPGMATree

Stan:
	python preprocess.py $(K) Stan $(MODEL) $(DATA) $(OUTPUT) $(ALPHA) $(ETA)
	Rscript Stan.r $(MODEL) $(OUTPUT) $(TOPIC) $(MAXITER) 1
	make jsd

LDAr:
	python preprocess.py $(K) LDAr LDA $(DATA) $(OUTPUT) $(ALPHA) $(ETA)
	Rscript LDAr.r $(OUTPUT) $(TOPIC) $(K) $(ALPHA) $(ETA) $(MAXITER)
	make jsd


.PHONY: clean
clean:
	rm *.*~ *~

# python preprocess.py 10 LDAr LDA ~/Desktop/Data/SquamateMTCDs/seq.fasta output/LDArTest 0.1 1
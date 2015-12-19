K = 20
ETA = 0.1
ALPHA = $$((50 / $(K) ))
MAXITER = 10
NUMCHAINS = 1
MAXSEQ = 10000000

#{Stan, LDAr, cmdStan}
METHOD = LDAr
#{LDA, CTM, fbCTM}
MODEL = LDA

CURRDIR = $(shell pwd)
# Geodermatophilaceae16s primatesMitoSeq-Single primatesMitoSeq SquamateMTCDs
DATA = ~/Desktop/Data/Geodermatophilaceae16s.fasta
PREFIX = output/
NAME = $(PREFIX)16s
PREOUTPUT = $(NAME)$(METHOD)Data
MODELINPUT = $(PREOUTPUT)
MODELOUTPUT = $(NAME)$(METHOD)Topic
MATRIX = $(NAME)$(METHOD)JSDMatrix


preprocess:
	python preprocess.py $(K) $(METHOD) $(MODEL) $(DATA) $(PREOUTPUT) $(ALPHA) $(ETA) $(MAXSEQ) $(NAME)

jsd:
	python JSD.py $(MODELOUTPUT) $(MATRIX) $(NAME)
	./ffptree -p $(MATRIX) > $(NAME)$(METHOD)NeighborTree
	./ffptree -n $(MATRIX) > $(NAME)$(METHOD)UPGMATree

Stan:
	make preprocess
	Rscript Stan.r $(MODEL) $(MODELINPUT) $(MODELOUTPUT) $(MAXITER) $(NUMCHAINS)
	make jsd

LDAr:
	make preprocess
	Rscript LDAr.r $(MODELINPUT) $(MODELOUTPUT) $(K) $(ETA) $(MAXITER)
	make jsd


.PHONY: clean
clean:
	rm *.*~ *~

test:
	python preprocess.py 10 LDAr LDA ~/Desktop/Data/SquamateMTCDs/seq.fasta output/LDArTest 0.1 1


# Compile Stan Model with CmdStan
RESULT = $(PREFIX)cmdStanOutmf.csv
STANMODEL = LDA.stan
MAXWARM = $$(($(MAXITER)/2))
ADAPTITER = 100
SAMPLENUM = 100

compile:
	~/Desktop/cmdstan-2.9.0/bin/stanc --name=$(MODEL) --o=$(PREFIX)$(MODEL).hpp $(STANMODEL)

build:
	cd ~/Desktop/cmdstan-2.9.0; \
	make $(CURRDIR)/$(MODEL)

sample:
	# default algo: HMC with NUTS as engine
	./$(MODEL) sample num_samples=$(MAXITER) num_warmup=$(MAXWARM) data file=$(MODELINPUT) output file=$(RESULT)

optimize:
	# default algo: (L)-BFGS
	./$(MODEL) optimize algorithm=lbfgs iter=$(MAXITER) data file=$(MODELINPUT) output file=$(RESULT)

advi:
	./$(MODEL) variational algorithm=meanfield iter=$(MAXITER) adapt iter=$(ADAPTITER) output_samples=$(SAMPLENUM) data file=$(MODELINPUT) output file=$(RESULT)
	# ./$(MODEL) variational algorithm=fullrank iter=$(MAXITER) adapt iter=$(ADAPTITER) output_samples=$(SAMPLENUM) data file=$(OUTPUT) output file=$(RESULT) 

summary:
	~/Desktop/cmdstan-2.9.0/bin/stansummary $(RESULT)


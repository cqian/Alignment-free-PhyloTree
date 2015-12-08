library(ape)
library(distory)

RefTree <- read.tree('SquamateMTCDs/newTree.newick')
NBTree <- read.tree('LDArNeighborTree')
UPGMATree <- read.tree('LDArUPGMATree')

phylo.diff(RefTree,NBTree)
phylo.diff(RefTree,UPGMATree)

distinct.edges(RefTree,NBTree)
distinct.edges(RefTree,tUPGMA)
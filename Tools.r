library(ape)
library(distory)

setwd(getwd())
args <- commandArgs(TRUE)

# draw all trees in a folder
drawTree <- function(dir){
	files <- list.files(path=dir, pattern='*Tree', recursive=FALSE)

	for(i in 1:length(files)){
		fin <- paste(dir, files[i], sep='')
		fout <- paste(fin, '.pdf', sep='')
		print(fin)
		print(fout)
		t <- read.tree(fin)
		pdf(fout)
		plot(t, cex=0.7)
		dev.off()
	}
}

# compare trees
compTree <- function(f1, f2, fout){
	t1 <- read.tree(f1)
	t2 <- read.tree(f2)
	print(length(distinct.edges(t1,t2)))
	pdf(fout)
	phylo.diff(t1,t2,cex=0.7)
	dev.off()
}


# extract data from cmdStan output
extractCSV <- function(input, output, numDocs, numTopics, maxIter) {
	data <- read.csv(input, comment.char='#')
	colIndex <- grep("theta",colnames(data))
	theta <- array(0,c(numTopics,numDocs))
	
	# extract data
	for(iter in (1:maxIter)){
		x <- 1
		for(i in seq(colIndex[1], tail(colIndex,n=1), numDocs)){
			y <- 1
			for (j in 1:numDocs-1){
				theta[x,y] <- theta[x,y] + data[[i+j]][iter]
				y <- y+1
			}
			x <- x+1
		}
	}
	print(theta)

	# normalize
	for(i in 1:numDocs){
		theta[,i] <- theta[,i]/maxIter
	}

	theta <- aperm(theta)
	write(theta, file=output, ncolumns=numTopics, append=FALSE, sep="\t")
}


# dir <- args[1]
# drawTree(dir)

f1 <- args[1]
f2 <- args[2]
fout <- args[3]
compTree(f1, f2, fout)	


# fin <- args[1]
# fout <- args[2]
# numDocs <- 23
# numTopics <- 6
# maxIter <- 101
# extractCSV(fin, fout, numDocs, numTopics, maxIter)


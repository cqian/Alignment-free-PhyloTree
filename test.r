setwd("~/Cloud/Dropbox/Fall2015/GM-STATG6509/Proj/src")
fileName <- "../Tools/ap/ap.txt"
conn <- file(fileName,open="r")
linn <-readLines(conn)
print(linn)
# for (i in 1:length(linn)){
# 	print(linn[i])
# }
close(conn)



rm(list=ls())
setwd("~/Cloud/Dropbox/Fall2015/GM-STATG6509/Proj/src")

docFile = "../Tools/ap/ap.txt";
vocabFile = "../Tools/ap/vocab.txt";

vocabs = read.vocab(vocabFile);
conn <- file(docFile,open="r")
doclines <-readLines(conn)
close(conn)

documents = lexicalize(doclines, sep = " ", lower = FALSE, 
                       count = 1L, vocab = vocabs);

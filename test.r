setwd("~/Cloud/Dropbox/Fall2015/GM-STATG6509/Proj/src")
fileName <- "../Tools/ap/ap.txt"
conn <- file(fileName,open="r")
linn <-readLines(conn)
print(linn)
# for (i in 1:length(linn)){
# 	print(linn[i])
# }
close(conn)
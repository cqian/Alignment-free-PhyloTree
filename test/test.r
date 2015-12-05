# setwd("~/Cloud/Dropbox/Fall2015/GM-STATG6509/Proj/src")
# fileName <- "../Tools/ap/ap.txt"
# conn <- file(fileName,open="r")
# linn <-readLines(conn)
# print(linn)
# # for (i in 1:length(linn)){
# # 	print(linn[i])
# # }
# close(conn)


library(topicmodels)

rm(list=ls())
setwd("~/Cloud/Dropbox/Fall2015/GM-STATG6509/Proj/src")

data("AssociatedPress", package = "topicmodels")
ctm <- CTM(AssociatedPress[1:20,], k = 2)
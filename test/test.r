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


## test code for Stan.r
# plot result
# plot(fit, pars = c("theta"))
# theta <- extract(fit, 'theta')
# theta <- unlist(theta, use.names=FALSE)
# plot(density(theta),
#      xlab=expression(theta), col=grey(0, 0.8),
#      main="Parameter distribution")
# 
# plot(fit, pars=c("phi")) 
# phi <- extract(fit, 'phi')
# phi <- unlist(phi, use.names=FALSE)
# plot(density(phi),
#      xlab=expression(phi), col=grey(0, 0.8),
#      main="Parameter distribution")
#
# plot(fit, pars = c("eta"))
# eta <- extract(fit, 'eta')
# eta <- unlist(eta, use.names=FALSE)
# plot(density(eta),
#      xlab=expression(eta), col=grey(0, 0.8),
#      main="Parameter distribution")



## test code for LDAr.r
# ## Get the top words in the cluster
# top.words <- top.topic.words(result$topics, 5, by.score=TRUE);
# top.topics <- top.topic.documents(result$document_sums, 
#                                   num.documents = 20, alpha = 0.1)
# 
# ## Statistical output
# wc <- word.counts(docs,vocab=vocabs);
# dl <- document.lengths(docs);

# ## Plot
# topic.proportions <- topic.proportions[sample(1:dim(topic.proportions)[1], N),];
# topic.proportions[is.na(topic.proportions)] <-  1/K;
# colnames(topic.proportions) <- apply(top.words, 2, paste, collapse=" ");
#
# topic.proportions.df <- melt(cbind(data.frame(topic.proportions),
#                                    document=factor(1:N)),
#                              variable.name="topic",
#                              id.vars = "document")  
# 
# qplot(topic, value, fill=document, ylab="proportion",
#       data=topic.proportions.df, geom="bar", stat="identity") +
#   theme(axis.text.x = element_text(angle=90, hjust=1)) +
#   coord_flip() +
#   facet_wrap(~ document, ncol=5)


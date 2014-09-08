# Load tnet and the network as a tnet object
#load library(tnet)
# set the proper directory i.e. setwd("~/Desktop/WMD_Analytics")
jan<-read.csv("January2010WMD-data.cdb.csv", header=TRUE, sep=",", stringsAsFactors=FALSE)
summary(jan)
jan.labels <- unique(c(jan[,"source"], jan[,"target"]))
jan.labels <- jan.labels[order(jan.labels)]
jan[,"source"] <- factor(x=jan[,"source"], levels=jan.labels)
jan[,"target"]   <- factor(x=jan[,"target"], levels=jan.labels)
jan <- data.frame(i=as.integer(jan[,"source"]), j=as.integer(jan[,"target"]), w=jan[,"weight"])  ####the weight is also converted to integer while trouble shooting in SQL
### Add up duplicated entries
jan <- jan[order(jan[,"i"], jan[,"j"]),]
index <- !duplicated(jan[,c("i","j")])
jan <- data.frame(jan[index,c("i","j")], w=tapply(jan[,"w"], cumsum(index), sum))
jan <- jan[jan[,"w"]>0,] ### # Take out (routes/ edges/ vertices/ paths?) with no value (cargo) ###>0 cause there should be no 0 in the weights
### Take out (routes/ edges/ vertices/ paths?) from a vertice to itself
jan <- jan[jan[,"i"]!=jan[,"j"],]
jan <- na.omit(jan)
jan <- as.tnet(jan, type="weighted one-mode tnet")

jan2 <- as.tnet(jan, type="weighted one-mode tnet") ###just by coding the type as it is R checks to make sure that the net is one way. . .
btTest <- betweenness_w(jan)
testc<-closeness_w(jan)
dgrtest<- degree_w(jan)
betweenness_w(jan)
closeness_w(jan)
degree_w(jan)
testigraph<- tnet_igraph(jan, type="weighted one-mode tnet")
plot(tnet_igraph(jan, type="weighted one-mode tnet")) ## that's how you plot, get the visualization # but how do you get a less crowded visual.

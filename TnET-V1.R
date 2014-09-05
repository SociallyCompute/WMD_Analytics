# http://toreopsahl.com/2011/08/12/why-anchorage-is-not-that-important-binary-ties-and-sample-selection/
# http://toreopsahl.com/tnet/software/one-mode-data-structure/

jan<-read.csv("January2010WMD-data.cdb.csv", header=TRUE, sep=",", stringsAsFactors=FALSE)
summary(jan)

jan.labels <- unique(c(jan[,"source"], jan[,"target"]))
jan.labels <- jan.labels[order(jan.labels)]
jan[,"source"] <- factor(x=jan[,"source"], levels=jan.labels)
jan[,"target"]   <- factor(x=jan[,"target"], levels=jan.labels)
jan <- data.frame(i=as.integer(jan[,"source"]), j=as.integer(jan[,"target"]), w=jan[,"weight"])

jan2 <- as.tnet(jan, type="weighted one-mode tnet")

btTest <- betweenness_w(jan)

# install.packages("RODBC")
# install.packages("lsa")
## Look at the networksis package for this data...
## Quite a gap between methods used in journals and the methods that
## are available for use.  R plays a role 

# !!!!!!! Be sure to change your working directory to the location of the files you will be reading in

rm(list=ls(all=TRUE))

library(tnet)
library(igraph)
library(lsa)
library(RODBC)
library(ggplot2)
library(blockmodeling)
igraph.par("print.vertex.attributes", TRUE)
igraph.par("print.edge.attributes", TRUE)

####################################################################
# NetworkData
####################################################################
networkList <- read.table("facebook_by_day_noHC_noTopic_results.txt",header=TRUE,row.names=NULL)
str(networkList)
# factors are important for data management in R
networkList$day_of_year <- factor(networkList$day_of_year)
networkList$topicId <- factor(networkList$topicId)
str(networkList)
# factors are important for data management in R
networkList$day_of_year <- factor(networkList$day_of_year)
networkList$topicId <- factor(networkList$topicId)
str(networkList)
# separate cut for header code list because its different.
headerCodeList <- read.table("facebook_headercodes_results.txt",header=TRUE,row.names=NULL)
str(headerCodeList)

# separate cut for topic list because its different.
topicList <- read.table("facebook_topics_results.txt",header=TRUE,row.names=NULL)
topicList$topicId <- factor(topicList$topicId)
str(topicList)

# create a factor of topic code by date
topicDay = interaction(networkList$day_of_year, networkList$headerCode)

allHeaderCodes <- unique(networkList$headerCode)
allDays <- unique(networkList$day_of_year)
allTopics <- unique(networkList$topicId)

# need to build a matrix of 
## most central actors
## network size
## network centraliztion
## network density
## subgroups
templateDay <- rep(0,length(allDays))
templateHC <- rep(0,length(allHeaderCodes)) 
templateTopic <- rep(0,length(allTopics)) 

dayBetFrame <- data.frame(x=templateDay)
dayDistFrame <- data.frame(x=templateDay)
dayInDegFrame <- data.frame(x=templateDay)
dayOutDegFrame <- data.frame(x=templateDay)
dayCloseFrame <- data.frame(x=templateDay)

HCBetFrame <- data.frame(x=templateHC)
HCDistFrame <- data.frame(x=templateHC)
HCInDegFrame <- data.frame(x=templateHC)
HCOutDegFrame <- data.frame(x=templateHC)
HCCloseFrame <- data.frame(x=templateHC)

topicBetFrame <- data.frame(x=templateTopic)
topicDistFrame <- data.frame(x=templateTopic)
topicInDegFrame <- data.frame(x=templateTopic)
topicOutDegFrame <- data.frame(x=templateTopic)
topicCloseFrame <- data.frame(x=templateTopic)



for(i in 1:length(allDays))
{
	day.i <- allDays[i]
	network.i <- networkList[networkList$day_of_year == day.i,]

	tnetNew <- data.frame(x=network.i$node1, y=network.i$node2, weight=network.i$weight)
	tnetNew.i <- as.tnet(tnetNew, type="weighted one-mode tnet")
	
	ids <- unique(c(tnetNew.i[,"i"], tnetNew.i[,"j"]))
	ids <- ids[order(ids)]
	# Calculate betweenness
	newBetween <- betweenness_w(tnetNew.i)
	# Extract active ids from output
	newBetween <- newBetween[newBetween[,"node"] %in% ids,]
	filename=paste("output/","day-betweenness",i,".csv")
	write.csv(newBetween, file=filename)
	# Calculate distance
	#newDistance <- distance_w(tnetNew.i)	
	# Extract active ids from output
	#newDistance <- newDistance[newDistance[,"node"] %in% ids,]
	#filename=paste("output/","day-distance",i,".csv")
	#write.csv(tnetNew.i, file=filename)
}








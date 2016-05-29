setwd("~/Dropbox/WebMD Dissertation/Analysis/Clustering/visulization")


library(RColorBrewer)
library(riverplot)

#####read coding book
inputFile <- "coding_book_full.csv"

# Read input file
myCorpus <- read.csv(inputFile, head = TRUE, na.strings=c("",".","NA"))
#myCorpus <- read.csv(inputFile, head = TRUE)

coding_book <- data.frame(myCorpus)



# Read input file
myCorpus <- read.csv(inputFile, head = TRUE, na.strings=c("",".","NA"))
#myCorpus <- read.csv(inputFile, head = TRUE)

number_to_code <- data.frame(myCorpus)


#####read origianl edge data
inputFile <- "topic_full.csv"

# Read input file
myCorpus <- read.csv(inputFile, head = TRUE, na.strings=c("",".","NA"))
#myCorpus <- read.csv(inputFile, head = TRUE)

topic_full <- data.frame(myCorpus)



####transform number to code first 
##change from factors to characters
topic_full[, c("seg", "N1", "N2")] <- lapply(topic_full[, c("N1", "N2")], as.character)
number_to_code[,c("code","original")] <-lapply(number_to_code[,c("code","original")], as.character)


iterations = nrow(topic_full)
variables = 3
iterations2 = nrow(number_to_code)
variables2 = 2

for (i in 1:iterations) {
  for (j in 1:variables)
    #print(tt[i,j])
    for (k in 1:iterations2)
      #print(tt1[k,])
      if (topic_full[i, 2] == number_to_code[k,1]) {
        topic_full[i, 2] <- number_to_code[k, 2]
      } 
}  
  
#####transform code to input for node positions

##change from factors to characters for coding book
coding_book[, c("rep", "ori","segment")] <- lapply(coding_book[, c("rep", "ori","segment")], as.character)


iterations = nrow(topic_full)
variables = 3
iterations2 = nrow(coding_book)
variables2 = 3

for (i in 1:iterations) {
  for (j in 1:variables)
    #print(tt[i,j])
    for (k in 1:iterations2)
      #print(tt1[k,])
      if (topic_full[i, 1] == coding_book[k,1] && (topic_full[i, 2]) == coding_book[k,3]) {
            topic_full[i, 2] == coding_book[k,2]
          } 
}
        





edges <- topic_full[,-1]
head(edges)










###############################replace to original

##change from factors to characters for coding book
tt1[, c("rep", "ori")] <- lapply(tt1[, c("rep", "ori")], as.character)

###replace edges 
iterations = nrow(edges)
variables = 2
iterations2 = nrow(tt1)
variables2 = 2

for (i in 1:iterations) {
  for (j in 1:variables)
    #print(tt[i,j])
    for (k in 1:iterations2)
      #print(tt1[k,])
      if (tt1[k, 1] == edges[i,j]) {
        edges[i,j] <- tt1[k, 2]
      }  
}

















tt <- myCorpus

##change from factors to characters
tt[, c("N1", "N2")] <- lapply(tt[, c("N1", "N2")], as.character)

edges <- tt



nodes = data.frame(ID = unique(c(edges$N1, edges$N2)), stringsAsFactors = FALSE)

nodes$x = as.integer(substr(nodes$ID, 2, 2))

nodes$y = as.integer(sapply(substr(nodes$ID, 1, 1), charToRaw)) - 65




###############################replace to original

##change from factors to characters for coding book
tt1[, c("rep", "ori")] <- lapply(tt1[, c("rep", "ori")], as.character)

###replace edges 
iterations = nrow(edges)
variables = 2
iterations2 = nrow(tt1)
variables2 = 2

for (i in 1:iterations) {
  for (j in 1:variables)
    #print(tt[i,j])
    for (k in 1:iterations2)
      #print(tt1[k,])
      if (tt1[k, 1] == edges[i,j]) {
        edges[i,j] <- tt1[k, 2]
      }  
}

###replace nodes
iterations = nrow(nodes)
variables = 1
iterations2 = nrow(tt1)
variables2 = 2

for (i in 1:iterations) {
  for (j in 1:variables)
    #print(tt[i,j])
    for (k in 1:iterations2)
      #print(tt1[k,])
      if (tt1[k, 1] == nodes[i,j]) {
        nodes[i,j] <- tt1[k, 2]
      }  
}



####control color
palette = paste0(brewer.pal(3, "Set1"), "30")
styles = lapply(nodes$y, function(n) {
  list(col = palette[n+1], lty = 0, textcol = "black")
})
names(styles) = nodes$ID


##constructing the object

rp <- list(nodes = nodes, edges = edges, styles = styles)

class(rp) <- c(class(rp), "riverplot")


##final plot
##final plot
plot(rp, plot_area = 0.95, yscale=0.06)



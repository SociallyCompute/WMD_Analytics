setwd("C:/Users/gloriaguo1986/Dropbox/WebMD Dissertation/Analysis/Longitudinal Clustering/tree")

library(kml)
library(plyr)
library(cluster)
library(NbClust)
#if(!require(devtools)) install.packages("devtools")
#devtools::install_github("kassambara/factoextra")
#library(modeest)
library(factoextra)
#library(mice)
library(digest)
#install_github("ggbiplot", "vqv")
#library(ggbiplot)
#library(vqv)



inputFile <- "count_input.csv"

#inputFile <- "normalized reduce dimension_final.csv"

# Read input file
myCorpus <- read.csv(inputFile, head = TRUE, na.strings=c("",".","NA"))
#myCorpus <- read.csv(inputFile, head = TRUE)

##switch colums and rows
myCorpus <- data.frame(myCorpus)

##transform percentation to numeric
myCorpus2 <- myCorpus[,-1]


###scale data
output <- as.matrix(myCorpus2)

output <- apply(output, MARGIN = 1, FUN = function(X) (X - min(X))/diff(range(X)))

#switch colums and row
output <- data.frame(t(output))


####PCA analysis
iris <- output

ir.pca <- prcomp(iris, center = TRUE)
#print (ir.pca)

fviz_screeplot(ir.pca, ncp=10)

fviz_pca_var(ir.pca, col.var="steelblue")+
  theme_minimal()

#plot(ir.pca, type = "l")
summary(ir.pca)

####PCA analysis
iris <- output

library(FactoMineR)

res.pca <- PCA(iris, graph = FALSE)

eigenvalues <- res.pca$eig
eigenvalues <- eigenvalues[1:28, ]

barplot(eigenvalues[, 2], names.arg=1:nrow(eigenvalues), 
        main = "Variances",
        xlab = "Principal Components",
        ylab = "Percentage of variances",
        col ="steelblue")
# Add connected line segments to the plot
#lines(x = 1:nrow(eigenvalues), eigenvalues[, 2], 
#     type="b", pch=19, col = "red")



####

scores_existing_df <- as.data.frame(ir.pca$x)

scores_existing_df[21:28]

####48 pc explain more than 80% of the variance


#tt <- predict(ir.pca, newdata = iris)
#tt[, 1:10]


biplot(ir.pca)


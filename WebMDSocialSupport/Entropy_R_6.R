setwd("C:/Users/wxdg5/Dropbox/WebMD dissertation/Analysis/Entropy/Entropy input")

library(nonlinearTseries)
library(entropy)
library(rainbow)


# Read input file
inputFile <- "add_and_adhd_exchange_final_format.csv"

y <- read.csv(inputFile, head = TRUE)

core <- y[, 1]
core <- core[!is.na(core)]

periphery <- y[, 2]
periphery <- periphery[!is.na(periphery)]


xperiphery <- y[, 3]
xperiphery <- xperiphery[!is.na(xperiphery)]


##calcualte core entropy
core1 <- entropy(core, method="ML")
core2 <- entropy(core, method="MM")
core3 <- entropy(core, method="Jeffreys")
core4 <- entropy(core, method="Laplace")
core5 <- entropy(core, method="SG")
core6 <- entropy(core, method="minimax")
core7 <- entropy(core, method="CS")


##calcualte periphery entropy
periphery1 <- entropy(periphery, method="ML")
periphery2 <-entropy(periphery, method="MM")
periphery3 <-entropy(periphery, method="Jeffreys")
periphery4 <-entropy(periphery, method="Laplace")
periphery5 <-entropy(periphery, method="SG")
periphery6 <-entropy(periphery, method="minimax")
periphery7 <-entropy(periphery, method="CS")


##calcualte xperiphery entropy
xperiphery1 <- entropy(xperiphery, method="ML")
xperiphery2 <- entropy(xperiphery, method="MM")
xperiphery3 <- entropy(xperiphery, method="Jeffreys")
xperiphery4 <- entropy(xperiphery, method="Laplace")
xperiphery5 <- entropy(xperiphery, method="SG")
xperiphery6 <- entropy(xperiphery, method="minimax")
xperiphery7 <- entropy(xperiphery, method="CS")

##combine entropy for each calcuation 
entropy1 <- c(core1, periphery1, xperiphery1)
entropy2 <- c(core2, periphery2, xperiphery2)
entropy3 <- c(core3, periphery3, xperiphery3)
entropy4 <- c(core4, periphery4, xperiphery4)
entropy5 <- c(core5, periphery5, xperiphery5)
entropy6 <- c(core6, periphery6, xperiphery6)
entropy7 <- c(core7, periphery7, xperiphery7)



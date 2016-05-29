setwd("C:/Users/wxdg5/Dropbox/WebMD dissertation/Analysis/Granger Causality and Dynamic Bayesian")

##http://www.r-bloggers.com/chicken-or-the-egg-granger-causality-for-the-masses/

#install.packages("lmtest")
#install.packages("forecast")


library(lmtest)
library(forecast)

inputFile <- "granger_file copy.csv"

# Read input file
chickegg <- read.csv(inputFile, head = TRUE, stringsAsFactors=FALSE, fileEncoding="latin1")

head(chickegg)

attach(chickegg)

# plot the time series
par(mfrow=c(2,1))

plot.ts(chicken)

plot.ts(egg)


################forecast
# test for unit root and number of differences required, you can also test for seasonality with nsdiffs
ndiffs(chicken, alpha=0.05, test=c("kpss"))

ndiffs(egg, alpha=0.05, test=c("kpss"))

# differenced time series
dchick <- diff(chicken)

degg <- diff(egg)

plot.ts(dchick)

plot.ts(degg)


# do eggs granger cause chickens?
grangertest(dchick ~ degg, order=4)

#autoamtically search for the bset lag result

for (i in 1:3)
{
  cat("LAG=", i)
  print(grangertest(dchick ~ degg, order=i))
}












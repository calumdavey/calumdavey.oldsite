# Executable example of double robust estimator 

# Set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load data (just one round)
load('dummy_data.RDS')

# Remove missing data 
d <- d[complete.cases(d),]
d <- d[d$Outcome!=999 & d$Exposure!=999,]

# Load packages
library("boot")
library("survey")
library("MASS")

# Double-robust function 
DR <- function(d, indices){
  # Get the stabilised weights 
    # Numerator and denominator 
    p_n <- polr(Exposure ~ 1, data = d, method='logistic')
    p_d <- polr(Exposure ~ Cat.confounder + Num.confounder, 
               data = d, method='logistic')
    # Calculate the weights, selected based on the observed exposure 
    d$n <- apply(cbind(d$Exposure, predict(p_n, type = 'probs')), 1, function(x) x[x[1]+1])
    d$d <- apply(cbind(d$Exposure, predict(p_d, type = 'probs')), 1, function(x) x[x[1]+1])
    d$w <- d$n/d$d
  # Make copies of the data for the standarisation
  dd <- d
  dd$int <- -1 # Treatment unchanged
  for (l in names(table(d$Exposure)[table(d$Exposure)!=0])){ 
    ddd <- d
    ddd$int <- which(l == names(table(d$Exposure)[table(d$Exposure)!=0]))
    ddd$Exposure <- l # treatment set to each level of exposure
    ddd$Outcome  <- NA # but the outcome missing so not used in estimation
    dd <- rbind(dd, ddd)
  }
  # Run model for outcome with weight as a coefficient 
  p_dr <- glm(Outcome ~ Exposure + Cat.confounder + Num.confounder + w,
              data= dd, family=poisson(link='log'))
  # Predict the means 
  dd$pY <- predict(p_dr, dd)
  # Estimate the mean outcomes 
  m <- c() 
  for (l in names(table(dd$Exposure)[table(dd$Exposure)!=0])){
    m <- c(m,exp(mean(dd[which(dd$int==(which(l==levels(dd$Exposure)))),]$pY)))
  }
  return(m)
}

# Bootstrap the analysis; get 95% CI and RRs
  results <- boot(data=d, statistic=DR, R=25, parallel="multicore")
  
  # Store the prevalences & calculate 95% CI
  m1 <- cbind(results$t0, apply(results$t,2,sd))
  m1 <- cbind(m1[,1], apply(m1,1,function(x) x[1]-qnorm(.975)*x[2]),
                      apply(m1,1,function(x) x[1]+qnorm(.975)*x[2]))
  
  # Quick function to calculate the RR
  calc.RR <- function(x){  
    t1 <- c(); for (i in 2:length(x)){
      t <- x[i]/x[1]; t1 <- c(t1,t)
    }
    return(t1)  
  }  
  m2 <- cbind(calc.RR(results$t0), apply(apply(results$t, 1, calc.RR),1,sd))
  m2 <- cbind(m2[,1], apply(m2,1,function(x) x[1]-qnorm(.975)*x[2]),
                      apply(m2,1,function(x) x[1]+qnorm(.975)*x[2]))
  
  # Put the adjusted prevalence and the RRs in a list 
  results <- list(m1,m2)
  
results  
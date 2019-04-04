# PENDA Deworm3 simulated precision estimates 

n <- 2000 # 2000 disabled children, 2000 non-disabled 
d <- matrix(,nrow=n*2, ncol=4) # Create data 
d[,1] <- rep(c(0,1),times=c(n,n)) # Code disabled, and non-disabled (1,0)
c <- 40 # total number of clusters 
d[,2] <- rep(rep(seq(1,c,1), times=rep(n/c, times=c)),times=2)

# Set assummed population-level parameters 
e0_p <- c(.7) # enrolment of non-disabled children 
e1_p <- c(.5) # enrolment of disabled children 
k <- c(.01) # Set intercluster coefficient of variation
var_b1 <- k/e1_p
var_b2 <- k/e0_p
# Fix true cluster-level means of the outcome 
e1_c <- rnorm(40, e1_p, var_b1^.5)
e0_c <- rnorm(40, e0_p, var_b2^.5)
d[,3] <- c(rep(e0_c, times=rep(n/c, times=c)),
           rep(e1_c, times=rep(n/c, times=c)))
  # Do need a way to avoid values >1 or <0

# Generate enrolment outcome 
i <- 1
while (i<=1000){
  d <- cbind(d, apply(d, 1, function(x) sample(c(0,1),size=1,prob=c(1-x[3],x[3]))))
  i <- i+1
}

# Calculate sample enrolment figures 
p0 <- apply(d[d[,1]==0, 5:ncol(d)], 2, mean)
p1 <- apply(d[d[,1]==1, 5:ncol(d)], 2, mean)
diff <- apply(cbind(p0,p1),1,function(x) x[1]-x[2])

# Plot the results 
hist(p0, xlim=c(0.1,.8),ylim=c(0,50), main='',
     xlab='R or RD', freq=F)
hist(p1, add =T, freq=F)
hist(diff, xlab = 'RD',add=T, freq=F)
lines(density(diff),col='red')




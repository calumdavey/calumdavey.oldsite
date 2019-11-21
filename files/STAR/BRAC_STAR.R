# BRAC STAR+ sample size 
# 01 NOV 2019 
# LSHTM 

#install.packages('clusterPower')
library(clusterPower)

# Set the parameters 
# Assume mean community 10,000, SD 5,000
# 1/5 age between 14-24, and 2% disabled 
# therefore mean of 10,000 * .2 * 0.02 = 40 eligible people per cluster, SD=20
m0 <- 40
# m_sd <- 20 # leaving this as constant, although should vary 

# Assume that the effect of STAR+ similar to STAR, from table 5.3 in STAR eval report, weighted by gender balance in 5.1
p_t <- .88*.71 + (1-.88)*.41
# but that the control arm will perform less well, also from table 5.3 in STAR eval report, weighted by gender balance in 5.1
# e.g. assume the trend over time will be more like the women in the STAR eval 
p_c <- .88*.66 + (1-.88)*.23 # this is the overall employment level for the STAR report 
p_c <- p_c * seq(.5,1,.1)

# ICC
icc <- seq(0.1,0.4,0.05)

# Build the scenario dataset 
d <- cbind(rep(p_c,times=length(icc)), rep(icc,each=length(p_c)))
d <- cbind(d, rep(p_t, nrow(d)), rep(m0, nrow(d)))

# Sample size calcs 
d <- cbind(d, apply(d,1,function(x) crtpwr.2prop(n=x[4], p1=x[1], p2=x[3], icc=x[2])))

# Plot the results 
plot(d[,1], d[,5], xlab='Control p', ylab='Clusters per arm', bty="n", pch='.',
     main='Number of clusters per arm\nwith p in intervention arm .67')
abline(h=seq(50,350,50), col='gray80')
for (j in unique(d[,2])){
  lines(x=d[d[,2]==j,1],y=d[d[,2]==j,5])
}
abline(h = 25, col='red')
mtext(icc, side=4, at=d[d[,1]==max(p_c),5], las=1)
text(x=.355,y=30,labels='25 clusters per arm', col='red')


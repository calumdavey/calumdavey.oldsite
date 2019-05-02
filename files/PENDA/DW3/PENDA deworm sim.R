# Set the design parameters for the study 

library(openxlsx)
library(dplyr)
# Load the number of people enumerated in each cluster 
N <- openxlsx::read.xlsx('Cluster Population CE1.xlsx')
N[,3] <- round(N[,2]*(2400/sum(N[,2])),0) # back-calc for the proportion of CWD in each cluster 
N[,4] <- round(N[,2]*(2400/(sum(N[,2]*0.05))),0) # back-calc for the total children in each cluster 
colnames(N) <- c('cluster','N','N_cwd','N_c')
head(N)

# Number of simulations to run 
j <- 5000
# Matrix to save the results 
d <- matrix(, ncol=0, nrow=j)

es <- c(.4,.5,.6,.7,.75)

for (i in es){
# Set assummed population-level parameters 
# Enrolment 
e0 <- c(.75) # enrolment of all children 
e1 <- c(i) # enrolment of disabled children 
k <- c(.05) # Set intercluster coefficient of variation 
var_b0 <- k/e0 # Calculate the variance of the cluster proportions enrolled  
var_b1 <- k/e1 # Calculate the variance of the cluster proportions enrolled 
# Fix true cluster-level means of school enrollment 
rnorm_0_1 <- function(p, v){
  r <- 1
  while (r>=1 | r<=0){
    r <- round(rnorm(1, p, v^.5),2)
  }
  return(r)
}

N$e_0 <- apply(N, 1, function(x) rnorm_0_1(e0, var_b0))
N$e_1 <- apply(N, 1, function(x) rnorm_0_1(e1, var_b1))

# True relationship between enrollment and treatment in school-treatment arm
a0 <- c(.8) # 80% of enrolled children are in school and treated 
a1 <- c(.7) # 70% of enrolled children with disabilities are in school and treated 
# True proportions treated by the intervention
var_b0 <- k/a0 # Calculate the variance of the cluster attendance if enrolled 
var_b1 <- k/a1 # Calculate the variance of the cluster attendance if enrolled   
# Fix the true cluster-level means of the attendance at school if enrolled 
N$a_0 <- apply(N, 1, function(x) rnorm_0_1(a0, var_b0))
N$a_1 <- apply(N, 1, function(x) rnorm_0_1(a1, var_b1))

# Allocate half clusters to treatment and half to control  
N$allocation <- sample(c(rep(0,length.out=(nrow(N)/2)),rep(1,length.out=nrow(N)/2)))

# Proportion treated in each cluster == 
# School-only arm: proportion enrolled * proportion in school if enrolled 
N$t_0 <- N$e_0 * N$a_0 # all children
N$t_1 <- N$e_1 * N$a_1 # children with disabilities 
# Community arm: set at 98% with small se
t_comm <- .98
var_t_comm <- k/t_comm
N$t_1[N$allocation == 1] <- apply(N[N$allocation == 1,], 1, function(x) rnorm_0_1(t_comm, var_t_comm))
N$t_0[N$allocation == 1] <- apply(N[N$allocation == 1,], 1, function(x) rnorm_0_1(t_comm, var_t_comm))

# Generate enrolment outcome 
# Number of treated children overall, and number of treated disabled children 
i <- 1
t_0 <- matrix(, ncol=0, nrow=nrow(N))
t_1 <- matrix(, ncol=0, nrow=nrow(N))
while (i<=j){
  t_0 <- cbind(t_0, apply(N, 1, function(x)
    sum(sample(c(0,1),size=x[2],prob=c(1-x['t_0'],x['t_0']),replace=T))))
  t_1 <- cbind(t_1, apply(N, 1, function(x)
    sum(sample(c(0,1),size=x[3],prob=c(1-x['t_1'],x['t_1']),replace=T))))
  i <- i+1
}

## Conduct analysis on simulated data 
# Produce proportions treated in CWD and in children without disabilities 
# First need to subtract the number od disabled children treated from the number of non-disabled children treated 
t_0 <- t_0 - t_1
# And the denominators 
N_0 <- N[,2] - N[,3]

# Calculate the proportions 
t_0_p <- t_0 / N_0
t_1_p <- t_1 / N[,3] 

# Append the allocation 
t_0_p <- cbind(t_0_p, N$allocation)
t_1_p <- cbind(t_1_p, N$allocation)

# Disparity between all children and CWD
diff_p <- t_0_p[,1:(ncol(t_0_p)-1)] - t_1_p[,1:(ncol(t_1_p)-1)]
diff_p <- cbind(diff_p, N$allocation)

# Calculate sample enrolment figures 
p0_sc   <- as.data.frame(t_0_p) %>% filter(V5001==0) %>% select(-V5001) %>% apply(2, mean)
p1_sc   <- as.data.frame(t_1_p) %>% filter(V5001==0) %>% select(-V5001) %>% apply(2, mean)
p0_comm <- as.data.frame(t_0_p) %>% filter(V5001==1) %>% select(-V5001) %>% apply(2, mean)
p1_comm <- as.data.frame(t_1_p) %>% filter(V5001==1) %>% select(-V5001) %>% apply(2, mean)

# Median disparity in each arm
diff_sc <- as.data.frame(diff_p) %>% filter(V5001==0) %>% select(-V5001) %>% apply(2, mean)
diff_comm <- as.data.frame(diff_p) %>% filter(V5001==1) %>% select(-V5001) %>% apply(2, mean)

# Difference in the disparity between the arms 
diff_in_disp <- diff_sc - diff_comm

d <- cbind(d,diff_in_disp)
}


# Plot the differences in the disparities s
plot(density(d[,1]),col='red',ylim=c(0,30), main='', xlab='Difference in disparity', 
     freq=F, xlim=c(0,.6),bty="n")
lines(density(d[,2]), col='red')
lines(density(d[,3]), col='red')
lines(density(d[,4]), col='red')
lines(density(d[,5]), col='red')
text(x=apply(d,2,mean), y=rep(25, times=ncol(d)), labels = as.character(es*100))

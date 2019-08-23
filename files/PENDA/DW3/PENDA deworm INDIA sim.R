# Set the design parameters for the study 

rnorm_0_1 <- function(p, s){
  r <- 1; while (r <= 0 | r>=1){r <- rnorm(1, p, s)}; return(r)
}

sampler <- function(K){
  k <- K # k = standard deviation of cluster means / grand mean 

  # Load the number of people enumerated in each cluster 
  Ns <- round(rnorm(40, 150000/40, (k*150000/40)), 0)
  
  # Estimate the proportion children, and the proportion of the children that have functional impairment 
  child <- Ns * rnorm(40, .4, k*.4)
  child_d <- round(child * rnorm(40, 87603/8685914, k* 87603/8685914),0)
  child_nd <- round(child - child_d, 0)
  
  # Enrolment ages 6-13 overall in Tamil Nadu
  # https://mhrd.gov.in/sites/upload_files/mhrd/files/upload_document/National-Survey-Estimation-School-Children-Draft-Report.pdf
  # Proportion all children in school: Table C2.3
  e0 <- c(1-(57529-23627)/(8685914-87603))
  # Proportion disabled children in school: Tables C8 and C9
  e1 <- c(1-23627/87603)
  
  # Proportion in school in each cluster for children with and without disabilities
  prop_in_school_nd <- replicate(40, rnorm_0_1(e0, k*e0), simplify = TRUE)
  prop_in_school_d  <- replicate(40, rnorm_0_1(e1, k*e1), simplify = TRUE)
  
  # Proportion treated by community: cluster-specific around 95% coverage for all children
  treated_comm_nd <- replicate(40, rnorm_0_1(.95, k*.95), simplify = TRUE)
  treated_comm_d <- replicate(40, rnorm_0_1(.95, k*.95), simplify = TRUE)

  # Proportion treated in school: cluster-specific around 95% coverage for all children in school
  treated_scho_nd <- treated_comm_nd * prop_in_school_nd
  treated_scho_d  <- treated_comm_d * prop_in_school_d
  
  # Allocate half clusters to treatment and half to control  
  allocation <- sample(c(rep(0,length.out=(length(Ns)/2)),rep(1,length.out=length(Ns)/2)))
  
  # Means of the cluster proportions treated, weighted by cluster size 
  treated_comm_mean_nd <- weighted.mean(treated_comm_nd[allocation == 1], child_nd[allocation == 1])
  treated_comm_mean_d  <- weighted.mean(treated_comm_d[allocation == 1], child_d[allocation == 1])
  treated_scho_mean_nd <- weighted.mean(treated_scho_nd[allocation == 0], child_nd[allocation == 0])
  treated_scho_mean_d  <- weighted.mean(treated_scho_d[allocation == 0], child_d[allocation == 0])
  
  # Calculate the disparity 
  d_nd <- treated_comm_mean_nd - treated_scho_mean_nd
  d_d  <- treated_comm_mean_d - treated_scho_mean_d
  dd   <- d_nd - d_d
  return(dd)
}

dd_25 <- replicate(10000, sampler(.25))
dd_35 <- replicate(10000, sampler(.35))
dd_15 <- replicate(10000, sampler(.15))

# Plot the differences in the disparities
density_25 <- density(dd_25, bw=0.05)
density_15 <- density(dd_15, bw=0.05)
density_35 <- density(dd_35, bw=0.05)

plot(density(dd_15), col='green', main='',  
     xlab='Difference in disparity', bty="n", xlim=c(min(density_35$x),max(density_35$x)),lwd=2)
lines(density_35, col='red',lwd=2)
lines(density_25, col='blue',lwd=2)
legend(x=.2,y=6,bty='n',legend=c('k=.15','k=.25','k=.35'),lty=1, col=c('green','blue','red'))


# Three step cascade 
# Dots for site-specific values 
# No confidence intervals 

library(openxlsx)
library(stringr)

# Read the data (requires package openxlsx)
d <- read.xlsx('data.xlsx', sheet = 2)
c <- unique(d$level)

# Extract the cascade levels being shown
y <- d$percentage
# Extract the site-specfic values
s <- d[,5:length(d)]
# Set x-axis values for the years for each value 
x <- c(.01, .055, .1, 
       #.11, .155, .2, 
       .21, .255, .3,
       .31, .355, .4,
       .41, .455, .5)
xy <- cbind(x[1:length(y)],y,s)
pt <- rep(c(15,21,19), times=length(y))

# Save PNG
png(filename = 'Cascade.png', width = 8, height = 8, units = 'in', res = 300)

# Create the plot and the points 
par(mar=c(1,5,2,1))
plot(xy[,1:2], ylim=c(-.1,1), xlim=c(0.01,(max(xy[,1]))), yaxt="n", xaxt="n", type='n',
     pch=pt, bty="n", xlab="", ylab="RDS-adjusted proportions in all women", cex.lab=.6)

# Add the site-specific points 
for (c in 3:length(xy)){
  p <- xy[,c(1,c)]  
  points(p, pch=20, cex=1, col='gray70')
}

# Add the sloping lines 
for (r in seq(1, by=3, length.out = length(y)/3)){
  lines(xy[r:(r+1),1], xy[r:(r+1),2], type="l", lwd=1.7)
  lines(xy[(r+1):(r+2),1], xy[(r+1):(r+2),2], type="l", lwd=1.7)
}

# Add the vertical lines
for (r in c(1, 3, 4, 6, 7, 9, 11, 12)){
  lines(c(xy[r,1],xy[r,1]),c(0,xy[r,2]), lwd=.6)
}

# Add the points
points(xy, pch=pt, bg='white')

# Add the labels 
for (i in 1:nrow(xy)){
  text(xy[i,1]+0.01, xy[i,2]-.025,
       labels = paste0(round(xy[i,2]*100,0),'%'), 
       cex = .6)
}

# Add horizontal line at bottom
lines(c(0.01,.71), c(0,0))

# Add the 90:90:90 lines
nnn <- c(.9,          # First 90 for diagnosis 
         .9*.9,       # Second 90 for treatment  
         .9*.9*.9)    # Third 90 for suppression 

lines(c(x[4],x[6]),  c(nnn[1],nnn[1]),lty=2)
lines(c(x[7],x[9]),  c(nnn[2],nnn[2]),lty=2)
lines(c(x[10],x[12]),c(nnn[3],nnn[3]),lty=2)

text(x[6]-.005,nnn[1]+.02,labels=paste0("90"), cex=.6)
text(x[9]-.005,nnn[2]+.02,labels=paste0("81"), cex=.6)
text(x[12]-.005,nnn[3]+.02,labels=paste0("73"), cex=.6)

# Add axes     
ap <- c(0,.2,.4,.6,.8, 1)
axis(2, at=ap, lab=paste0(ap * 100, "%"), las=TRUE, cex.axis=0.6)

xp <- c(.05, #.15, 
        .25, .35, .45)    
text(xp[1:(length(y)/3)],c(-.03), 
     labels=str_wrap(unique(d$level),25), cex=.8)

legend(0,.99,c("2011: 3 sites (N=836)", 
               "2013: 14 sites (N=2,722)",
               "2016: 17 sites (N=5,390)"),
       pch=c(15,21,19), bty="n", cex=.7)
dev.off()
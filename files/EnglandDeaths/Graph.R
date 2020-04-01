# ENGLAND AND WALES DEATHS 
# 2020 04 01 
# CALUM DAVEY 

# Load data 
d <- read.csv('DeathsPerMonth.csv',as.is = T)

# Get colours 
cols <- colorRampPalette(c('white','purple'))
cols <- c(cols(length(unique(d$Year))-1),'blue')

# Plot deaths in each month
plot(1,1,type='n',bty='n', axes=F,
     xlim=c(1,12),
     ylim=c(min(d$Deaths), max(d$Deaths)),
     xlab='Month', ylab='Deaths')

# Add gridlines
grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted", lwd = par("lwd"), equilogs = F)

for (i in unique(d$Year)){
  pd <- d[d$Year==i,]
  lines(pd$Month, pd$Deaths,
        col=cols[i-2008])
}

# Add axes 
axis(1,lwd=0,at=c(1:12),cex=.6)
ats <- seq(35000,65000,by=10000)
axis(2,lwd=0,las=2,at=ats,labels=sub('000','k',as.character(ats)))

# Add legend 
legend(x='topright',
       legend=unique(d$Year),col=cols,
       bty='n', cex=.6,lty=1,ncol=5)

# Add the title
mytitle = "Deaths in England and Wales"
mysubtitle = "Arranged by month for each year 2009-2020"
mtext(side=3, line=2, at=-0.07, adj=0, cex=1, mytitle)
mtext(side=3, line=1, at=-0.07, adj=0, cex=0.7, mysubtitle)



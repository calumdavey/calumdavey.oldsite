


# https://migrationobservatory.ox.ac.uk/resources/briefings/long-term-international-migration-flows-to-and-from-the-uk/
d <- read.csv('net-migration-by-citizen.csv')  

# Graph of migration to the UK, EU and non-EU 
par(lwd=2)
plot(d[,1],d[,4],typ='l',bty='n',xlab='Year',ylab='Thousands',col='green',ylim=c(0,360))
lines(d[,1],d[,5],col='blue')
abline(v=2004)

# Add EU migration after 2003
m91_03 <- median(d[1:13,5]) # but subtract the median migration before 2003
d$nonEU.plus <- d$Non.EU + d$EU - m91_03
d[1:14,6] <- d[1:14,4]
b
lines(d[14:nrow(d),1],d[14:nrow(d),6], col='red')

# Total non-EU migrants not in UK since 2003
sum(d[14:nrow(d),6]-d[14:nrow(d),5])
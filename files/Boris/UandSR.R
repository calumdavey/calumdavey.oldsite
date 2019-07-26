# Uxbridge and South Ruislip 
library(rvest)

# Declare the location of the data 
url <- 'https://en.wikipedia.org/wiki/Uxbridge_and_South_Ruislip_(UK_Parliament_constituency)'

# Read the HTML
page <- read_html(url)

# Create tables 
x17 <- html_table(html_nodes(page, xpath=paste0('//*[@id="mw-content-text"]/div/table[3]')))[[1]]
x15 <- html_table(html_nodes(page, xpath=paste0('//*[@id="mw-content-text"]/div/table[4]')))[[1]]
x10 <- html_table(html_nodes(page, xpath=paste0('//*[@id="mw-content-text"]/div/table[5]')))[[1]]

# Plot Con and Lab
par(lwd=2)
plot(x=1,y=1,type='n', xlim=c(2010,2019), ylim=c(0,100),
     xlab='Year', ylab='%', bty='n')
lines(x=c(2010,2015,2017),
      y=c(as.numeric(x10[x10[,2]=='Conservative','%']),
          as.numeric(x15[x15[,2]=='Conservative','%']),
          as.numeric(x17[x17[,2]=='Conservative','%'])),col='blue')
lines(x=c(2010,2015,2017),
      y=c(as.numeric(x10[x10[,2]=='Labour','%']),
          as.numeric(x15[x15[,2]=='Labour','%']),
          as.numeric(x17[x17[,2]=='Labour','%'])),col='red')
lines(x=c(2010,2015,2017),
      y=c(as.numeric(x10[x10[,2]=='Turnout','%']),
          as.numeric(x15[x15[,2]=='Turnout','%']),
          as.numeric(x17[x17[,2]=='Turnout','%'])))

# Calculate hypothetical: turnout 80%, 80% of new votes for lab
electors <- as.numeric(sub(',','',x17[x17[,2]=='Registered electors','Votes']))
turnout  <- as.numeric(sub(',','',x17[x17[,2]=='Turnout','Votes']))
con <- as.numeric(sub(',','',x17[x17[,2]=='Conservative','Votes']))
lab <- as.numeric(sub(',','',x17[x17[,2]=='Labour','Votes']))
hypo_turnout <- .8 * electors
hypo_con     <- 100*(con + .2 * (hypo_turnout-turnout))/hypo_turnout
hypo_labour  <- 100*(lab + .8 * (hypo_turnout-turnout))/hypo_turnout

# Add the lines 
lines(x=c(2017,2019),
      y=c(as.numeric(x17[x17[,2]=='Turnout','%']),80), lty=2)
lines(x=c(2017,2019),
      y=c(as.numeric(x17[x17[,2]=='Conservative','%']),hypo_con), lty=2, col='blue')
lines(x=c(2017,2019),
      y=c(as.numeric(x17[x17[,2]=='Labour','%']),hypo_labour), lty=2, col='red')


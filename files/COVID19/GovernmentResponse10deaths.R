# Government responses 
# Calum Davey 
# 25 MAR 2020

library(readxl)
library(httr)

# LOAD DATA FROM OXFORD COVID-19 GOVERNMENT RESPONSE TRACKER
url <- "https://www.bsg.ox.ac.uk/sites/default/files/OxCGRT_Download_latest_data.xlsx?raw=true"
GET(url, write_disk(tf <- tempfile(fileext = ".xlsx")))
df <- read_excel(tf)

# CLEAN UP THE DATA 
df$Date <- as.Date(as.character(df$Date), "%Y%m%d")
# EXPLORE THE STRINGNCY OF CONTROL 
# Names of countries with 10 or more deaths 
countries <- c("Italy","Spain","France","Germany","USA","UK") # "Japan" mostly missing?
# Rename in df
df$CountryName[df$CountryName=='United Kingdom'] <- 'UK'
df$CountryName[df$CountryName=='United States']  <- 'USA'

# Choose colours for each country 
# install.packages('RColorBrewer')
library(RColorBrewer)
cols <- brewer.pal(length(countries), 'Dark2')

par(oma=c(2,0,0,0))
plot(1, type = 'n', 
     bty = 'n', # no border around the plot 
     xlim = c(0,25), # would be better to make this dynamic 
     ylim = c(0,100),
     axes = FALSE, 
     xlab='',
     ylab='Stringency',
     sub='Data from Oxford COVID-19 Government response tracker\nhttps://www.bsg.ox.ac.uk/sites/default/files/OxCGRT_Download_latest_data.xlsx',
     cex.sub=.7,
     cex.lab=.7)

# Add gridlines 
grid(nx = NULL, ny = NULL, col = "lightgray", lty = "dotted", lwd = par("lwd"), equilogs = F)

for (country in countries){
  plot_df <- df[df$CountryName==country & !is.na(df$StringencyIndex) & df$ConfirmedDeaths>=5,]
  # Add the lines 
  lines((1:nrow(plot_df)),plot_df$StringencyIndex,
        col=cols[which(countries==country)])
  # Add a label
  text(x=nrow(plot_df), 
       y=plot_df$StringencyIndex[nrow(plot_df)],
       label=paste0(country), 
       pos=4, offset=.1, cex=.6, font=1,
       col=cols[which(countries==country)])
}

# Add axes, title
axis(1, lwd=0, cex.axis=.7)
axis(2, lwd=0, las=1, cex.axis=.7)

# Add titles
mytitle = "Stringency of government response to COVID-19"
mysubtitle = "Arranged by number of days since 10 or more deaths"
mtext(side=3, line=2, at=-0.07, adj=0, cex=1, mytitle)
mtext(side=3, line=1, at=-0.07, adj=0, cex=0.7, mysubtitle)

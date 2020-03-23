# COVID DEATHS GRAPHS 
# CALUM DAVEY
# LSHTM 
# 22 MAR 2020

# LOAD THE DATA 
data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")

# DATA MANAGEMENT 
# Names of selected countries 
countries <- c("Italy","Spain","France","Germany","US","Japan","United Kingdom")

# Keep data for selected countries 
data <- data_raw[data_raw$`Country.Region` %in% countries, ]

# Keep only country (column 2) and the columns 
# with the cases per day (columns 5 onward)
data <- data[, c(2, c(5:ncol(data)))]

# Change the data from 'wide' to 'long'
data <- reshape(data = data, 
                direction = 'long',
                varying = c(2:ncol(data)),
                sep='', new.row.names=NULL)

# Identify the dates as dates in the data 
data$time <- as.Date(data$time, "%m.%d.%y")

# Group the data by country and time, with the sum of cases 
data <- aggregate(data$X, 
                  list(data$Country.Region, data$time),
                  'sum')

# Only keep days with 10 or more deaths 
data <- data[data$x>=10,]

# PLOTTING THE DATA 
# Choose colours for each country 
# install.packages('RColorBrewer')
library(RColorBrewer)
cols <- brewer.pal(length(countries), 'Dark2')

# Start with an 'empty' plot of Italy 
plot_data <- data[data$Group.1=='Italy', ]

plot(plot_data$x, type = 'n', 
     log = 'y', # y-axis is on the log scale 
     bty = 'n', # no border around the plot 
     xlim = c(1,(nrow(plot_data)+4)),
     axes = FALSE, bg='gray80',
     xlab='Days after 10 confirmed deaths',
     ylab='Confirmed deaths (log scale)',
     cex.lab=.7)

# Add gridlines 
grid(nx = NULL, ny = NULL, col = "lightgray", lty = "dotted", lwd = par("lwd"), equilogs = F)

# Add each of the other countries 
for (country in countries){
  plot_data <- data[data$Group.1 == country,]
  # Plot the lines 
  lines(c(1:nrow(plot_data)), plot_data$x, 
        col=cols[which(countries==country)])
  # Add a label
  text(x=nrow(plot_data), y=max(plot_data$x),
       label=paste0(country,' (',nrow(plot_data),' days)'), 
       pos=4, offset=.1, cex=.5,
       col=cols[which(countries==country)])
}

# Add the axes 
axis(1, lwd=0, cex.axis=.7)
axis(2, lwd=0, las=1, cex.axis=.7)

# Add titles
mytitle = "Covid-19 deaths"
mysubtitle = "Arranged by number of days since 10 or more deaths"
mtext(side=3, line=2, at=-0.07, adj=0, cex=1, mytitle)
mtext(side=3, line=1, at=-0.07, adj=0, cex=0.7, mysubtitle)

# COVID DEATHS GRAPHS 
# CALUM DAVEY
# LSHTM 
# 22 MAR 2020

# LOAD THE DATA 
data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv",
                     as.is = TRUE)

# DATA MANAGEMENT 
# Names of selected countries 
countries <- c("US")

# Keep data for selected countries 
data <- data_raw[data_raw$`Country.Region` %in% countries, ]

# Keep only state (column 1) and the columns 
# with the cases per day (columns 5 onward)
data <- data[, c(1, c(5:ncol(data)))]

states <- as.character(unique(data$Province.State)[1:52])

data <-  data[as.character(data$Province.State) %in% states, ]

# Change the data from 'wide' to 'long'
data <- reshape(data = data, 
                direction = 'long',
                varying = c(2:ncol(data)),
                sep='', new.row.names=NULL)

# Identify the dates as dates in the data 
data$time <- as.Date(data$time, "%m.%d.%y")

# Group the data by country and time, with the sum of cases 
data <- aggregate(data$X, 
                  list(data$Province.State, data$time),
                  'sum')

# Only keep days with 5 or more deaths 
data <- data[data$x>=5,]

states <- unique(data$Group.1)

# PLOTTING THE DATA 
# Choose colours for each country 
# install.packages('RColorBrewer')
library(RColorBrewer)
cols <- c("dodgerblue2", "#E31A1C", "green4", "#6A3D9A", "#FF7F00", "black", "gold1", "skyblue2", "palegreen2", "#FDBF6F", "gray70", "maroon", "orchid1", "darkturquoise", "darkorange4", "brown")
  
 # brewer.pal(length(unique(data$Group.1)), 'Dark2')

# Start with an 'empty' plot of state with most deaths 
highest.deaths <- data$Group.1[which(data$x == max(data$x))]
plot_data <- data[data$Group.1==highest.deaths, ]

plot(plot_data$x, type = 'n', 
     log = 'y', # y-axis is on the log scale 
     bty = 'n', # no border around the plot 
     xlim = c(1,(nrow(plot_data)+10)),
     axes = FALSE, bg='gray80',
     xlab='Days after 5 confirmed deaths',
     ylab='Confirmed deaths (log scale)',
     cex.lab=.7)

# Add gridlines 
grid(nx = NULL, ny = NULL, col = "lightgray", lty = "dotted", lwd = par("lwd"), equilogs = F)

# Add each of the other countries 
for (state in states){
  plot_data <- data[data$Group.1 == state,]
  # Plot the lines 
  lines(c(1:nrow(plot_data)), plot_data$x, 
        col=cols[which(states==state)])
  # Add a label
  text(x=nrow(plot_data), y=max(plot_data$x),
       label=paste0(state,' (',nrow(plot_data),' days)'), 
       pos=4, offset=.1, cex=.5,
       col=cols[which(states==state)])
}

# Add the axes 
axis(1, lwd=0, cex.axis=.7)
axis(2, lwd=0, las=1, cex.axis=.7)

# Add titles
mytitle = "Covid-19 deaths"
mysubtitle = "Arranged by number of days since 5 or more deaths"
mtext(side=3, line=2, at=-0.07, adj=0, cex=1, mytitle)
mtext(side=3, line=1, at=-0.07, adj=0, cex=0.7, mysubtitle)

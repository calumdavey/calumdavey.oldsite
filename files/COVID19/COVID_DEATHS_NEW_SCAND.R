# COVID DEATHS GRAPHS 
# CALUM DAVEY
# LSHTM 
# 31 MAR 2020

# PLOT THE DEATHS
#================

# LOAD THE DATA JHU data on deaths 
  data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

# DATA MANAGEMENT 
  # Keep only country (column 2) and the columns with the cases per day (columns 5 onward)
  data <- data_raw[, c(2, c(5:ncol(data_raw)))]
  
  # Change the data from 'wide' to 'long'
  data <- reshape(data = data, 
                  direction = 'long',
                  varying = c(2:ncol(data)),
                  sep='', new.row.names=NULL)
  
  # Identify the dates as dates in the data 
  data$time <- as.Date(data$time, "%m.%d.%y")
  
  # Group the data by country and time, with the sum of cases 
  data <- aggregate(data$X, list(data$Country.Region, data$time), 'sum')

  # Only keep days with 1 or more deaths 
  data <- data[data$x>=1,]

countries <- c('Sweden', 'Denmark', 'Norway')  
  
# PLOTTING THE DATA
  max_x <- max(data$x[data$Group.1=='Sweden'],na.rm=T)
  max_y <- max(data$x[data$Group.1=='Sweden'],na.rm=T)
  mini  <- min(data$x[data$Group.1=='Sweden'],na.rm=T)
  
  # install.packages('RColorBrewer')
  library(RColorBrewer)
  cols <- brewer.pal(length(countries), 'Dark2')
  
  plot(c(1,1), type = 'n', 
       log = 'xy', # y-axis is on the log scale 
       bty = 'n', # no border around the plot 
       xlim = c(5,max_x),
       ylim = c(2,max_y),
       axes = FALSE, 
       xlab='Total number of deaths',
       ylab='Deaths in last week',
       cex.lab=.7)

  # Function to get the row above
  rowShift <- function(x, shiftLen = -7L) {
    r <- (1L + shiftLen):(length(x) + shiftLen)
    r[r<1] <- NA
    return(x[r])
  }  
    
  # Add gridlines 
  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted", lwd = par("lwd"), equilogs = F)
  
  # Add each of the countries 
  for (country in countries){
     plot_data <- data[data$Group.1 == country,]
    # Get the number of new cases
    plot_data$x_prev <- rowShift(plot_data$x)
    plot_data$y <- plot_data$x - plot_data$x_prev
    
    # Plot the lines 
    lines(plot_data$x, plot_data$y,col=cols[which(countries==country)])

    # Add a labels
    text(x=max(plot_data$x, na.rm = T), 
         y=max(plot_data$y, na.rm = T),
         label=country, 
         pos=1, offset=.5, cex=.7,
         col=cols[which(countries==country)])
  }

  # Add the axes 
  axis(1, lwd=0, cex.axis=.7)
  axis(2, lwd=0, las=1, cex.axis=.7)    

# Add titles
  mytitle = "New and total Covid-19 deaths"
  mysubtitle = "Arranged on a log-scale"
  mtext(side=3, line=2, adj=0, cex=1, mytitle)
  mtext(side=3, line=1, adj=0, cex=0.7, mysubtitle)
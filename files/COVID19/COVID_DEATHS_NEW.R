# COVID DEATHS GRAPHS 
# CALUM DAVEY
# LSHTM 
# 27 MAR 2020; update 16 APR

# Load the data 
  data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

# Data management  
  # Keep only country (column 2) and the columns with the cases per day (columns 5 onward)
  data <- data_raw[, c(2, c(5:ncol(data_raw)))]
  
  # Change the data from 'wide' to 'long'
  data <- reshape(data = data, direction = 'long', varying = c(2:ncol(data)), sep='', new.row.names=NULL)
  
  # Identify the dates as dates in the data 
  data$time <- as.Date(data$time, "%m.%d.%y")
  
  # Group the data by country and time, with the sum of cases 
  data <- aggregate(data$X, list(data$Country.Region, data$time), 'sum')

  # Choose the countries to include 
  countries <- c('China', 'Italy', 'Germany', 'Spain', 'France','US', 'Sweden', 'United Kingdom')  
  
# Plot 
  # install.packages('RColorBrewer')
  library(RColorBrewer)
  cols <- brewer.pal(length(countries), 'Paired')
  
  par(mar=c(4,1,5,5))
  plot.new()
  plot.window(xlim = c(1,max(data$x)+1000), ylim = c(1,10000))
  rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = "gray95", lwd=0)
  grid(nx = NULL, ny = NULL, col = "white", lty = "dotted", lwd = 2)
  
  # Function to get the row above
  rowShift <- function(x, shiftLen = -5L) {
    r <- (1L + shiftLen):(length(x) + shiftLen)
    r[r<1] <- NA
    return(x[r])
  }  
    
  # Add each of the countries 
  for (country in countries){
     plot_data <- data[data$Group.1 == country,]
    # Get the number of new cases
    plot_data$x_prev <- rowShift(plot_data$x)
    plot_data$y <- plot_data$x - plot_data$x_prev
    
    # Plot the lines 
    lines(plot_data$x, plot_data$y,col=cols[which(countries==country)], lwd=2)

    # Add a labels
    text(x=plot_data$x[nrow(plot_data)], 
         y=plot_data$y[nrow(plot_data)],
         label=country, 
         pos=4, offset=.1, cex=1,
         col=cols[which(countries==country)])
  }

  # Add the axes 
  axis(4, lwd=0, las =1, 
       at=seq(0,10000,2000), cex.axis=.8,
       labels=format(seq(0,10000,2000), big.mark = ','))
  axis(1, lwd=0, cex.axis=.8,
       at=seq(0,100000,5000), 
       labels=format(seq(0,100000,5000), big.mark = ','))

# Add titles & axes 
  mtext(side=3, line=2, adj=0, cex=1.2, "New and total Covid-19 deaths")
  mtext(side=3, line=1, adj=0, Sys.Date())
  text(par("usr")[2]*1.1, mean(par("usr")[3:4]), "Deaths in last five days", srt = -90, xpd = TRUE, pos = 4)
  title(main='', xlab='Total number of deaths', ylab='')
  
  
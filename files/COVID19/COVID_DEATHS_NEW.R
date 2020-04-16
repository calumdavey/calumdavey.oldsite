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
  
  # Rename 'United Kingdom' as 'UK' and 'US' as 'USA'
  data$Group.1 <- as.character(data$Group.1)
  data$Group.1[data$Group.1=='United Kingdom'] <- 'UK'
  data$Group.1[data$Group.1=='US'] <- 'USA'

  # Choose the countries to include 
  countries <- c('China', 'Italy', 'Germany', 'Spain', 'France', 'USA', 'Sweden', 'UK')  
  
# Plot 
  # install.packages('RColorBrewer')
  library(RColorBrewer)
  cols <- brewer.pal(length(countries), 'Paired')
  
  par(mar=c(4,2,5,6))
  plot.new()
  plot.window(xlim = c(1,max(data$x)+1000), ylim = c(1,15000))
  
  # Add horizontal lines 
  abline(h=c(0,5000,10000,15000), col='gray92', lwd=3)

  # Function to get the deaths a week earlier 
  rowShift <- function(x, shiftLen = -7L) {
    r <- (1L + shiftLen):(length(x) + shiftLen)
    r[r<1] <- NA
    return(x[r])
  }  
    
  # Add each of the countries 
  for (country in countries){
    plot_data <- data[data$Group.1 == country,]
    
    # Get the number of new deaths since last week 
    plot_data$x_prev <- rowShift(plot_data$x)
    plot_data$y      <- plot_data$x - plot_data$x_prev
    
    # Plot the lines 
    lines(plot_data$x, plot_data$y,col=cols[which(countries==country)], lwd=2.5)

    # Add a labels
    text(x=plot_data$x[nrow(plot_data)], 
         y=plot_data$y[nrow(plot_data)],
         label=country, font = 2, 
         pos=4, offset=.1, cex=1.1,
         col=cols[which(countries==country)])
  }

  # Add the axes 
  axis(4, lwd=0, las =1,
       at=seq(0,15000,5000), cex.axis=1,
       labels=format(seq(0,15000,5000), big.mark = ','))
  axis(1, lwd=0, cex.axis=1, lwd.ticks = 2, col='gray80',
       at=seq(0,100000,5000), 
       labels=format(seq(0,100000,5000), big.mark = ','))

# Add titles & axes 
  mtext(side=3, line=2, adj=0, cex=1.4, "New and total Covid-19 deaths")
  mtext(side=3, line=1, adj=0, Sys.Date(), cex=1.1)
  text(par("usr")[2]*1.1, mean(par("usr")[3:4])+2000, "Deaths in last week", srt = -90, xpd = TRUE, pos = 4)
  title(main='', xlab='Total deaths', ylab='')
  
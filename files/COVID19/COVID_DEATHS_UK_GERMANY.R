# COVID DEATHS GRAPHS 
# CALUM DAVEY
# LSHTM 
# 20 APR 2020

# PLOT THE DEATHS
#================

# LOAD THE DATA JHU data on deaths 
  data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

# DATA MANAGEMENT 
  countries <- c("United Kingdom", 'Germany')
  
  # Keep data for selected countries
  # Keep only country (column 2) and the columns with the cases per day (columns 5 onward)
  data <- data_raw[data_raw$`Country.Region` %in% countries , c(2, c(5:ncol(data_raw)))]
  
  # Change the data from 'wide' to 'long'
  data <- reshape(data = data, 
                  direction = 'long',
                  varying = c(2:ncol(data)),
                  sep='', new.row.names=NULL)
  
  # Identify the dates as dates in the data 
  data$time <- as.Date(data$time, "%m.%d.%y")
  
  # Group the data by country and time, with the sum of cases 
  data <- aggregate(data$X, list(data$Country.Region, data$time), 'sum')

  # Only keep days with 10 or more deaths 
  data <- data[data$x>=10 & data$Group.1 %in% countries, ]
  
  # Function to get new deaths
  rowShift <- function(x, shiftLen = -1L) {
    r <- (1L + shiftLen):(length(x) + shiftLen)
    r[r<1] <- NA
    return(x[r])
  }  
  
# PLOTTING THE DATA
  # Choose colours for each country 
  # install.packages('RColorBrewer')
  cols <- c('gray40','white')
  
  xmax <- sum(data$Group.1==country[1])-1.5
  ymax <- 1000
  
  # Start with an 'empty' plot 
  par(mar=c(4,4,5,6))
  plot.new()
  plot.window(xlim = c(5,xmax), ylim = c(1,ymax))
  
  # Add horizontal lines 
  abline(h=seq(0,ymax,200), col='gray92', lwd=3)
  
  for (country in countries){
  # Add each of the countries 
  plot_data <- data[data$Group.1 == country,]
    
  # Get the number of new deaths since last 2 weeks 
  plot_data$x_prev <- rowShift(plot_data$x)
  plot_data$y      <- abs(plot_data$x - plot_data$x_prev)
    
  # Plot the bars 
  rect(c(1:nrow(plot_data))-1.1, 
       0, 
       c(1:nrow(plot_data)), 
       plot_data$y, 
       col=cols[which(countries==country)], lwd=0)  
  }

  # Add the axes 
  axis(1, lwd=0, cex.axis=.7)
  axis(4, lwd=0, las=1, cex.axis=.7)    

  legend(x='topleft', legend=countries, bty='n', fill = cols)
  
# Add titles
  mtext(side=3, line=2, at=2, adj=0, cex=1.2, "Excess daily COVID-19 deaths in UK ")
  mtext(side=3, line=1, at=2, adj=0, cex=1, "(compared to Germany)")
  mtext(side=1, line=2, at=15, adj=0, cex=.8, "Days since 10 deaths")
  mtext(side=4, line=3, at=300, adj=0, cex=.8, "Deaths per day")
  
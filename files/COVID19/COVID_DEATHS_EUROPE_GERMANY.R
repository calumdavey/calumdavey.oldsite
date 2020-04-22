# BLACK CLOUD 
# CALUM DAVEY
# LSHTM 
# 21 APR 2020

# LOAD THE DATA JHU data on deaths 
  data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

# DATA MANAGEMENT 
  countries <- c("UK", 'France', 'Italy', 'Spain')
  
  # Keep data for selected countries
  data_raw$Country.Region <- as.character(data_raw$Country.Region)
  data_raw$Country.Region[data_raw$Country.Region=='United Kingdom'] <- 'UK'
  # Keep only country (column 2) and the columns with the cases per day (columns 5 onward)
  data <- data_raw[data_raw$`Country.Region` %in% c(countries,'Germany') , c(2, c(5:ncol(data_raw)))]
  
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
  data <- data[data$x>=10, ]
  
  # Function to get new deaths
  rowShift <- function(x, shiftLen = -1L) {
    r <- (1L + shiftLen):(length(x) + shiftLen)
    r[r<1] <- NA
    return(x[r])
  }  
  
  # Save the German data 
  g_data        <- data[data$Group.1 == 'Germany',]
  g_data$x_prev <- rowShift(g_data$x)
  g_data$y      <- abs(g_data$x - g_data$x_prev)
  
# PLOTTING THE DATA
  # Choose colours for each country 
  # install.packages('RColorBrewer')
  cols <- c('gray40','white')
  
  xmax <- nrow(g_data)-1.5
  
  # Start with an 'empty' plot 
  par(mar=c(3,3,5,3), mfrow=c(2,2))
  
  for (country in countries){
  
  # Select data for the country  
  plot_data <- data[data$Group.1 == country,]
    
  # Get the number of new deaths since last 2 weeks 
  plot_data$x_prev <- rowShift(plot_data$x)
  plot_data$y      <- abs(plot_data$x - plot_data$x_prev)
  
  # Create the plot
  plot.new()
  ymax <- 1400 #max(plot_data$y, na.rm = T)
  plot.window(xlim = c(5,xmax), ylim = c(1,ymax))
  
  # Add horizontal lines 
  abline(h=seq(0,ymax,200), col='gray92', lwd=3)
  
  # Plot the bars 
  rect(c(1:nrow(plot_data))-1.1, 0, c(1:nrow(plot_data)), plot_data$y, col=cols[1], lwd=0)  
  #lines(c(1:nrow(plot_data)), plot_data$y,col='gray80', lwd=2.5)
  rect(c(1:nrow(g_data))-1.1, 0, c(1:nrow(g_data)), g_data$y, col=cols[2], lwd=0)  
  
  # Add the axes 
  axis(1, lwd=0, cex.axis=.7)
  axis(4, lwd=0, las=1, cex.axis=.7)    
  
  # Add titles
  mtext(side=3, line=2, at=2, adj=0, cex=1, paste0("Excess COVID-19 deaths in ",country))
  mtext(side=3, line=1, at=2, adj=0, cex=.7, "(compared to Germany)")
  mtext(side=1, line=2, at=15, adj=0, cex=.6, "Days since 10 deaths")
  mtext(side=4, line=3, at=300, adj=0, cex=.6, "Deaths per day")
  }
  
  
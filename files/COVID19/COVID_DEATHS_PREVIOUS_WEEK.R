# PREVIOUS WEEK 
# CALUM DAVEY
# LSHTM 
# 22 APR 2020

# LOAD THE DATA JHU data on deaths 
  data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

# DATA MANAGEMENT
  countries <- c("France", "Italy", 'Germany', "Spain", "United Kingdom", "US", "Brazil", "Russia", "Turkey")

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

# # DATA CHECK: open the csv file from Our World in Data 
#   data <- read.csv('total-deaths-covid-19.csv', as.is = T)
#   data$Entity[data$Entity=='United States'] <- 'US'
#   data <- data[data$Entity %in% countries, ]
#   data$x <- data$Total.confirmed.deaths.due.to.COVID.19..deaths.
#   data$Group.1 <- data$Entity
#   #--> get the same image 
  
  # Keep only days with at least ten deaths 
  data <- data[data$x>=10, ]
  
  # Function to get new deaths
  rowShift <- function(x, shiftLen) {
    r <- (1L + shiftLen):(length(x) + shiftLen)
    r[r<1] <- NA
    return(x[r])
  }  
  
# PLOTTING THE DATA
  cols <- c('gray40')
  yrange <- c(-600, 2000)
  par(mar=c(4,4,5,6), mfrow=c(3,3))
  
  for (country in countries){
    # Add each of the countries 
    plot_data <- data[data$Group.1 == country,]
      
    # Get new deaths 
      plot_data$x_prev <- rowShift(plot_data$x, shiftLen = -1L)
      plot_data$y      <- plot_data$x - plot_data$x_prev
    # Compare with previous week 
      plot_data$y_prev <- rowShift(plot_data$y, shiftLen = -7L)
      plot_data$change <- plot_data$y - plot_data$y_prev

    # Start with an 'empty' plot 
    plot.new()
    plot.window(xlim = c(0,nrow(plot_data)), ylim = yrange)
    
    # Add horizontal lines 
    abline(h=seq(yrange[1],yrange[2],500), col='gray92', lwd=3)
      
    # Plot the bars 
    rect(c(1:nrow(plot_data))-1.2, 
         0, 
         c(1:nrow(plot_data)), 
         plot_data$change, 
         col=ifelse(plot_data$change>=0,'coral3','cornflowerblue'), lwd=0)  

  # Add the axes 
  axis(1, lwd=0, cex.axis=1)
  axis(2, lwd=0, las=1, cex.axis=1)    
  
  # Add titles
  mtext(side=3, line=1, at=2, adj=0, cex=1, country)
  mtext(side=1, line=2, adj=1, cex=.8, 'Days since 10 deaths')
  }
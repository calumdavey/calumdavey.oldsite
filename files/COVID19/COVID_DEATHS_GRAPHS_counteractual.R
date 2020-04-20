# COVID DEATHS GRAPHS 
# CALUM DAVEY
# LSHTM 
# 20 APR 2020

# PLOT THE DEATHS
#================

# LOAD THE DATA JHU data on deaths 
  data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

# DATA MANAGEMENT 
  countries <- c("Italy", "United Kingdom", 'Germany')
  
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

  # Only keep days with 5 or more deaths 
  data <- data[data$x>=5,]

# PLOTTING THE DATA
  # Choose colours for each country 
  # install.packages('RColorBrewer')
  library(RColorBrewer)
  cols <- brewer.pal(length(countries), 'Dark2')
  
  # Start with an 'empty' plot of Italy 
  plot_data <- data[data$Group.1=='Italy', ]
  max_x <- nrow(plot_data)
  
  par(mar=c(5, 4, 4, 6) + 0.1)
  plot(plot_data$x, 
       type = 'n', 
       #log = 'y', # y-axis is on the log scale 
       bty = 'n', # no border around the plot 
       xlim = c(1,(max_x+6)),
       axes = FALSE, 
       xlab='Days after 5 confirmed deaths',
       ylab='Confirmed deaths',
       cex.lab=1)
  
  # Add each of the other countries 
  for (country in countries){
    plot_data <- data[data$Group.1 == country,]
    
    # Plot the lines 
    lines(c(1:nrow(plot_data)), plot_data$x, 
          col=cols[which(countries==country)],
          lwd=1.5)
    
    # Add a labels
    text(x=ifelse(nrow(plot_data)<=(max_x+6), nrow(plot_data), max_x+4), 
         y=ifelse(nrow(plot_data)<=(max_x+6), max(plot_data$x, na.rm=T), plot_data$x[max_x]),
         label=paste0(country,'\n (',nrow(plot_data),
                      ifelse(nrow(plot_data)<=(max_x+6), ' days)', ' days→')), 
         pos=4, offset=.3, cex=1, font =2,
         col=cols[which(countries==country)])
  }

  # Add the axes 
  axis(1, lwd=0, cex.axis=.7)
  axis(2, lwd=0, las=1, cex.axis=.7)    

# Add titles
  mytitle = "Covid-19 deaths"
  mysubtitle = "Arranged by number of days since 5 or more deaths"
  mtext(side=3, line=2, at=-0.07, adj=0, cex=1.2, mytitle)
  mtext(side=3, line=1, at=-0.07, adj=0, cex=1, mysubtitle)
  
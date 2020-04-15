# COVID DEATHS GRAPHS 
# CALUM DAVEY
# LSHTM 
# 03 APR 2020

# PLOT THE DEATHS
#================

# LOAD THE DATA JHU data on deaths 
  data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

# DATA MANAGEMENT 
  countries <- c("Italy", "United Kingdom", "France")
  
  # Keep data for selected countries 
  data <- data_raw[data_raw$`Country.Region` %in% countries, ]
    
  # Keep only country (column 2) and the columns with the cases per day (columns 5 onward)
  data <- data[, c(2, c(5:ncol(data)))]
  
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
  datas <- list()
  datas[[1]] <- data[data$x>=1,]
  datas[[5]] <- data[data$x>=5,]
  datas[[10]] <- data[data$x>=10,]

  # Choose colours for each country 
  # install.packages('RColorBrewer')
  library(RColorBrewer)
  countries <- unique(data$Group.1)
  cols <- brewer.pal(length(countries), 'Dark2')
  
# PLOTTING THE DATA
par(mfrow=c(1,3))

for (i in c(1,5,10)){
  data <- datas[[i]]
  # Start with an 'empty' plot of Italy 
  plot_data <- data[data$Group.1=='Italy', ]
  max_x <- nrow(plot_data)
  
  par(mar=c(5, 4, 4, 6) + 0.1)
  plot(plot_data$x, type = 'n', 
       #log = 'y', # y-axis is on the log scale 
       bty = 'n', # no border around the plot 
       xlim = c(1,(max_x+6)),
       axes = FALSE, bg='gray80',
       xlab=paste0('Days after ', i,' confirmed deaths'),
       ylab='Confirmed deaths',
       cex.lab=.7)
  
  # Add each of the other countries 
  for (country in countries){
    plot_data <- data[data$Group.1 == country,]
    
    # Plot the lines 
    lines(c(1:nrow(plot_data)), plot_data$x, col=cols[which(countries==country)],lwd=1.5)
    
    # Add a labels
    text(x=ifelse(nrow(plot_data)<=max_x, nrow(plot_data), max_x), 
         y=ifelse(nrow(plot_data)<=max_x, max(plot_data$x, na.rm=T), plot_data$x[max_x]),
         label=paste0(country,'\n (',nrow(plot_data),
                      ifelse(nrow(plot_data)<=max_x, ' days)', ' days→')), 
         pos=4, offset=.3, cex=.7,
         col=cols[which(countries==country)])
  }
  

  # Add the axes 
  axis(1, lwd=0, cex.axis=.7)
  axis(2, lwd=0, las=1, cex.axis=.7)    

  # Add titles
  mytitle = "New and total Covid-19 deaths"
  mysubtitle = paste0("Arranged on a log-scale since ",i," deaths")
  mtext(side=3, line=2, adj=0, cex=1, mytitle)
  mtext(side=3, line=1, adj=0, cex=0.7, mysubtitle)
}
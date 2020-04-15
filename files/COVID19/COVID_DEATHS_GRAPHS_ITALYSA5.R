# COVID DEATHS GRAPHS 
# CALUM DAVEY
# LSHTM 
# 03 APR 2020

# PLOT THE DEATHS
#================

# LOAD THE DATA JHU data on deaths 
  data_raw <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

# DATA MANAGEMENT 
  countries <- c("Italy", "South Africa", "Nigeria", "India")
  
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

  # Only keep days with 5 or more deaths 
  data <- data[data$x>=5,]

# PLOTTING THE DATA
  # Choose colours for each country 
  # install.packages('RColorBrewer')
  library(RColorBrewer)
  countries <- unique(data$Group.1)
  cols <- brewer.pal(length(countries), 'Dark2')
  
  # Start with an 'empty' plot of Italy 
  plot_data <- data[data$Group.1=='Italy', ]
  max_x <- nrow(plot_data)
  
  par(mar=c(5, 4, 4, 6) + 0.1)
  plot(plot_data$x, type = 'n', 
       log = 'y', # y-axis is on the log scale 
       bty = 'n', # no border around the plot 
       xlim = c(1,(max_x+6)),
       axes = FALSE, bg='gray80',
       xlab='Days after 5 confirmed deaths',
       ylab='Confirmed deaths (log scale)',
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

# ADD GOVERNMENT STRINGENCY PLOT ON TOP 
#======================================
  
# LOAD DATA FROM OXFORD COVID-19 GOVERNMENT RESPONSE TRACKER
  library(readxl)
  library(httr)
  url <- "https://www.bsg.ox.ac.uk/sites/default/files/OxCGRT_Download_latest_data.xlsx?raw=true"
  GET(url, write_disk(tf <- tempfile(fileext = ".xlsx")))
  df <- read_excel(tf)

# CLEAN UP THE DATA 
  df$Date <- as.Date(as.character(df$Date), "%Y%m%d")
  df$CountryName[df$CountryName=='South Korea'] <- 'Korea, South'
    
# MERGE DATASETS TO ENSURE THE DATES MATCH
  data <- merge(data, df, by.x=c('Group.1','Group.2'), by.y=c('CountryName','Date'),all.x=T)
  
# PLOT 
  par(new=TRUE)  
  plot(1, type = 'n', 
       bty = 'n', # no border around the plot 
       xlim = c(0,max_x), 
       ylim = c(0,100),
       axes = FALSE, 
       xlab='',
       ylab='',
       #sub='\nData from Oxford COVID-19 Government response tracker\nhttps://www.bsg.ox.ac.uk/sites/default/files/OxCGRT_Download_latest_data.xlsx',
       cex.sub=.7,
       cex.lab=.7)
  
  for (country in countries){
    plot_data <- data[data$Group.1==country & !is.na(data$StringencyIndex),]
    
    if (nrow(plot_df)>2){
      # Since only updated every 1-3 days, drop final 2 rows 
      plot_data <- plot_data[1:(nrow(plot_data)-1),]
      
      # Add the lines 
      lines((1:nrow(plot_data)),plot_data$StringencyIndex,
            col=cols[which(countries==country)],lty=3)
    }
  }

# Add axes 
  axis(4, lwd=0, las=1, cex.axis=.7)

# Add titles
  mytitle = "Covid-19 deaths & gov. response stringency "
  mysubtitle = "Arranged by number of days since 5 or more deaths"
  mtext(side=3, line=2, at=-0.07, adj=0, cex=1, mytitle)
  mtext(side=3, line=1, at=-0.07, adj=0, cex=0.7, mysubtitle)
  mtext("Response stringency",side=4,line=2,cex=.7)

# Add legend 
  legend(x='bottomright', legend=c('Deaths','Stringency'), lty=c(1,3), bty='n', cex=.7)

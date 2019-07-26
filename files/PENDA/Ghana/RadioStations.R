# Radio stations in Ghana 
library(rvest)

# Declare the location of the data 
url <- 'https://www.ghanaweb.com/GhanaHomePage/communication/radio.php'

# Read the HTML
page <- read_html(url)

# Create tables 
titles <- seq(3,21,2)
stations <- matrix(, ncol=5,nrow=0)
for (i in 1:10){
  x <- html_table(html_nodes(page, 
                  xpath=paste0('//*[@id="medsection1"]/table[',i,']')))[[1]]
  t <- html_text(html_nodes(page, 
                  xpath=paste0('//*[@id="medsection1"]/p[',titles[i],']')))[[1]]
  stations <- rbind(stations, 
                    cbind(x, rep(t, times = nrow(x))))
}

stations <- as.data.frame(stations[,c(1,2,4,5)])
colnames(stations) <- c('Name','Frequency','Location','Region')

# Get map data 
library(sp)
library(rgeos)
admin <- readRDS("gadm36_GHA_1_sp.rds")
ghana <- gUnaryUnion(admin, id=admin@data$ID_0)
ghana <- gSimplify(spgeom=ghana, tol=.03)
par(mar = c(1,1,1,1))
plot(ghana, lwd = 3)
plot(admin, add = T)
# 29 APRIL 2020

# install.packages('magick')
  library(magick)

# Plotting function   
plot_animate <- function(data = NULL, x = NULL, y = NULL, z = NULL, add = TRUE,
                         w=500, h=500, r=96){
    XRANGE <- c(min(data[,x], na.rm = T), max(data[,x], na.rm = T))
    YRANGE <- c(min(data[,y], na.rm = T), max(data[,y], na.rm = T))
  
    par(bg=NA)
    img <- image_graph(w, h, res = r)
    datalist <- split(data, data[,z])

    lapply(datalist, function(d){
      plot.new(); plot.window(xlim=XRANGE, ylim=YRANGE); axis(1); axis(2)
      points(d[,x], d[,y])
    })
    
    dev.off()
    animation <- image_animate(img, fps = 2, optimize = TRUE, dispose = 'none')
    print(animation)    
  }

# Basic plot 
plot_animate(data = iris, x = "Petal.Length", y = "Petal.Width", z = "Species")  

  
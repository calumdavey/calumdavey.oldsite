# 29 APRIL 2020

# install.packages('magick')
  library(magick)

# Plotting function   
plot_animate <- function(data = NULL, x = NULL, y = NULL, z = NULL, add = TRUE,
                         xrange = c(min(data[,x], na.rm = T), max(data[,x], na.rm = T)),
                         yrange = c(min(data[,y], na.rm = T), max(data[,y], na.rm = T)),
                         w=500, h=500, r=96, add=TRUE){
    
    img <- image_graph(w, h, res = r)
    Z <- unique(data[,z])
    plot.new(); plot.window(xlim = xrange, ylim = yrange); axis(1); axis(2)
    
    for (i in Z){
      if (add == TRUE){
          d <- data[data[,z] %in% Z[1:which(Z == i)],]
        } else {
          d <- data[data[,z]==i,] 
        }
      plot.new(); plot.window(xlim = xrange, ylim = yrange); axis(1); axis(2)
      points(d[,x], d[,y])  
    }
    
    dev.off()
    animation <- image_animate(img, fps = 2, optimize = TRUE)
    print(animation)    
  }

# Basic plot 
  # Additive 
  plot_animate(data = iris, x = "Petal.Length", y = "Petal.Width", z = "Species")  

  # Non-additive 
  plot_animate(data = iris, x = "Petal.Length", y = "Petal.Width", z = "Species", add = FALSE)  
  
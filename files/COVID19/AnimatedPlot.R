# 1 May 2020

if(!require(magick)) install.packages('magick')
library(magick)

# Plotting function   
plot_animate <- function(data = NULL, x = NULL, y = NULL, z = NULL, add = TRUE,
                         xrange = c(min(data[[x]], na.rm = T), max(data[[x]], na.rm = T)),
                         yrange = c(min(data[[y]], na.rm = T), max(data[[y]], na.rm = T)),
                         w=500, h=500, r=96,
                         fps = 2, morph = FALSE, 
                         plot_type = "points", ...){
    
    img <- image_graph(w, h, res = r)
    Z <- unique(data[[z]])
    
    
    for (i in seq_along(Z)){
      if (add == TRUE){
          d <- data[data[[z]] %in% Z[1:i],]
        } else {
          d <- data[data[[z]] == Z[i],]
        }
      plot.new(); plot.window(xlim = xrange, ylim = yrange); axis(1); axis(2)
      do.call(plot_type, list(d[[x]], d[[y]], ...))  
    }
    

    
    if (morph){
      img <- image_morph(img)
      fps <- 10
    }
    animation <- image_animate(img, fps = fps, optimize = TRUE)
    print(animation)
}

# Scatter plot 
  # Additive 
plot_animate(data = iris, x = "Petal.Length", y = "Petal.Width", z = "Species",
             plot_type = "points")


# With pch, color and morphing
plot_animate(data = iris, x = "Petal.Length", y = "Petal.Width", z = "Species",
             plot_type = "points", 
             pch = 5, col="blue", morph = TRUE)


# Line plot
# Get some data
economics <- ggplot2::economics_long[1:50,] # First 50 rows as an example

plot_animate(data = economics, x = "date", y = "value", z = "value",
             fps = 10, plot_type = "lines", xlab="Date")

# Non-additive 
plot_animate(data = iris, x = "Petal.Length", y = "Petal.Width", z = "Species", add = FALSE)  



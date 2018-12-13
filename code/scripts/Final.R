# load up required packages

library(vegan)
library(ggplot2)
# Download 
# library(devtools)
# devtools::install_github("GuillemSalazar/EcolUtils")
library(EcolUtils)
library(ggpubr)
library(devtools)
library(readxl)

######################## MULTIPLOT FUNCTION ############################

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
##################################################################################

# import data
setwd("~/Downloads/bri/")
level_7 <- (read.csv("level-7.csv", sep = ",", row.names = 1))
clean_data <- subset(level_7[ ,1:211])
no_mock <- subset(level_7[1:151 ,1:211])
inmeta <- read.csv("New_7_map.csv",sep = "\t",header = TRUE)

# look at reads
barplot(sort(rowSums(clean_data)), ylim = c(0, max(rowSums(clean_data))), 
        xlim = c(0,NCOL(clean_data)), col = "Orange") 

# Rarefy to normalize the data
# Bray Distances
median.avg.dist <- avgdist(no_mock, sample = 2200, iterations = 100, 
                           meanfun = median, dmethod = "bray")

bray_distance_matrix <- as.data.frame(as.matrix(median.avg.dist))

# Alpha distances
rare_perm_otu <- rrarefy.perm(clean_data, sample = 2200, n = 10, round.out = T)
barplot(sort(rowSums(rare_perm_otu)), ylim = c(0, max(rowSums(rare_perm_otu))), 
        xlim = c(0,NCOL(rare_perm_otu)), col = "Orange")



# Write to file
write.csv(bray_distance_matrix, file = "bray_distances.csv")
write.csv(rare_perm_otu, file = "rarified_otu-table.csv")

# Do nMDS
quick_nmds <- metaMDS(bray_distance_matrix, k=2)
plot(quick_nmds)
quick_nmds

##############################################################################
######################## PREVOTELLA CORRELATIONS #######################
##############################################################################


prevotella_cytokines <- read_excel("prevotella.xlsx")

#prevotella vs tnfa
A <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "TNFa", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella copri", ylab = "TNFa", shape = "HealthStatus", size = 2) 


#prevotella vs IP10
B <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IP10", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IP10", shape = "HealthStatus", size = 2)

C <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "GRO", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "GRO", shape = "HealthStatus", size = 2)

#prevotella vs IFNg
D <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IFNg", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IFNg", shape = "HealthStatus", size = 2)

#prevotella vs IL10
E <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL10", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IL10", shape = "HealthStatus", size = 2)

#prevotella vs IL17a
F <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL17a", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IL17a", shape = "HealthStatus", size = 2)

#prevotella vs IL1RA
G <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL1RA", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IL1RA", shape = "HealthStatus", size = 2)

#prevotella vs IL1a
H <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL1a", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IL1a", shape = "HealthStatus", size = 2)

#prevotella vs IL1b
I <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL1b", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IL1b", shape = "HealthStatus", size = 2)

#prevotella vs IL6
J <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL6", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IL6", shape = "HealthStatus", size = 2)

#prevotella vs IL8
K <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL8",
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Prevotella_copri", ylab = "IL8", shape = "HealthStatus", size = 2)

multiplot(A, B, C, D, E, F, G, H, I, J, K, cols=3)


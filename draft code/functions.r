# Functions used for data analysis
# craetes correlation matrix for all variables in selected regions
# also check for adjusted p values for each pair
# might not work outside of dataset Crime from pkg plm

# Environments
require(dplyr)
require(tidyverse)
require(ggplot2)
require(stats)


###### Create matrix for testing ######
matxCorr <- function(data, region, method = 'pearson', adjust = 'bonferroni'){
    # a function to produce a correlation matrix among selected marker of data
    # might not work outside of dataset Crime from pkg plm
    # region (region tag of county): west, central, other
    # method (corr test methods): 'pearson', 'kendall', 'spearman'
    # adjust (p-value adjustment): "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"
    
    data <- data %>% 
        filter(region == region) %>% 
        select(starts_with('l'))
    
    d <- expand.grid(var1 = names(data),
                    var2 = names(data)) %>%
    as_tibble() %>%
    mutate(test = map2(var1, var2, ~cor.test(unlist(data[,.x]),    # perform the correlation test for each pair and store it
                                           unlist(data[,.y]))),
          corr = map_dbl(test, 'estimate'),
          p_unadj = map_dbl(test,'p.value'))
    d$p <- p.adjust(d$p_unadj, adjust)
    return(d)
}


##### Organize matrix to factorial view #####
showCorr <- function(data, type = 'p'){
    # draw a matrix of correlation or p values
    # type includes 'corr' or 'p' (default 'p')
    
    data %>% select(var1, var2, type) %>%
    spread(var2, type)
}


##### Visualize matrix using ggplot heatmap #####
paintCorr <- function(data, type = 'p'){
    # paint heat map based on correlation or p values
    # type includes 'corr' or 'p' (default 'p')
  library(RColorBrewer)
  if (type != "corr") # if type = p/p_unadj
    {
    colMain <- colorRampPalette(brewer.pal(8, "Blues"))(25)
    colMain_continuous <- rev(colorRampPalette(colMain)(100))
    limit = c(0,1)
    }
  else{
    colMain_continuous <- colorRampPalette(c("navy", "white", "darkred"))(100)
    limit = c(-1, 1)
  }
    ggplot(data, aes(var1, var2)) + 
        geom_tile(aes(fill = !!as.name(type))) +
        scale_x_discrete(expand = c(0,0)) +
        scale_y_discrete(expand = c(0,0)) +
      scale_fill_gradientn(colours = colMain_continuous, limits = limit) +
        #scale_fill_gradient(low = lower, high = higher)+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
}

# dirty script to print average RMSE values
# and compare models with the NULL model
# using an ANOVA and TukeyHSD test

# run summary stats on the model comparison
library(phenor)

# make sure you are in the phenor manuscript path
# before loading the data
comparison = readRDS("./data/pre_processed/comparison.rds")
melaas = readRDS("./data/pre_processed/melaas.rds")

# list all data
phenocam_data = c("phenocam_DB",
  "phenocam_EN",
  "phenocam_GR")

for (i in 1:3){
  # calculate mean / sd RMSE of all model runs
  # (different parameters - by different seeds)
  rmse_stats = lapply(comparison[[i]]$modelled,function(x){
    rmse = apply(x$predicted_values,1,function(y){
      sqrt(mean((y - comparison[[i]]$measured) ^ 2, na.rm = T))
    })
    return(rmse)
  })

  # plot average model RMSE across all models
  print(phenocam_data[i])
  print(sprintf("%s +_ %s", mean(unlist(rmse_stats)), sd(unlist(rmse_stats))))

  # calculate the ANOVA stats comparing model RMSE output
  # first some formatting, bit ugly
  l = length(rmse_stats[[1]])
  labels = as.matrix(unlist(lapply(names(rmse_stats),function(x){
    rep(x,l)
  })))
  v = as.matrix(unlist(rmse_stats))

  # calculate values for the NULL model
  null = sqrt(mean((comparison[[i]]$measured - mean(comparison[[i]]$measured))^2))
  null = data.frame(rep(null,l),rep("NULL",l))
  names(null) = c("v","labels")

  # print null values, for reporting
  print(null[1,])

  # bind everyting together
  df = data.frame(v,labels)
  df = rbind(df,null)
  df$labels = as.factor(df$labels)

  # run ANOVA and HSD
  fit = aov(log10(v) ~ labels, data = df)
  HSD = TukeyHSD(fit)
  HSD_sorted = as.matrix(sort(HSD$labels[,4], decreasing = TRUE))
  total = nrow(HSD_sorted)
  non_sign = length(which(HSD_sorted > 0.95))

  print(sprintf("total comparisons: %s, non significant: %s", total, non_sign))

  # different from NULL model?
  print(HSD$labels[grep("NULL",rownames(HSD$labels)),])
}


# subset the DB dataset to those sites in Melaas et al.
comparison_DB_subset = comparison[[1]]
all_sites = flat_format(phenocam_DB)$site

sites_melaas = c(
  "harvard",
  "bartlettir",
  "acadia",
  "mammothcave",
  "nationalcapital",
  "dollysods",
  "smokylook",
  "upperbuffalo",
  "boundarywaters",
  "groundhog",
  "umichbiological2",
  "queens"
)

loc = which(all_sites %in% sites_melaas)

# calculate mean / sd RMSE of all model runs
# (different parameters - by different seeds)
rmse_stats = lapply(comparison_DB_subset$modelled,function(x){
  rmse = apply(x$predicted_values[,loc],1,function(y){
    sqrt(mean((y - comparison_DB_subset$measured[loc]) ^ 2, na.rm = T))
  })
  return(rmse)
  list("rmse" = mean(rmse,na.rm=TRUE),"sd"=sd(rmse,na.rm=TRUE))
})

rmse_stats = do.call("cbind",rmse_stats)

print("Melaas et al. subset")
print(sprintf("%s +_ %s", mean(rmse_stats), sd(rmse_stats)))

# calculate mean / sd RMSE of all model runs
# (different parameters - by different seeds)
rmse_stats = lapply(melaas$modelled,function(x){
  rmse = apply(x$predicted_values,1,function(y){
    sqrt(mean((y - melaas$measured) ^ 2, na.rm = T))
  })
  return(rmse)
})

rmse_stats = do.call("cbind",rmse_stats)

print("Melaas et al. separate optimization")
print(sprintf("%s +_ %s", mean(rmse_stats), sd(rmse_stats)))

# calculate mean / sd RMSE of all model runs
# (different parameters - by different seeds)
error = lapply(comparison[[1]]$modelled,function(x){
  error = apply(x$predicted_values,1,function(y){
    y - comparison[[1]]$measured
  })
  return(error)
})

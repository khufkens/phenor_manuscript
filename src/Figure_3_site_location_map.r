# Figure 3.

# An overview map of the PhenoCam deciduous broadleaf sites as included
# in the PhenoCam Data Paper (Richardson et al. 2017).
# this code should be run within the directory which contains the code
# set your working directory accordingly.

# load libraries
library(ggplot2)
library(gridExtra)
library(maptools)
library(phenor)
library(mapproj)

# map theme
theme_map <- function(...) {
  theme_minimal() +
    theme(
      text = element_text(color = "#22211d"),
      axis.line = element_blank(),
      #axis.text.x = element_blank(),
      #axis.text.y = element_blank(),
      #axis.ticks = element_blank(),
      #axis.title.x = element_blank(),
      #axis.title.y = element_blank(),
      panel.grid.minor = element_line(color = "#ebebe5", size = 0.2),
      panel.grid.major = element_line(color = "#ebebe5", size = 0.2),
      #panel.grid.minor = element_blank(),
      #plot.background = element_rect(fill = "#f5f5f2", color = NA),
      panel.background = element_rect(fill = "#f5f5f2", color = NA),
      legend.background = element_rect(fill = "#f5f5f2", color = NA),
      panel.border = element_blank(),
      ...
    )
}

# flatten the format
phenocam_DB = flat_format(phenocam_DB)
phenocam_EN = flat_format(phenocam_EN)
phenocam_GR = flat_format(phenocam_GR)

# create a spatial points object and transform to polar coords
sites_DB = unique(data.frame(t(phenocam_DB$location[1:2,])))
sites_EN = unique(data.frame(t(phenocam_EN$location[1:2,])))
sites_GR = unique(data.frame(t(phenocam_GR$location[1:2,])))

colnames(sites_GR) = c("lat","lon")
colnames(sites_EN) = c("lat","lon")
colnames(sites_DB) = c("lat","lon")

# read in the data, please run the demo_data.r routine first
path = "~/phenor_files/"
npn_data = readRDS(paste0(path,"npn_demo_data.rds"))
pep725_data = readRDS(paste0(path,"pep725_demo_data.rds"))
modis_data = readRDS(paste0(path,"modis_demo_data.rds"))

# load the modis data
modis_data = as.data.frame(unique(t(flat_format(modis_data)$location)))
colnames(modis_data) = c("lat","lon")

# get the NPN budburst data for Acer rubrum
npn_data = as.data.frame(unique(t(flat_format(npn_data)$location)))
colnames(npn_data) = c("lat","lon")

# get PEP725 data for Fagus sp.
pep725_data = as.data.frame(unique(t(flat_format(pep725_data)$location)))
colnames(pep725_data) = c("lat","lon")

p = ggplot() +
  geom_polygon(data = map_data("world"),
               aes(x=long, y=lat, group=group),
               fill='grey20',
               colour = 'white',
               size = 0.1) +
  expand_limits(x = fifty_states$long, y = fifty_states$lat) +
  scale_x_continuous(breaks=seq(-160,-50,20)) +
  scale_y_continuous(breaks=seq(25,65,10)) +
  coord_cartesian(xlim = c(-155, -65), ylim = c(25, 60)) +
  geom_point(data = sites_DB,
             aes(x = lon, y = lat),
             col = "darkgoldenrod1",
             alpha = 0.8,
             pch = 15,
             size = 3) +
  geom_point(data = sites_GR,
             aes(x = lon, y = lat),
             col = "dodgerblue",
             alpha = 0.8,
             pch = 17,
             size = 3) +
  geom_point(data = sites_EN,
             aes(x = lon, y = lat),
             col = "chartreuse3",
             alpha = 0.8,
             pch = 19,
             size = 3) +
  xlab("") +
  ylab(expression(paste("Latitude (", degree, ")"))) +
  labs(title=expression("A. PhenoCam (multiple PFTs)" * italic(" "))) +
  theme_map()

p1 = ggplot() +
  geom_polygon(data = map_data("world"),
               aes(x=long, y=lat, group=group),
               fill='grey20',
               colour = 'white',
               size = 0.1) +
  scale_x_continuous(breaks=seq(-160,-50,20)) +
  scale_y_continuous(breaks=seq(25,65,10)) +
  coord_cartesian(xlim = c(-155, -65), ylim = c(25, 60)) +
  geom_point(data = npn_data,
             aes(x = lon, y = lat),
             col = "darkgoldenrod1",
             alpha = 0.8,
             pch = 15,
             size = 1 ) +
  xlab("") +
  ylab("") +
  labs(title=expression("B. USA-NPN (" * italic("Acer rubrum") * ")")) +
  theme_map()

p2 = ggplot() +
  geom_polygon(data = map_data("world"),
               aes(x=long, y=lat, group=group),
               fill='grey20',
               colour = 'white',
               size = 0.1) +
  scale_x_continuous(breaks=seq(-160,-50,20)) +
  scale_y_continuous(breaks=seq(25,65,10)) +
  coord_cartesian(xlim = c(-155, -65), ylim = c(25, 60)) +
  geom_point(data = modis_data,
             aes(x = lon, y = lat),
             col = "dodgerblue",
             alpha = 0.8,
             pch = 17,
             size = 3 ) +
  xlab(expression(paste("Longitude (", degree, ")"))) +
  ylab(expression(paste("Latitude (", degree, ")"))) +
  labs(title=expression("C. MODIS MCD12Q2 (grasslands)" * italic(" "))) +
  theme_map()

p3 = ggplot() +
  geom_polygon(data = map_data("world"),
               aes(x=long, y=lat, group=group),
               fill='grey20',
               colour = 'white',
               size = 0.1) +
  scale_x_continuous(breaks=seq(-10,45,5)) +
  scale_y_continuous(breaks=seq(20,65,5)) +
  coord_cartesian(xlim = c(-10, 25), ylim = c(43, 60)) +
  geom_point(data = pep725_data,
             aes(x = lon, y = lat),
             col = "darkgoldenrod1",
             alpha = 0.8,
             pch = 15,
             size = 1) +
  xlab(expression(paste("Longitude (", degree, ")"))) +
  ylab(" ") +
  labs(title=expression("D. PEP725 (" * italic("Fagus sylvatica ssp.") * ")")) +
  theme_map()

# export device
pdf("~/Figure_3_site_location_map.pdf",9,7)
  grid.arrange(p, p1, p2, p3, ncol = 2)
dev.off()

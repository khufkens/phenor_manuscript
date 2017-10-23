# Figure 5

# Create spatial representations from scratch
# for full transparency in processing. Take
# into account that this might take a while
# for regenerating the maps as shown in
# the original manuscript. Mainly downloading
# and processing tiled Daymet data is rather slow.

# load the necessary libraries
library(phenor)
library(daymetr)
library(maps)
library(RColorBrewer)
library(raster)

# path to store phenor data
path = "~/phenor_files"

# check if the path exists if not create it
if ( !dir.exists(path) ){
  dir.create(path)
}

# set working directory, create path parameters in
# necessary functions (TODO)
setwd(path)

# download daymet tiles and format the data
# this might take a while (be warned), first
# list all the tiles needed
tiles = c(
  11936, 12295, 12296, 12297,
  12114, 12115, 12116, 12117,
  11934, 11935, 11754, 11755,
  11756, 12294, 11937)

download all daymet tiles, include the preceeding year
as we need this data too (see start_yr).
daymetr::download_daymet_tiles(tiles = tiles,
                               param = c("tmin","tmax"),
                               start = 2010,
                               end = 2011)

# now calculate the mean daily temperature from tmin and tmax
lapply(tiles, function(x)daymetr::daymet_tmean(path = path,
                                               tile = x,
                                               year = 2010,
                                               internal = FALSE))

lapply(tiles, function(x)daymetr::daymet_tmean(path = path,
                                               tile = x,
                                               year = 2011,
                                               internal = FALSE))

# now format all tiles acoording to the phenor format
# (default settings)
lapply(tiles, function(x)daymet_data = format_daymet_tiles(
  path = path,
  tile = x,
  year = 2011,
  internal = FALSE))

download_cmip5(path = path,
               model = "IPSL-CM5A-MR",
               scenario = "rcp85",
               year = 2011)

download_cmip5(path = path,
               model = "IPSL-CM5A-MR",
               scenario = "rcp85",
               year = 2099)

# get cmip5 data for the end of the century
# if file exists...
format_cmip5(path = path,
             year = 2100,
             internal = FALSE)
format_cmip5(path = path,
             year = 2011,
             internal = FALSE)

cmip5_data_2011 = readRDS("~/phenor_cmip5_data_2011.rds")
cmip5_data_2100 = readRDS("~/phenor_cmip5_data_2100.rds")

comparison = readRDS(file.path(path.package("phenor"),"extdata/comparison.rds"))
par = apply(comparison$phenocam_DB$modelled$PTT$parameters,2,mean)
par_grass = apply(comparison$phenocam_GR$modelled$PTT$parameters,2,mean)

# create maps using estimated parameters and
# the estimate_phenology routine
cmip5_map_2100 = estimate_phenology(par = par,
                               model = "PTT",
                               data = cmip5_data_2100)

# create maps using estimated parameters and
# the estimate_phenology routine
cmip5_map_2011 = estimate_phenology(par = par,
                                    model = "PTT",
                                    data = cmip5_data_2011)

# create maps using estimated parameters and
# the estimate_phenology routine
cmip5_map_2100_grass = estimate_phenology(par = par_grass,
                                    model = "PTT",
                                    data = cmip5_data_2100)

# create maps using estimated parameters and
# the estimate_phenology routine
cmip5_map_2011_grass = estimate_phenology(par = par_grass,
                                    model = "PTT",
                                    data = cmip5_data_2011)

daymet_map = estimate_phenology(par = par,
                                model = "PTT",
                                path = path)

# mask ocean values
data(wrld_simpl, package = "maptools")
ocean_mask = rasterize(wrld_simpl, cmip5_map_2100)
cmip5_map_2011 = mask(cmip5_map_2011, ocean_mask, maskvalue = NA)
cmip5_map_2100 = mask(cmip5_map_2100, ocean_mask, maskvalue = NA)
cmip5_map_2011_grass = mask(cmip5_map_2011_grass, ocean_mask, maskvalue = NA)
cmip5_map_2100_grass = mask(cmip5_map_2100_grass, ocean_mask, maskvalue = NA)

# select those land cover pixels
# with more than 1/4 of the pixel covered
# igbp classes 1/4/5/10 are included in the
# package as igbp_#
m = igbp_4 > 0.5 | igbp_5 > 0.5
m[m==0] = NA
m_grass = igbp_10 > 0.5
m_grass[m_grass==0] = NA

# create difference map
cmip5_map_diff = cmip5_map_2100 - cmip5_map_2011
cmip5_map_diff_grass = cmip5_map_2100_grass - cmip5_map_2011_grass

# Generate the final plot comparing model output
# across various scales and time frames use
# a pdf device for quality graphs
pdf("~/Figure_5_spatial_runs.pdf",12,10)

# set margins and general layout
# of subplots
par(oma = c(5,4,5,2))
layout(matrix(c(1,1,2,2,
                1,1,2,2,
                3,3,2,2,
                3,3,2,2,
                4,4,5,5),
              5, 4, byrow = TRUE))

# define the colours to use
cols = colorRampPalette(brewer.pal(9,'RdBu'))(100)

zlim =  c(100,200)
zlim_delta = c(-60,5)
ratio = abs(zlim_delta[1]/zlim_delta[2])

ylgn = colorRampPalette(brewer.pal(5,"YlGn"))(50)
ylorbr = colorRampPalette(brewer.pal(5,"YlOrBr"))(50/ratio)
ylgn = ylgn[c(-1:-4)]
ylorbr = ylorbr[-1]
cols_delta = c(rev(ylgn),ylorbr)

# loop over all datasets and plot them in the
# correct order with adjusted settings

# top left
    par(mar = c(1,1,0,1),
        cex = 1.1,
        cex.lab = 1.1)
    image(cmip5_map_diff * m,
          xlab = '',
          ylab = '',
          xaxt = 'n',
          yaxt  = 'n',
          tck = 0.02,
          bty = 'n',
          zlim = zlim_delta,
          col = cols_delta)
    box()
    map("world",
        col = "grey25",
        add = TRUE)
    mtext("CMIP5 (25x25 km)",
          side = 3,
          line = 1,
          cex = 1.3)
    axis(1,
         tck = 0.02,
         labels = FALSE)
    axis(2,
         tck = 0.02)
    legend("bottomright",
           "a",
           bty = "n",
           cex = 1.5)

# top right
    par(mar = c(0,1,0,1))
    image(daymet_map,
          xlab = '',
          ylab = '',
          xaxt = 'n',
          yaxt  = 'n',
          tck = 0.02,
          bty = 'n',
          zlim = zlim,
          col = cols)
    box()
    map("world",
        col = "grey25",
        add = TRUE)
    mtext("Daymet (1x1 km)",
          side = 3,
          line = 1,
          cex = 1.3)
    axis(1,
         tck = 0.02)
    axis(4,
         tck = 0.02)
    mtext(text = "longitude",
          side = 1,
          line = 3,
          cex = 1.5)
    legend("bottomright",
           "c",
           bty = "n",
           cex = 1.5)
    segments(-68.921274, 45.904354, -68, 44,
             lwd = 1,
             lty = 2)
    text(-68, 43.8, "Mt. Katahdin", cex = 1.3)
    points(-71.063611,42.358056,
           pch = 19,
           cex = 1.5)
    text(-71.063611,
         42.358056,
         "Boston",
         cex = 1.3, pos = 2)

# plot a filtered version of the be_map data
par(mar = c(0,1,1,1))
image(cmip5_map_diff_grass * m_grass,
      xlab = '',
      ylab = '',
      xaxt = 'n',
      yaxt  = 'n',
      tck = 0.02,
      bty = 'n',
      zlim = zlim_delta,
      col = cols_delta)
box()
map("world",
    col = "grey25",
    add = TRUE)
axis(1,
     tck = 0.02,
     labels = FALSE)
axis(2,
     tck = 0.02)
mtext(text = "latitude",
      side = 2,
      line = 3,
      adj = 1,
      cex = 1.5)
legend("bottomright",
       "b",
       bty = "n",
       cex = 1.5)
axis(1,
     tck = 0.02)
axis(2,
     tck = 0.02)
mtext(text = "longitude",
      side = 1,
      line = 3,
      cex = 1.5)

# colour legend
par(mar = c(1,1,5,1))
imageScale(cmip5_map_diff,
           col = cols_delta,
           zlim = zlim_delta,
           cex = 1.5,
           axis.pos = 1)

mtext(expression(Delta*" DOY (2100 - 2011)"),
      1,
      3,
      cex = 1.5)

# colour legend
par(mar = c(1,1,5,1))
imageScale(daymet_map,
           col = cols,
           zlim = zlim,
           cex = 1.5,
           axis.pos = 1)

mtext("DOY",
      1,
      3,
      cex = 1.5)

# close device to generate a valid output file
dev.off()

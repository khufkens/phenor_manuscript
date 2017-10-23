# This script shows how you download
# and format data from various data sources
# some data is included in the phenor manuscript repository

# download and optimize data
tmp_path = "~/phenor_files"

# create temporay directory for some of the data
# if it doesn't exist
if(!dir.exists(tmp_path)){
  dir.create(tmp_path)
}

# load or download necessary data
# [create a proper pep725login.txt file first]
download_pep725(credentials = "~/phenor_files/pep725login.txt",
                species = "Fagus",
                internal = FALSE,
                path = tmp_path)

# download eobs data, please register before using this function
# [might take a while]
server_path = "http://www.ecad.eu/download/ensembles/data/Grid_0.25deg_reg"

products = c(
  "tg_0.25deg_reg_v16.0.nc.gz",
  "tn_0.25deg_reg_v16.0.nc.gz",
  "tx_0.25deg_reg_v16.0.nc.gz",
  "rr_0.25deg_reg_v16.0.nc.gz",
  "elev_0.25deg_reg_v16.0.nc.gz"
)

lapply(products, function(product){
  httr::GET(sprintf("%s/%s",server_path, product),
            httr::write_disk(sprintf("%s/%s",
                                     tmp_path,
                                     product),
                             overwrite = TRUE),
            httr::progress())
})

# format pep725 data (Fagus sylvatica) and save
pep725_data = format_pep725(pep_path = tmp_path,
                            eobs_path = tmp_path)
saveRDS(pep725_data,"~/phenor_files/pep725_demo_data.rds")

# Download USA-NPN data (Acer rubrum)
# download all phenophases, select in format routine
# format and save
npn_data = download_npn(species = 3, phenophase = NULL)
npn_data = format_npn(npn_data)

# Download / format modis data and save
# check the modis directory (data is included in the phenor manuscript repo)
modis_data = format_modis(path = "./data/modis/")
saveRDS(modis_data,"~/phenor_files/modis_demo_data.rds")

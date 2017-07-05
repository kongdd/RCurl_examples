rm(list = ls())
library(openxlsx)
source("R/MainFunction.R", encoding = "utf-8") 
source("RCurl_modis/modisTools-v5.R", encoding = "utf-8")

df <- read.xlsx("RCurl_modis/data/siteinfo.xlsx")
Id_name <- read.xlsx("RCurl_modis/data/Sites.xlsx", colNames = F)[, 1]
df <- df[match(Id_name, df$Site.ID), ]

data.table::fwrite(df, file = "RCurl_modis/data/stationInfo.txt", sep = "\t")

email <- "kongdd@mail2.sysu.edu.cn"
srcs <- list()

for (i in 1:nrow(df)){
  cat(sprintf("[%d]: ------------\n", i))
  lat <- df$Latitude[i]
  lon <- df$Longitude[i]
  srcs[[i]] <- getMODIS_points(lat, lon, email)
}

[2] "http://modis.ornl.gov/glb_viz_3/05Jul2017_02:09:26_320764023L-12.542499542236328L131.30700683593699S7L7_MYD15A2/index.html"
[3] "http://modis.ornl.gov/glb_viz_3/05Jul2017_02:09:44_706199403L-12.49429988861084L131.15199279785156S7L7_MYD15A2/index.html" 
[4] "http://modis.ornl.gov/glb_viz_3/05Jul2017_02:09:52_866766203L-35.65570068359375L148.15199279785156S7L7_MYD15A2/index.html" 
[5] "http://modis.ornl.gov/glb_viz_3/05Jul2017_02:10:02_085187762L-37.429000854492187L145.18699645996S7L7_MYD15A2/index.html" 


urls <- unlist(srcs)
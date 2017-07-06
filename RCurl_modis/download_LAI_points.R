rm(list = ls())
library(openxlsx)
library(purrr)
library(data.table)

source("R/MainFunction.R", encoding = "utf-8") 
source("RCurl_modis/modisTools-v5.R", encoding = "utf-8")

## 01. get station informations from xlsx files
df <- read.xlsx("RCurl_modis/data/siteinfo.xlsx")
Id_name <- read.xlsx("RCurl_modis/data/Sites.xlsx", colNames = F)[, 1]
df <- df[match(Id_name, df$Site.ID), ] %>% set_rownames(NULL)

#save stationInfo
fwrite(df, file = "RCurl_modis/data/stationInfo.txt", sep = "\t")

# convert dataframe into list
xlist <- transpose(df) %>% {set_names(., seq_along(.))}

# set the email which is used to get download urls
email <- "kongdd@mail2.sysu.edu.cn"

## 02. for loop download (one request a time)
# srcs <- rep(NA, nrow(df))
srcs <- list()
Id <- 1:nrow(df)
for (i in Id){
	cat(sprintf("[%d]: ------------\n", i))
	srcs[[i]] <- getMODIS_points(xlist[[i]])
}

## 03. parallel download
vars = c("header", "html_inputs", "xml_check")
pkgs <- c("httr", "xml2", "magrittr")

cl <- makeCluster(1, outfile = "log.txt")

clusterEvalQ(cl, 
	invisible(lapply(c("httr", "xml2", "magrittr"), library, character.only = TRUE)))
clusterExport(cl, vars)
clusterEvalQ(cl, source("RCurl_modis/modisTools-v5.R", encoding = "utf-8"))

## need to learn R envirnment to fully understand eval and substitute function
# cluster_Init(n = 8, 
#              vars = c("header", "html_inputs"),
#              pkgs = c("httr", "xml2", "magrittr"),
#              expr = source("RCurl_modis/modisTools-v5.R", encoding = "utf-8"))
result <- list()

## repeat to evaluate expr until times >= 10, or fully success
#  I can't understand why parallel downloading didn't save much time! 
times <- 0
while (TRUE & times < 10){
	if (length(result) > 0){
		Id <- sapply(result, is.na) %>% which(.)
		if (length(Id) == 0) break
	} else{
		Id <- seq_along(xlist)
	}

	srcs <- parLapplyLB(cl, xlist[Id], getMODIS_points)
	result[Id] <- srcs

	times <- times + 1
}

# save(srcs, file = "srcs.rda")
write_urls(unlist(result), 'lai.txt')

## 04. Generate download links for aria2----
xx <- fread("lai.txt", sep = "\t", header = F)$V1 %>% sort

lai <- character()
fpar <- character()
## batch set download file names for aria2
for (i in 1:nrow(df)){
  src <- dirname(xx[i])
  lai[i] <- sprintf("%s/filtered_scaled_Lai_1km.asc\n\tout=LAI_[%03d]_%s.txt", src, i, df$Site.ID[i])
  fpar[i] <- sprintf("%s/filtered_scaled_Fpar_1km.asc\n\tout=FPAR_[%03d]_%s.txt", src, i, df$Site.ID[i])
}

urls <- c(lai, fpar) %>% sort
write_urls(urls, "RCurl_modis/data/download_LAI.txt")

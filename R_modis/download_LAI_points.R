rm(list = ls())
library(openxlsx)
library(data.table)
library(purrr)
library(parallel)

# source("R/MainFunction.R", encoding = "utf-8") 
source("modisTools-v5.R", encoding = "utf-8")

## 01. get station informations from xlsx files
df <- fread("FluxSite.csv") %>% as.data.frame()

# convert dataframe into list
xlist <- transpose(df) %>% {set_names(., seq_along(.))}
# getMODIS_points(xlist[[1]])

# set the email which is used to get download urls
email <- "kongdd@mail2.sysu.edu.cn"

## 02. for loop download (one request a time)
# srcs <- rep(NA, nrow(df))
# srcs <- list()
# Id <- 1:nrow(df)
# for (i in Id){
# 	cat(sprintf("[%d]: ------------\n", i))
# 	srcs[[i]] <- getMODIS_points(xlist[[i]])
# }

## 03. parallel download
vars = c("header", "html_inputs", "xml_check")
pkgs <- c("httr", "xml2", "magrittr")

cl <- makeCluster(4, outfile = "log.txt")

tmp <- clusterEvalQ(cl, 
	invisible(lapply(c("httr", "xml2", "magrittr"), library, character.only = TRUE)))
clusterExport(cl, vars)
tmp <- clusterEvalQ(cl, source("modisTools-v5.R", encoding = "utf-8"))

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

save(srcs, file = "srcs.rda")
# write_urls(unlist(result), 'lai.txt')

# ## 04. Generate download links for aria2----
# xx <- fread("lai.txt", sep = "\t", header = F)$V1 %>% sort
write_urls <- function(urls, file){
  # data.table::fwrite(data.frame(urls), file, col.names = F)
  write.table(data.frame(urls), file, col.names = F, row.names = F, quote=F)
}

xx <- unlist(result)
lai <- character()
fpar <- character()
## batch set download file names for aria2
for (i in 1:nrow(df)){
  src <- dirname(xx[i])
  lai[i] <- sprintf("%s/filtered_scaled_Lai_1km.asc\n\tout=LAI_[%03d]_%s.txt", src, i, df$SiteCode[i])
  fpar[i] <- sprintf("%s/filtered_scaled_Fpar_1km.asc\n\tout=FPAR_[%03d]_%s.txt", src, i, df$SiteCode[i])
}

urls <- c(lai, fpar)#%>% sort
write_urls(urls, "download_LAI.txt")

# ## 
# x <- fread("RCurl_modis/data/download_LAI.txt", header = F, sep = ",")$V1 %>%
# {.[seq(1, length(.), 4)]}

# pos <- str_extract_all(x, "(?<=L)[-]{0,}\\d{1,}.\\d{1,}") %>% 
#   laply(function(x) paste(x[1], x[2], sep = "|"))

# Id <- match(pos, paste(df$Latitude, df$Longitude, sep = "|"))
# # all.equal(match(pos[[1]], df$Latitude), match(pos[[2]], df$Longitude))

# files <- dir("RCurl_modis/data/data", full.names = T, pattern = "LAI_.*")
# file.copy(files, paste0("RCurl_modis/data/LAI/", basename(files)[Id]))

# files <- dir("RCurl_modis/data/data", full.names = T, pattern = "FPAR_.*")
# file.copy(files, paste0("RCurl_modis/data/FPAR/", basename(files)[Id]))

# ## check missing downloads
# files <- dir("RCurl_modis/data/LAI", full.names = T, pattern = "*.txt")
# str_extract(files, "\\d{1,}") %>% as.numeric() %>% setdiff(1:252, .)

# files <- dir("RCurl_modis/data/fpar/", full.names = T, pattern = "*.txt")
# Id <- str_extract(files, "\\d{1,}") %>% as.numeric() %>% 
#   setdiff(1:252, .) %T>% print 

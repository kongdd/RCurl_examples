# source("E:/GitHub/RCurl_project/R/MainFunction.R", encoding = "utf-8")
library(httr)
library(xml2)
library(magrittr)

header <- "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
url <- "https://modis.ornl.gov/cgi-bin/MODIS/GLBVIZ_1_Glb/modis_subset_order_global_col5.pl"
# handle_reset("https://modis.ornl.gov") #quite important
# Sys.setlocale("LC_TIME", "english")#

xml_check <- function(x){
  if(class(x)[1] %in% c("xml_document", "xml_node")) x else read_html(x)
}

html_inputs <- function(p, xpath = "//form/input"){
  xml_check(p) %>% xml_find_all(xpath) %>% 
    {setNames(as.list(xml_attr(., "value")), xml_attr(., "name"))}
}

set_config(c(
  # verbose(),
  timeout(60),
  add_headers(
    Connection =  "keep-alive",
    `Accept-Encoding` = "gzip, deflate, br",
    `Accept-Language` = "zh-CN,zh;q=0.8,en;q=0.6",
    Host = "modis.ornl.gov",
    Origin = "https://modis.ornl.gov",
    Referer = url,
    `Upgrade-Insecure-Requests` = 1,
    `User-Agent` = header
  )
))
# p <- GET(url, verbose())

getMODIS_points <- function(pos, email = "kongdd@live.cn") {
    lat <- pos$Latitude
    lon <- pos$Longitude

    times <- 4
    # lat = "35.958767"
    # lon = "-84.287433"
    # email = "kongdd@live.cn"
    blank_params <- c("show_name", "albedo", "albedo_product")
    src <- tryCatch({
      cat(sprintf("\t| 1. Post position information ...\n"))
      param1 <- list(lat = lat, lon = lon, from_initial_load = "Continue")
      # If falied than try aagain
      p1 <- RETRY("POST", url, body = param1, times = times) %>% content()
 
      # p1 %>% xml_find_first("//body") %>% xml_text() %>% cat
      # save_html(p1)
      # ----- 02. select params
      param2 <- c(
        display_product = "MOD15A2",
        html_inputs(p1, "//input")[1:13]
      ) #%T>% str
      
      cat(sprintf("\t| 2. Post product MOD15A2 ...\n"))
      p2 <- RETRY("POST", url, body = param2, times = times) %>% content()
 
      # ----- 03. retrieve data through email ------
      param3 <- c(
        start_modis_dates = "01/01/2000",
        end_modis_dates   = "03/22/2017",
        geotiff           = "geotiffreproject",
        email             = email,
        html_inputs(p2, "//input")[4:27]
      )
      # param3[blank_params] <- ""
      
      cat(sprintf("\t| 3. Post email and project information ...\n"))
      p3 <- RETRY("POST", url, body = param3, times = 4) %>% content()
 
      # ----- 04 confirm submit
      param4 <- html_inputs(p3, "//input")[1:32]
      param4[c(blank_params, "szn", "in_od", "pretty_modis_date")] <- ""
      
      cat(sprintf("\t| 4. submit confirm ...\n"))
      p4 <- RETRY("POST", url, body = param4, times = times) %>% content()
      
      # show orders in the queue
      orders <- xml_find_first(p4, '//p[@style="font-weight: bold;"]/span') %>% xml_text()
      cat(sprintf(" \t| [%s] orders in the queue ...\n", orders))
      
      xml_find_first(p4, "//p/a[@target='_blank']") %>% xml_attr("href")
      
      # xml_find_first(p4, "//body") %>% xml_text %>% cat
      # save_html(p4)
    }, error = function(e){
      message(sprintf("[%d]: %s", 1, e))
      NA
    })
    cat(sprintf("\t ** %s **\n", src))
    return(src)
  }
## download raw data
# https://modis.ornl.gov/glb_viz_3/03Jul2017_04:26:50_730751277L-29.2639999389648L-61.0279998779296S7L7_MYD15A2/filtered_scaled_Lai_1km.asc
# http://modis.ornl.gov/glb_viz_3/03Jul2017_04:26:50_730751277L-29.2639999389648L-61.0279998779296S7L7_MYD15A2/filtered_scaled_Fpar_1km.asc

#' retry to execute expr until success before reaches the max try times (maxTimes)
retry <- function(expr, maxTimes = 3){
  eTimes <- 0
  out <- NULL
  while (eTimes < maxTimes){
    out <- tryCatch({
      expr
      eTimes <- maxTimes
    }, error = function(e){
      eTimes <<- eTimes + 1
      message(sprintf("[try%d]: %s", eTimes, e))
      NULL #If error return NULL
    })
  }
  return(out)
}
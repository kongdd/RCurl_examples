# source("E:/GitHub/RCurl_project/R/MainFunction.R", encoding = "utf-8")
# library(RCurl)

library(curl)
library(httr)
library(xml2)
library(rvest)
library(V8)
library(jsonlite)

library(magrittr)
library(reshape2)
library(plyr)
library(stringr)
library(foreach)
library(iterators)

library(readr)
library(openxlsx)
library(parallel)
library(floodmap) #private package, could be found in my Github.

# Sys.setlocale("LC_TIME", "english") #
# Sys.setlocale("LC_ALL","English")
# Sys.getlocale(category = "LC_ALL")
# [1] "LC_COLLATE=English_United States.1252;LC_CTYPE=English_United States.1252;LC_MONETARY=English_United States.1252;LC_NUMERIC=C;LC_TIME=English_United States.1252"

# set httr global header
header <- "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"

set_config(c(add_headers(`User-Agent` = header,
  Connection =  "keep-alive")))



#' @return time stamp, just like 1498029994455 (length of 13)
systime <- function() as.character(floor(as.numeric(Sys.time())*1000))

## -------------- html & xml functions ----------------
xml_check <- function(x){
  if(class(x)[1] %in% c("xml_document", "xml_node")) x else read_html(x)
}

save_html <- function(x, file = "kong.html") write_xml(xml_check(x), file)

html_body <- function(p, xpath = "//body") xml_find_all(xml_check(p), xpath)

html_inputs <- function(p, xpath = "//form/input"){
  xml_check(p) %>% xml_find_all(xpath) %>% 
    {setNames(as.list(xml_attr(., "value")), xml_attr(., "name"))}
}

getElementById <- function(p, Id) xml_check(p) %>% xml_find_all(sprintf("//*[@id='%s']", Id))
getElementByName <- function(p, Id) xml_check(p) %>% xml_find_all(sprintf("//*[@name='%s']", Id))

uniqid <- function(){
  ctx <- v8();
  ctx$source("R/uniqid.js")
  # ctx$eval("uniqid('----WebKitFormBoundary')")
  ctx$eval("uniqid('------------------------706')")
}
# "----WebKitFormBoundary595a651253cfe"
# ------------------------706b9a0dff09e04c
## ------------------------------- GLOBAL FUNCTIONS --------------------------
listk <- function(...){
  # get variable names from input expressions
  cols <- as.list(substitute(list(...)))[-1]
  vars <- names(cols)
  Id_noname <- if (is.null(vars)) seq_along(cols) else which(vars == "")

  if (length(Id_noname) > 0)
    vars[Id_noname] <- sapply(cols[Id_noname], deparse)
  # ifelse(is.null(vars), Id_noname <- seq_along(cols), Id_noname <- which(vars == ""))
  x <- setNames(list(...), vars)
  return(x)
}

#' Get query paramters from URL address
#' 
#' @param show If TRUE, it whill print returned parameter in the console.
#' @param clip If TRUE, it will get url string from clipboard
#' @param quote If TRUE, params names print in console will use quote.
#' @examples:
#' url <- "http://elearning.ne.sysu.edu.cn/webapps/discussionboard/do/message?layer=forum&currentUserInfo=***&conf_id=_413_1&numAttempts=1626&type=user_forum&attempt_id=_5918115_1&callBackUrl=%2Fwebapps%2Fgradebook%2Fdo%2Finstructor%2FviewNeedsGrading%3Fcourse_id%3D_405_1%26courseMembershipId%3D_3928655_1%26outcomeDefinitionId%3D_114127_1&forum_id=_61110_1&currentAttemptIndex=1&nav=discussion_board_entry&action=collect_forward&origRequestId=0D68B9644B97B73FA532AC7B5119169C.root_1498061370964&user_id=_227280_1&course_id=_405_1&sequenceId=_405_1_0&viewInfo=%E9%9C%80%E8%A6%81%E8%AF%84%E5%88%86&
#' param <- url2params(url, returnI = T)
#' 
#' # param <- {
#' #   layer                	= "forum"
#' #   currentUserInfo      	= "2016秋入学专科 *** (活动)"
#' #   conf_id              	= "_413_1"
#' #   numAttempts          	= "1626"
#' #   type                 	= "user_forum"
#' #   attempt_id           	= "_5918115_1"
#' #   callBackUrl          	= "/webapps/gradebook/do/instructor/viewNeedsGrading?course_id=_405_1&courseMembershipId=_3928655_1&outcomeDefinitionId=_114127_1"
#' #   forum_id             	= "_61110_1"
#' #   currentAttemptIndex  	= "1"
#' #   nav                  	= "discussion_board_entry"
#' #   action               	= "collect_forward"
#' #   origRequestId        	= "0D68B9644B97B73FA532AC7B5119169C.root_1498061370964"
#' #   user_id              	= "_227280_1"
#' #   course_id            	= "_405_1"
#' #   sequenceId           	= "_405_1_0"
#' #   viewInfo             	= "需要评分"
#' # }
url2params <- function(url, show=T, clip = F, 
  quote = FALSE, 
  iconvI = TRUE,
  returnI = FALSE){
  if (clip) url <- suppressWarnings(readLines("clipboard"))
  # url <- URLdecode(url)
  # url %<>% URLdecode
  
  params <- as.list(getFormParams(url)) %>% 
    lapply(URLdecode)
  if (iconvI) params %<>% lapply(iconv, "utf-8", "gbk")
    # lapply(URLdecode) %>% lapply(iconv, "UTF-8", "gbk")
  
  # for the convenience of write param
  if (quote){
    str <- sprintf('  "%s" \t\t= "%s"', names(params), params) %>% 
      paste(collapse = ",\n") %>%
      paste0("param <- list(\n", ., "\n}") 
  }else{
    str <- sprintf('  %-20s \t= "%s"',  names(params), params) %>% 
      paste(collapse = ",\n") %>%
      paste0("param <- list(\n", ., "\n}") 
  }
  
  if (show) cat(str)
  writeLines(str, 'clipboard')
  if (returnI) return(params)
}

#' constuct URL based on query parameters
params2URL <- function(urlRaw, params){
  URL <- paste(urlRaw, paste(names(params), params, collapse = "&",sep="="), sep="?")
  return(URL)
}

#' get cookies from curl handle
getCookies_hf <- function(rhead = h$value()){
  # rhead <- h$value()
  cookies <- rhead[names(rhead)=="Set-Cookie"] %>%
    {lapply(strsplit(., ";"), `[`, i=1)} %>%
    paste(collapse = ";",sep = ";")
  return(cookies)
}

#' get cookies from httpheader update handle
getCookies_ch <- function(curl = ch){
  x <- getCurlInfo(ch)$cookielist
  strsplit(x, "\t") %>% do.call(rbind.data.frame, .) %>% 
    set_names(c("domain", "bool", "path", "bool2", "expires", "name", "value"))
}

cookies2list <- function(cookies){
  strsplit(cookies, ";")[[1]] %>% 
    ldply(function(x) strsplit(x, "=")[[1]]) %>% 
    {set_names(as.list(.[, 2]), .[, 1])}
}

#' convert Raw format string into the real raw format variable
#' @param raw format string
#' @return raw vector
#' @examples 
#' key_p <- "EB2A38568661887FA180BDDB5CABD5F21C7BFD59C090CB2D245A87AC253062882729293E5506350508E7F9AA3BB77F4333231490F915F6D63C55FE2F08A49B353F444AD3993CACC02DB784ABBB8E42A9B1BBFFFB38BE18D78E87A0E41B9B8F73A928EE0CCEE1F6739884B9777E4FE9E88A1BBE495927AC4A799B3181D6442443"
#' stringToRaw(key_p)
stringToRaw <- function(str){
  string <- raw()
  for(i in 1:(str_length(str)/2)){
    string[i] <- str_sub(str, (2*i-1), (2*i)) %>% 
      as.hexmode() %>% unlist %>% as.raw()
  }
  return(string)
}

#' Initial cluster
#' 
#' @description Initial a cluster cl, for parallel computing
#' @param n works of cluster
#' @param outfile file to save the parallel console logs
#' @param pkgs character vector, packages need to load in cluster
#' @param vars character vector, variables need to export to cluster
#' @return no return. But it will assign cl into global environment
cluster_Init <- function(n = 8, pkgs, vars, expr, outfile = "log.txt"){
  # print(deparse(substitute(expr)))
  # print(deparse(substitute(expr, env = parent.frame())))
  cl <- makeCluster(n, outfile = outfile)
  if (!missing(pkgs)) 
    clusterEvalQ(cl, invisible(lapply(substitute(pkgs), library, character.only = TRUE)))
  
  if (!missing(vars)) clusterExport(cl, vars)
  if (!missing(expr)) clusterEvalQ(cl, substitute(expr))
  
  assign("cl", cl, envir = .GlobalEnv)
}

# source("E:/GitHub/RCurl_project/R/MainFunction.R", encoding = "utf-8")
library(RCurl)
library(rvest)

library(V8)
library(xml2)
library(jsonlite)

library(magrittr)
library(reshape2)
library(plyr)
library(stringr)
library(foreach)
library(iterators)

library(readr)
library(openxlsx)
library(floodmap) #private package, could be found in my Github.

# set httr global header
header <- "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
set_config(c(add_headers(`User-Agent` = header)))


#' @return time stamp, just like 1498029994455 (length of 13)
systime <- function() as.character(floor(as.numeric(Sys.time())*1000))

## -------------- html & xml functions ----------------
xml_check <- function(x){
  p <- if(class(x)[1] %in% c("xml_document", "xml_node")) x else read_html(x)
  return(p)
}

save_html <- function(x, file = "kong.html") write_xml(xml_check(x), file)

html_body <- function(p, xpath = "//body") xml_find_all(xml_check(p), xpath)

html_inputs <- function(p, xpath = "//form/input"){
  xml_check(p) %>% xml_find_all(xpath) %>% 
    {setNames(as.list(xml_attr(., "value")), xml_attr(., "name"))}
}

getElementById <- function(p, Id) xml_check(p) %>% xml_find_all(sprintf("//*[@id='%s']", Id))
getElementByName <- function(p, Id) xml_check(p) %>% xml_find_all(sprintf("//*[@name='%s']", Id))


# ch <- get_header()
get_header <- function(host = "data.cma.cn", origin, cookie = "cookies.txt"){
  ## RCurl设置, 直接把cookie粘贴过来，即可登录
  myHttpheader<- c(
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
    # "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language" = "zh-CN,zh;q=0.8,en;q=0.6",
    # accept-encoding have a strong influence on res
    # "Accept-Encoding"="gzip, deflate",
    "Connection"="keep-alive",
    # DNT = 1, 
    # "Upgrade-Insecure-Requests" = 1, 
    Host = host,
    Origin = origin, #"http://data.cma.cn",
    "X-Requested-With" = "XMLHttpRequest")
  # file_cookie <- "cookies.txt"
  
  ch <- getCurlHandle(# cainfo="pem/cacert.pem",
    # ssl.verifyhost=FALSE, ssl.verifypeer = FALSE,
    followlocation = TRUE,
    verbose = TRUE, 
    cookiejar = cookie, cookiefile = cookie,
    httpheader = myHttpheader)#带上百宝箱开始上路
  tmp <- curlSetOpt(curl = ch)
  return(ch)
}

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



#' Get URL query paramters
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
  url %<>% URLdecode
  if (iconvI) url %<>% iconv("utf-8", "gbk")
  params <- as.list(getFormParams(url))
    # lapply(URLdecode) %>% lapply(iconv, "UTF-8", "gbk")
  
  # for the convenience of write param
  if (quote){
    str <- sprintf('  "%s" \t\t= "%s"', names(params), params) %>% 
      {paste(c('param <- {', ., '}'), collapse = "\n")}
  }else{
    str <- sprintf('  %-20s \t= "%s"',  names(params), params) %>% 
      {paste(c('param <- {', ., '}'), collapse = "\n")} 
  }
  
  if (show) cat(str)
  writeLines(str, 'clipboard')
  if (returnI) return(params)
}

params2URL <- function(urlRaw, params){
  URL <- paste(urlRaw, paste(names(params), params, collapse = "&",sep="="), sep="?")
  return(URL)
}

## global functions ---------------------
# getCookies <- function(rhead = h$value()){
#   # rhead <- h$value()
#   cookies <- rhead[names(rhead)=="Set-Cookie"]
#   cookies <- paste(lapply(strsplit(cookies, ";"),function(v) v[1]),collapse = ";",sep = ";")
#   return(cookies)
# }
getCookies <- function(curl = ch){
  x <- getCurlInfo(ch)$cookielist
  strsplit(x, "\t") %>% do.call(rbind.data.frame, .) %>% 
    set_names(c("domain", "bool", "path", "bool2", "expires", "name", "value"))
}
cookies2list <- function(cookies){
  strsplit(cookies, ";")[[1]] %>% 
    ldply(function(x) strsplit(x, "=")[[1]]) %>% {set_names(as.list(.[, 2]), .[, 1])}
}

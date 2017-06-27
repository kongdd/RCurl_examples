rm(list = ls())
library(RCurl)
library(xml2)
library(magrittr)
library(plyr)
library(rvest)
# setwd("RCurl_elearn/")
# source('R/MainFunction.R', encoding = 'UTF-8')

## 带上百宝箱上路,必须加上httpheader此站才返回数据
## your can also directly login using cookies from firefox or other browser
myHttpheader<- c(
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:50.0) Gecko/20100101 Firefox/50.0",
  "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "Accept-Encoding"="gzip, deflate",
  "Accept-Language" = "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
  "Connection"="keep-alive",
  # "Cookie" = "JSESSIONID=DD1F84CD54D9831F8065A5026039A9CC.root; safedog-flow-item=AE46F7B8895D4633E2C87C0C0809A2EB; session_id=D15553506517F2E4E65E8CCD6F8F3DCA; JSESSIONID=36FBE15A073E5FACDD6DB6A61E6ADB45.root; xythosdrive=0",
  DNT = 1,
  "Host" = "datacenter.mep.gov.cn",
  # Referer = url$referer, 
  "Upgrade-Insecure-Requests" = 1)
h <- basicHeaderGatherer()
ch <- getCurlHandle()#带上百宝箱开始上路
cookie <-"RCurl_envir/cookies_envir.txt"
tmp <- curlSetOpt(curl = ch, 
                  # cainfo="pem/cacert.pem",
                  # ssl.verifyhost=FALSE, ssl.verifypeer = FALSE,
                  followlocation = TRUE,
                  verbose = FALSE, 
                  cookiejar = cookie, cookiefile = cookie,
                  httpheader = myHttpheader)

url_origin <- "http://datacenter.mep.gov.cn/report/air_daily/air_dairy.jsp?city=&startdate=2017-01-02&enddate=2017-01-03"
p <- getURL(url_origin, curl=ch) %T>% print

get_pagedata <- function(p){
  table <- read_html(p) %>% html_node(xpath = '//table[@id="report1"]')
  tmp <- xml_remove(xml_children(table)[1:2])#删除首部无用信息
  df <- html_table(table, header = T) %>% {.[1:(nrow(.)-3), -1]}#删除最后三行，他们为页面信息
  return(df)
}

pageinfo <- xml_find_all(read_html(p), "//font") %>% xml_text() %>% as.numeric() %>% {setNames(as.list(.), c("counts", "pages", "per"))}

urls <- c(url_origin, paste(url_origin, 2:pageinfo$pages, sep = "&page="))
pages <- getURLAsynchronous(urls, curl = ch, verbose = T)
x <- ldply(pages, get_pagedata, .progress = "text")

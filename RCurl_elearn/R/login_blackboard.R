rm(list = ls())
# setwd("RCurl_elearn/")
library(V8)
library(xml2)
source('R/MainFunction.R', encoding = 'UTF-8')

userInfo <- read.table("RCurl_elearn/userInfo_black.txt", header = T, stringsAsFactors = F)
user <- as.character(userInfo$user)
pwd <- as.character(userInfo$pwd)

url <-list(
  login_netid = "https://cas.sysu.edu.cn/cas/login?service=http%3A%2F%2Felearning.ne.sysu.edu.cn%2Fwebapps%2Fbb-caszsdx-bb_bb60%2Findex.jsp",
  login_origin = "http://elearning.ne.sysu.edu.cn/webapps/login/",
  referer = "http://elearning.ne.sysu.edu.cn/",
  userinfo = "http://elearning.ne.sysu.edu.cn/webapps/portal/execute/topframe?tab_tab_group_id=_22_1&frameSize=LARGE",
  main = "http://elearning.ne.sysu.edu.cn/webapps/portal/frameset.jsp"
)

## your can also directly login using cookies from firefox or other browser
myHttpheader<- c(
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:50.0) Gecko/20100101 Firefox/50.0",
  "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "Accept-Encoding"="gzip, deflate",
  "Accept-Language" = "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
  "Connection"="keep-alive",
  DNT = 1,
  "Host" = "elearning.ne.sysu.edu.cn",
  # Referer = url$referer, 
  "Upgrade-Insecure-Requests" = 1)
h <- basicHeaderGatherer()
ch <- getCurlHandle()#带上百宝箱开始上路
cookie <-"RCurl_elearn/cookies_elearn.txt"
tmp <- curlSetOpt(curl = ch, 
           cainfo="pem/cacert.pem",
           ssl.verifyhost=FALSE,
           ssl.verifypeer = FALSE,
           followlocation = TRUE,
           verbose = FALSE, 
           cookiejar = cookie, cookiefile = cookie,
           httpheader = myHttpheader)
# login -------------------------------
tmp <- getURL(url$login_origin, curl = ch, headerfunction = h$update)
one_time_token <- read_html(tmp) %>% xml_find_all("//input[@name='one_time_token']") %>% xml_attr("value")

ct <- v8()
ct$source("RCurl_elearn/src/blackboard.js")
encode_pws <- ct$call("kong", one_time_token, pwd)

params <- list(
  action="login",
  auth_type="",
  encoded_pw=encode_pws[1],
  encoded_pw_unicode=encode_pws[2],
  login = "登陆",#iconv("登陆", "gb2312", "utf-8") %>% URLencode(),
  new_loc =" ",#"%C2%A0", #" ",
  one_time_token=one_time_token,
  password = "",
  "remote-user"="",
  user_id = user)
page <- postForm(url$login_origin, .params = params, curl = ch,
                 # origin="http://elearning.ne.sysu.edu.cn", refere="http://elearning.ne.sysu.edu.cn/",
                 style="post") #%T>% print

# p <- params2URL(url$login_origin, params) %>% getURL(curl = ch)
# get data ----------------------------------------------------------------
p <- getURL(url$userinfo, curl = ch) 
grep("孔冬冬", p)#now you can find your name in p


## httr package version
# r <- VERB(
#   verb = "POST",
#   url = "http://elearning.ne.sysu.edu.cn/webapps/login/",
#   add_headers(
#     Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
#     `Accept-Encoding` = "gzip, deflate",
#     `Accept-Language` = "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
#     Connection = "keep-alive",
#     DNT = "1",
#     Host = "elearning.ne.sysu.edu.cn",
#     Referer = "http://elearning.ne.sysu.edu.cn/",
#     `Upgrade-Insecure-Requests` = "1",
#     `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:50.0) Gecko/20100101 Firefox/50.0"
#   ),
#   set_cookies(
#     `safedog-flow-item` = "AE46F7B8895D4633E2C87C0C0809A2EB",
#     session_id = "2435F5617696E3589423AB68A8095972",
#     JSESSIONID = "FF8E0085028F870368CBD150DAAB036E.root"
#   ),
#   body = list(
#     user_id = "fdjs146",
#     password = "",
#     login = iconv("登陆", "gb2312", "utf-8") %>% URLencode(),
#     action = "login",
#     `remote-user` = "",
#     new_loc = "%C2%A0",
#     auth_type = "",
#     one_time_token = one_time_token,
#     encoded_pw=encode_pws[1],
#     encoded_pw_unicode=encode_pws[2]
#   ),
#   encode = "form"
# )


## curl command login
# library(curlconverter)
# library(jsonlite)
# library(httr)
# con <- straighten("curl 'http://elearning.ne.sysu.edu.cn/webapps/login/' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3' -H 'Connection: keep-alive' -H 'Cookie: safedog-flow-item=AE46F7B8895D4633E2C87C0C0809A2EB; session_id=2435F5617696E3589423AB68A8095972; JSESSIONID=FF8E0085028F870368CBD150DAAB036E.root' -H 'DNT: 1' -H 'Host: elearning.ne.sysu.edu.cn' -H 'Referer: http://elearning.ne.sysu.edu.cn/' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:50.0) Gecko/20100101 Firefox/50.0' -H 'Content-Type: application/x-www-form-urlencoded' --data 'user_id=fdjs146&password=&login=%E7%99%BB%E5%BD%95&action=login&remote-user=&new_loc=%C2%A0&auth_type=&one_time_token=EE18F32E70018BC56D9226C75212E9F2&encoded_pw=F698DB6B490E095564975CB716699479&encoded_pw_unicode=E682AAF688707DF79154EDF4E52ABFE3'")
# req <- make_req(con)
# p <- content(req[[1]])


## 03.netid login

# page <- getURL(url, curl=ch) %>% read_html()
# inputs <- xml_find_all(page, '//form[@id="fm1"]/section/input')
# params <- inputs %>% {setNames(as.list(xml_attr(., "value")), xml_attr(., "name"))}
# params$username <- "****"
# params$password <- "****"
# 
# p <- postForm(url$login, .params = params, curl = ch, style="post")
# p2 <- getURL("http://elearning.ne.sysu.edu.cn/webapps/portal/frameset.jsp", curl = ch,
#              headerfunction = h$update)
# grep("孔冬冬", p2)



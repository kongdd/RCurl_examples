# rm(list = ls())
# setwd("RCurl_elearn/")
library(V8)
library(xml2)
library(httr)
source('R/MainFunction.R', encoding = 'UTF-8')

#' There is one problem that httr package same like can't clear 
#' previous cookie, in the debug model.


## 00. Set global 
set_config(add_headers(Host = "elearning.ne.sysu.edu.cn",
                       Origin = "http://elearning.ne.sysu.edu.cn"))
handle_reset("http://elearning.ne.sysu.edu.cn/") #quite important

userInfo <- read.table("RCurl_elearn/userInfo_black.txt", header = T, stringsAsFactors = F)
user <- as.character(userInfo$user)
pwd <- as.character(userInfo$pwd)

url <-list(
  login_origin = "http://elearning.ne.sysu.edu.cn/webapps/login/",
  referer = "http://elearning.ne.sysu.edu.cn/",
  userinfo = "http://elearning.ne.sysu.edu.cn/webapps/portal/execute/topframe?tab_tab_group_id=_22_1&frameSize=LARGE"
)

## 01. GET the one_time_token parameter
p <- GET(url$login_origin, verbose()) %>% content()
one_time_token <- xml_find_all(p, "//input[@name='one_time_token']") %>% xml_attr("value")

## 02. encode password using JS
ct <- v8()
ct$source("RCurl_elearn/src/blackboard.js")
encode_pws <- ct$call("kong", one_time_token, pwd)

## 03. construct login parameters
# login   : iconv("登录", "gb2312", "utf-8") %>% URLencode(),
# new_loc : #"%C2%A0", #" ",
params <- list(
  user_id = user,
  password = "",
  login = "登录",
  action="login",
  "remote-user"="",
  new_loc =" ",
  auth_type="",
  one_time_token=one_time_token,
  encoded_pw=encode_pws[1],
  encoded_pw_unicode=encode_pws[2])

p <- POST(url$login_origin, body = params, encode = "form", 
           verbose()) %>% content()

## 04. verify whether login successfully
p2 <- GET(url$userinfo) %>% content()
grep("孔冬冬", as.character(p2))#now you can find your name in p


## clear cookies in httr package
# https://stackoverflow.com/questions/39979393/how-to-remove-cookies-preserved-by-httrget

# detach("package:httr", unload=TRUE)
# library(httr)

# h1 <- handle('')
# r1 <- GET("https://some.url/login", handle=h1, authenticate("foo", "bar"))
# 
# h2 <- handle('')
# r2 <- GET("https://some.url/data/?query&subset=1", handle=h2)
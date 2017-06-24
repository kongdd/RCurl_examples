# library(RCurl) 
# library(rjson)
library(stringr)
# library(XML)
library(PKI)
library(magrittr)

rm(list = ls())
source("E:/GitHub/RCurl_project/R/MainFunction.R", encoding = "utf-8")

## global functions ----------------------------

#' @description encode username and password for sina blog using R packages
#' @param user character, sina username
#' @param pwd  character, sina user's password
#' @param params_Init list variable, pubkey, nonce and servertime are needed to encode
encode_sina <- function(user, pwd, params){
	su <- as.character(base64Encode(user))
	
	key_p <- stringToRaw(params$pubkey)
	#c("DER", "PEM", "key")
	pubkey_p <- PKI.mkRSApubkey(key_p, exponent = 65537L, format = "key")
	keyword <- paste0(params$servertime, "\t", params$nonce, "\n", pwd)
	
	passwd <- PKI.encrypt(charToRaw(keyword), pubkey_p)
	passwd <- paste(as.character(passwd), sep = "", collapse = "")
	return(list(su = su, sp = passwd))
}

## global variables ---------------------------
urls <- list(
  pre = "http://login.sina.com.cn/sso/prelogin.php?entry=account&callback=sinaSSOController.preloginCallBack&su=&rsakt=mod&client=ssologin.js(v1.4.15)&_=",
  login = "http://login.sina.com.cn/sso/login.php?client=ssologin.js(v1.4.15)&_="
)

# post data for urls$login
loginData <- c(
  "entry"      = "sso",
  "gateway"    = "1",
  'from'       = "null",
  "savestate"  = "30",
  "useticket"  = "0",
  "pagerefer"  = "",
  "vsnf"       = "1",
  "su"         = "",
  "service"    = "sso",
  "servertime" = "",
  "nonce"      = "",
  "pwencode"   = "rsa2",
  "rsakv"      = "",
  "sp"         = "",
  "sr"         = "1366*768",
  "encoding"   = "UTF-8",
  "cdult"      = "3",
  "domain"     = "sina.com.cn",
  "prelt"      = "100",
  "returntype" = "TEXT"
)

# header <- c(
#   "Connection"     = "keep-alive",
#   "Host"           = "login.sina.com.cn",
#   "User-Agent"     = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
#   "Accept"         = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
#   "Origin"         = "http://login.sina.com.cn",
#   "Referer"        = "http://login.sina.com.cn/?r=/member/my.php?entry=sso"
# )
# "Content-Length" =523,
# "Content-Type"   ="application/x-www-form-urlencoded",

## MAIN scripts -----------------------------------------
# 01. To the data of servertime, pubkey, nouce, rsakv and other parameters
p1 <- GET(url = paste0(urls$pre, systime())) %>% content("text")
# convert string in the () as json data
params_Init <- fromJSON(str_extract(p1, "(?<=\\().*(?=\\))")) 

# 01. Get user informations, and encode username and password
info <- read.table("Rweibo/User_weibo.txt", stringsAsFactors = F, header = T)
# you can also input your username and password here directly. But reading the
# information from txt file, can protect your user information when sharing code.
user <- info$user %>% URLencode(reserved = TRUE) 
pwd  <- info$pwd
Info <- encode_sina(user, pwd, params_Init)

# Update login post parameters
vars <- c("su", "sp", "rsakv", "servertime", "nonce")
loginData[vars] <- c(Info, params_Init)[vars]

# 02. post data to get the verification URL
p2 <- POST(url = paste0(urls$login, systime()), 
           body = loginData, encode = "form",
           verbose()) %>%
  content("text", encoding = "UTF-8") 

# 03. PASS the verfication and update httpheader info and get cookies

p3 <- GET(fromJSON(p2)$crossDomainUrlList[1], verbose())
# content("text", "UTF-8") %T>% print

str_extract(content(p3, "text", "UTF-8"), "(?<=\\().*(?=\\))") %>% 
  fromJSON() %>% str()

# List of 2
# $ result  : logi TRUE
# $ userinfo:List of 2
# ..$ uniqueid   : chr "2527457444"
# ..$ displayname: chr "无道予不语"
p3$cookies %$% paste(name, value, sep = "=", collapse = "; ")

## version 2: RCurl model -----------------------------------------------------
# p1 <- getURL(url = paste0(urls$pre, systime()))

##create a new curl handle
# h  <- basicHeaderGatherer() # used to update httpheader
# ch <- getCurlHandle(verbose = TRUE, headerfunction = h$update)

# p2 <- postForm(uri = paste0(urls$login, systime()), 
#                .params = loginData, 
#                .encoding = "utf-8", 
#                style = "post", curl = ch) %>% fromJSON

# p3 <- getURL(p2$crossDomainUrlList[1], 
#              headerfunction = h$update, .encoding="utf-8") %T>% print 
# cookie <- getCookies_hf(h$value()) #get login cookies

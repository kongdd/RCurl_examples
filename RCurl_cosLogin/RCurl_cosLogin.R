rm(list = ls())
source('R/MainFunction.R', encoding = 'UTF-8')
# library(xml2)

## please input your password here
user <- "kongdd"
pwd <- "****"

myHttpheader<- c(
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0",
  "Accept" = "text/html,application/xhtml+xml,application/xml,application/json;q=0.9,*/*;q=0.8",
  "Accept-Language" = "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
  "Connection"="keep-alive",
  "Host" = "cos.name")
ch <- getCurlHandle()#带上百宝箱开始上路
curlSetOpt(curl = ch, ssl.verifypeer = FALSE, 
           followlocation = TRUE,
           verbose = TRUE,
           cookiejar = "cookies_cnki.txt", #cookiefile = "cookies_cnki.txt", 
           httpheader = myHttpheader)

url_login <- 'http://cos.name/cn/wp-login.php'
# (1) first call to initializate session. you get the session cookie
page <- getURL(url_login, curl = ch)

post1 <- "log=user&pwd=pwd&pTE-gB-H-f-O-c-V=WPZKteIRNC9n9nwYjh758ig-mtHo4KXjrryHb0Ag1SDIlN8TZsEWs7U6qLAUWxhUCPXuED8XoSLBtNqkQSln9ONpRCdW0YfjXEfbGUf-9Echd4sR6YIwQHLfWdLAFVra&wp-submit=%E7%99%BB%E5%BD%95&redirect_to=http%3A%2F%2Fcos.name%2Fcn%2F&testcookie=1&y-v-F-FV-A-MP-U-Rh=10809510.020100101"
# post1 <- "log=kongdd&pwd=***&pTE-gB-H-f-O-c-V=XMwOESqRvcPzdR_6IvB-cnaPQYD9qMz26n1IcW_eck-2U6b2pOwFsFDbORlLIYLAJmVmO2sw1Vr8-4kWFhL71agXu2Q4UUoyYOtJ9lVXxQpr1nqltUymJxSn-Ehm8na8wjzedaTHfjU&user-submit=&user-cookie=1&redirect_to=http%3A%2F%2Fcos.name%2Fcn%2F&_wpnonce=e2209eb5ab&_wp_http_referer=%2Fcn%2F%3Floggedout%3Dtrue&QxN-A-BX-d-Ee-M-GD=19201080249510.0true50.0"
params1 <- getParams(post1)

params1$log <- user
params1$pwd <- pwd
# post2 <- "http://cos.name/cn/wp-admin/admin-ajax.php?action=gdbcRetrieveToken&browserInfo=%7B%22screenWidth%22%3A1920%2C%22screenHeight%22%3A1080%2C%22engine%22%3A24%2C%22features%22%3A95%2C%22mozilla%22%3A%225.0%22%2C%22windows_nt%22%3A%2210.0%22%2C%22wow64%22%3Atrue%2C%22rv%22%3A%2250.0%22%2C%22gecko%22%3A%2220100101%22%2C%22firefox%22%3A%2250.0%22%7D&pTE-gB-H-f-O-c-V=3759969693&requestTime=1480418883349"
# params2 <- getParams(post2)
# params2$requestTime <- as.character(floor(as.numeric(Sys.time())*1000))
# 
# postForm("http://cos.name/cn/wp-admin/admin-ajax.php", .params = params2, curl = ch, 
#          .opt = list(verbose = TRUE), 
#          Referer = "http://cos.name/cn/wp-login.php", style = "post")

page <- postForm("http://cos.name/cn/wp-login.php", .params = params1, curl = ch, 
         .opt = list(verbose = TRUE), 
         Referer = "http://cos.name/cn/wp-login.php", style = "post")

## login success if your username could be find in info
info <- htmlParse(page, encoding = "utf-8") %>% {getNodeSet(., "//div[@class='bbp-logged-in']")[[1]]} %T>% print
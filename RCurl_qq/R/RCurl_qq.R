# rm(list = ls())
library(V8)
library(xml2)
library(rjson)
library(stringr)
source('R/MainFunction.R', encoding = 'UTF-8')
# source('RCurl_qq_main.R', encoding = 'UTF-8')

#  qq login password encode
#' @param pwd, salt, verifycode, undefined
tx_pwd_encode_by_js <- function(pwd, salt, verifycode){
  #调用V8引擎，直接执行TX的登陆JS中的加密方法，不用自己实现其中算法。
  ct <- v8()
  ct$source("RCurl_qq/src/qq.login.encrypt.js")
  encrypt_pwd = ct$eval(sprintf("window.$pt.Encryption.getEncryption('%s', '%s', '%s', undefined)", 
                                pwd, salt, verifycode))
  return(encrypt_pwd)
}
## -----------------------------------------

## RCurl设置, 直接把cookie粘贴过来，即可登录
myHttpheader<- c(
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71",
  # "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  "Accept-Language" = "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
  # "Accept-Encoding"="gzip, deflate",
  "Connection"="keep-alive",
  DNT = 1, 
  "Upgrade-Insecure-Requests" = 1, 
  "Host" = "ui.ptlogin2.qq.com")

file_cookie <- "RCurl_qq/cookies_qq.txt"
h <- basicHeaderGatherer()
ch <- getCurlHandle(headerfunction = h$update,
                    # cainfo="pem/cacert.pem",
                    # ssl.verifyhost=FALSE, ssl.verifypeer = FALSE,
                    followlocation = TRUE,
                    verbose = TRUE, 
                    cookiejar = file_cookie, cookiefile = file_cookie,
                    httpheader = myHttpheader)#带上百宝箱开始上路
curlSetOpt(curl = ch)

## global variables ---------------------
appid = 636014201
action = '2-0-1456213685600'
urlRaw = "http://ui.ptlogin2.qq.com/cgi-bin/login"
urlCheck = 'http://check.ptlogin2.qq.com/check'
urlLogin = 'http://ptlogin2.qq.com/login'
urlSuccess = 'http://www.qq.com/qq2012/loginSuccess.htm'

userInfo <- read.table("RCurl_qq/userInfo_qq.txt", header=T)
uin <- as.character(userInfo$uin)
pwd <- as.character(userInfo$pwd)
pt_verifysession_v1 = ""

#  main functions ---------------------------------------------------------
## step 1, load web login iframe and get a login signature
params = list('no_verifyimg' = 1,
              "appid" = appid,
              "s_url" = urlSuccess)
p1 <- params2URL(urlRaw, params) %>% getURL(.encoding="utf-8",headerfunction = h$update, curl = ch)
# getForm has debug cooperated with headerfunction
# p1 <- getForm(urlRaw, .params = params, curl = ch, .opts=list(headerfunction=h$update)); h$value()
# p1 <- getForm(urlRaw, headerfunction = h$update, .params = params, curl = ch)

cookies <- try(getCookies() %>% cookies2list())
login_sig <- cookies$pt_login_sig

## step 2: get verifycode and pt_verifysession_v1.
#  TX will check username and the login's environment is safe
params = list(
  "uin"       = uin,
  "appid"     = appid,
  "pt_tea"    = 1,
  "pt_vcode"  = 1,
  "js_ver"    = 10151,
  "js_type"   = 1,
  "login_sig" = login_sig,
  "u1"        = urlSuccess
)
p2 <- params2URL(urlCheck, params) %>% 
  getURL(.encoding="utf-8",headerfunction = h$update, curl = ch) %>% gsub("'", "", .) %T>% print
# p2 <- getForm(urlCheck, .params = params, headerfunction = h$update, curl = ch) %T>% print

check <- str_extract(p2, "(?<=\\().*(?=\\))") %>% {strsplit(., ",")[[1]]}
# c("check_code", "verifycode", "salt", "pt_verfisession_v1", "v2")
# if (check[1]) #need veritifycode
if (check[1] != "0") warning("Need veritfycode!")

verifycode <- check[2]
salt <- check[3]
pt_verifysession_v1 <- check[4]

encrypt_pwd <- tx_pwd_encode_by_js(pwd, salt, verifycode)
# ptui_checkVC('1','0tQgjvfZI47EPP2Ru7Z5QceOXO7oTyNXK43ZV67Yr1CxUnJidzExfw**','\x00\x00\x00\x00\x3b\x1d
# \xd4\x10','','2');

## step 3: login and get cookie.
#  TX will check encrypt(password)
params_login = list(
  'u'                   = uin,
  'verifycode'          = verifycode,
  'pt_vcode_v1'         = 0,
  'pt_verifysession_v1' = pt_verifysession_v1,
  'p'                   = encrypt_pwd,
  'pt_randsalt'         = 0,
  'u1'                  = urlSuccess,
  'ptredirect'          = 0,
  'h'                   = 1,
  't'                   = 1,
  'g'                   = 1,
  'from_ui'             = 1,
  'ptlang'              = 2052,
  'action'              = action,
  'js_ver'              = 10143,
  'js_type'             = 1,
  'aid'                 = appid,
  'daid'                = 5,
  # pt_uistyle          = "40",
  'login_sig'           = login_sig
)
# params2URL(urlLogin, params_login) %>% getURL(., curl = ch)
# ch2 <- getCurlHandle()#带上百宝箱开始上路
# file_cookie2 <- "RCurl_qq/cookies_qq2.txt"
# tmp <- curlSetOpt(curl = ch2,
#                   # cainfo="pem/cacert.pem",
#                   # ssl.verifyhost=FALSE, ssl.verifypeer = FALSE,
#                   followlocation = TRUE, verbose = TRUE, 
#                   cookiejar = file_cookie, cookiefile = file_cookie,
#                   httpheader = myHttpheader)

h2 <- basicHeaderGatherer()
p3 <- params2URL(urlLogin, params_login) %>% getURL(., headerfunction = h2$update) %T>% print
cookies <- getCookies(h2$value())

## the below is under test

file_cookie2 <- "RCurl_qq/cookies_qq2.txt"
ch2 <- getCurlHandle(Cookie =cookies, 
                     headerfunction = h2$update,
                     followlocation = TRUE,
                     verbose = TRUE, 
                     cookiejar = file_cookie2, cookiefile = file_cookie2,
                     httpheader = myHttpheader)#带上百宝箱开始上路

# "pt2gguin=o0846262311;uin=o0846262311;skey=@AXdlV7ECj;ETK=;superuin=o0846262311;superkey=xK*Q1cqHrzjCw2dBOh2JZ0yPu2PXffYp5eo0l96np7I_;supertoken=3375648494;pt_recent_uins=ea533e8bf5cc38dbc84cb270f5d1358b06a4826da5d03d441ebe9b3ebcf263f6730200439c8c8b21c66521a1c6563ec7e1d0e4d90822b491;Set-Cookie:pt_guid_sig=66208ee1518d5e031b3753df377b4326884260c1d8be2da4bd8a7d783464bcfb;ptisp=ctc;RK=kI0apwzmND;ptnick_846262311=e69c88e697a2e4b88de8a7a3e9a5ae;u_846262311=@AXdlV7ECj:1482292061:1482292061:e69c88e697a2e4b88de8a7a3e9a5ae:1;ptcz=a9bf7a6eaab64872be074a52fc21d95063dbcaec86200664d7f34b6ea7cfe5ab;ptcz=;airkey="

"ptuiCB('0','0','http://ptlogin4.qzone.qq.com/check_sig?pttype=1&uin=991810576&service=login&nodirect=0&ptsigx=99517dde4ba639cf9becd15d4f53d6e201ee017b9655c5a6200ab3c3bed8cd4f837d87a9c947ad2d631381760895cc4a9c3927e73dcf3a62c3ec0a11a4c8303c&s_url=http%3A%2F%2Fwww.qq.com%2Fqq2012%2FloginSuccess.htm&f_url=&ptlang=2052&ptredirect=100&aid=636014201&daid=5&j_later=0&low_login_hour=0&regmaster=0&pt_login_type=1&pt_aid=0&pt_aaid=0&pt_light=0&pt_3rd_aid=0','0','登录成功！', 'Kong');\r\n"

# "ptuiCB('7','0','','0','提交参数错误，请检查。(3914338958)', '');\r\n"
# ptuiCB('3','0','','0','您输入的帐号或密码不正确，请重新输入。', '');

xx2 <- getFormParams("http://ptlogin2.qq.com/login?u=991810576&verifycode=@sm6&pt_vcode_v1=1&pt_verifysession_v1=t02IsZ2Q2rsqhUVPE4bCiRpoEYhRHfrUXQMAUoqPXnopsKqc6j5NLGzvezIxwMDMOyGLLX2i36lcVhzw0_LI_ssLFbjacYqe8E_h8OEgnQdjDU*&p=M9yIID7HJkxf3Tk0tTqYeaEnWtf0nX0bkhJHW1uJH6lXysuCL4dDU2WUfV38w8t6GnvNT8RGAv1oKAkWZL5bFbFmqQaMiGY*ht*KjI-B6VCg1xFJZfZlLiKhUdrTIOtaaIJmzt8N6d573yq6aqL7ubsUIhgQ4d6dEGWPH9E*zpKAACB104FNmiDpQi3gDQQVO9uGDnUtwdqHXiNDaEmQmUvBjpE8YSroFFXjx80PAx52w*iAwSUNfRHqwxwkycpkMm2DNG9pqv51-8GhbieNPHuqBey4WjWdvvYTJ9XEV*Q139zSa3TJuPi9m5TiTLz1YZWFuxSYQaVSlFrrzmNHjQ__&pt_randsalt=2&u1=http%3A%2F%2Fwww.qq.com%2Fqq2012%2FloginSuccess.htm&ptredirect=1&h=1&t=1&g=1&from_ui=1&ptlang=2052&action=7-45-1482253698638&js_ver=10187&js_type=1&login_sig=3sYSg2hSbXlhirHEiIfTQEiRcBFKEvbq-NLlst*kwBXM589jzWraDI4j0GGJqm53&pt_uistyle=40&aid=636014201&") %>% as.list()
# ptuiCB('0','0','http://id.qq.com/index.html','1','登录成功！', 'QQ昵称');

# http://check.ptlogin2.qq.com/check?regmaster=&pt_tea=2&pt_vcode=1&uin=991810576&appid=636014201&js_ver=10187&js_type=1&login_sig=10nkzp63PI*9v5WUxVnFhMMLAEc6qbngNJVY1IAKgME-K*wYzy32Rzd8QHXO7pME&u1=http%3A%2F%2Fwww.qq.com%2Fqq2012%2FloginSuccess.htm&r=0.5572740272425778&pt_uistyle=40

## 验证码处理
params_verfy <- url2params("http://captcha.qq.com/cap_union_new_getcapbysig?aid=636014201&asig=&captype=&protocol=http&clientype=2&disturblevel=&apptype=2&curenv=inner&noBorder=noborder&showtype=embed&uid=991810576&cap_cd=8nrJN4b4_v-WpoQvIvMhQzbuQ4B27K4ovuU_JQ033v72qVqqiCDLVw**&lang=2052&rnd=943521&rand=0.17577215541981617&vsig=gETBba06Q8Zj4cF-fKLX_noB3UNWTPHlgzif0nmvhdF_rKAs6jm8MDygWmBSnnmSr234dskUIEXKRr91PLYHGfS9vynVANDE3t1XZmfu3xRFdxBprqTD5Cw**&ischartype=1")


# http://captcha.qq.com/cap_union_new_show?aid=636014201&asig=&captype=&protocol=http&clientype=2&disturblevel
# =&apptype=2&curenv=inner&noBorder=noborder&showtype=embed&uid=991810576&cap_cd=8nrJN4b4_v-WpoQvIvMhQzbuQ4B27K4ovuU_JQ033v72qVqqiCDLVw
# **&lang=2052&rnd=943521

rm(list = ls())
source('R/MainFunction.R', encoding = 'UTF-8')

doc <- read_html("RCurl_elearn/第一次/message.htm")
trs <- xml_find_all(doc, '//ul[@id="contributorList"]/li[position()>1]/a')

# get_info <- function(x){
#   userinfo <- xml_find_first(x, "td/input") %>% {as.list(xml_attrs(.)[-c(1, 5)])}
#   tieinfo <- xml_find_all(x, "td[position()>2]") %>% {gsub("\\W", "", xml_text(.[c(2, 1, 4, 5)]))} %>% 
#     as.list() %>% set_names(c("user","time", "unread", "totaln"))
#   href <- xml_find_first(x, "th/span/a//@href") %>% xml_text()
#   data.frame(c(tieinfo, userinfo, href=href))
# }
get_info <- function(tr){
  user <- xml_text(tr)
  href <- xml_attr(tr, "href")
  data.frame(user, href, stringsAsFactors = F)
}
info <- ldply(trs, get_info, .progress = "text")

outdir <- "E:/GitHub/RCurl_project/RCurl_elearn/第一次学习活动/"
errorId <- list(); i = 1
for (i in seq_along(info$href)){
  cat(sprintf("[%004d]th-------------\n", i))
  tryCatch({
    url <- info$href[i]
    page <- getURL(url, curl = ch) 
    x <- page %>% read_html %>% xml_find_all('//div[@id="collectionContainer"]')
    fname <- sprintf("%s%04d_%s.txt", outdir, i, gsub(" ", "_", info$user[i]))
    write_lines(x, fname)
  }, 
  error=function(e) {
    errorId[[i]] <- i
    message(sprintf("[%04d] ERROR: %s", i, e))
  })
}


page <- getURL(url, curl = ch) %>% html_body()
'div[@id="collectionContainer"]/div[@class="dbThread"]'

head <- '<html lang="zh-CN"><head><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head>'
tail <- '</html>'
paste0("")


save_html(p, "a.html")

# htmlParse(page) %>% {getNodeSet(.,"//body")}
#   
# 
# url_login <- 'http://elearning.ne.sysu.edu.cn/webapps/login/?action=login&auth_type=&encoded_pw=636E016E1D37BBEC68DA82AD224D7E19&encoded_pw_unicode=F93C40E024BD16CA7AB5D78C246EC481&login=%E7%99%BB%E5%BD%95&new_loc=%C2%A0&one_time_token=30F7E3BCBFCF597035D19E0A16381BB2&password=&remote-user=&user_id=fdjs146'
# login_parasm <- getParams(url_login)
# 
# 
# page <- postForm("http://elearning.ne.sysu.edu.cn/webapps/login/", .params = login_parasm, curl = ch, 
#                  refere="http://elearning.ne.sysu.edu.cn/")
# # (1) first call to initializate session. you get the session cookie
# page <- getURL(url_login, curl = ch)
# p <- postForm("https://cas.sysu.edu.cn/cas/login?service=http%3A%2F%2Fmy.sysu.edu.cn%2Fc%2Fportal%2Flogin%3Fp_l_id%3D12207", 
#             .params = params, curl=ch,
#             .opts = list(ssl.verifypeer = FALSE))
# htmlParse(p, encoding = "utf-8") %>% getNodeSet("//body")
# 
# url_bss <- "http://elearning.ne.sysu.edu.cn/webapps/portal/frameset.jsp?tab_tab_group_id=_2_1&url=%2Fwebapps%2Fblackboard%2Fexecute%2Flauncher%3Ftype%3DCourse%26id%3D_405_1%26url%3D"
# 
# page2 <- getURL(url_bss, curl = ch)
# 
# 
# url_login <- "https://cas.sysu.edu.cn/cas/login;jsessionid=45DA4B5C40BAC8EECC320A20E67957B7?service=http%3A%2F%2Fmy.sysu.edu.cn%2Fc%2Fportal%2Flogin%3Fp_l_id%3D12207"
# page <- getURL(url_login, curl = ch)
# p <- postForm(url_login, .opts = curlOptions(password="xiuyuan156", username="kongdd"), 
#          .params = list(lt="LT-132480-GxU7fGCRTHOoBe0f74pwwdqt9HSPo3-cas.sysu.edu.cn", 
#                          submit="登录"), curl = ch)
# 
# ## --------------------- 采用cookie进行登录
# getURL("http://elearning.ne.sysu.edu.cn/webapps/discussionboard/do/forum?action=list_threads&course_id=_405_1&forum_id=53996&nav=discussion_board&conf_id=_413_1&mode=cpview", curl = ch) %>% 
#   htmlParse %>% {getNodeSet(.,"//body")}
# ----------------- After get the login cookie ------------------


d2 <- debugGatherer()
cHandle2 <- getCurlHandle(
  httpheader = c(
    "Connection" = "keep-alive",
    "Host"       = "weibo.com",
    "User-Agent" = header, #global variable in MainFunction.R
    "Accept"     = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Cookie"     = cookie
  ),
  followlocation = 1,
  debugfunction  = d2$update,
  verbose        = TRUE
)
#"Accept-Language"="zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3",
#"Accept-Encoding"="gzip,deflate",

page <- getURL("http://weibo.com/u/2527457444/home?wvr=5", curl = cHandle2)
doc <- htmlParse(page, encoding = "utf-8")#div class="WB_feed_detail clearfix"
contents <- getNodeSet(doc, "//script")[[15]]
docContent <- htmlParse(fromJSON(gsub("FM.view\\(\\{(.*)\\}\\)","\\{\\1\\}", xmlValue(contents)))$html,
                        encoding = "utf-8")

ans <- getNodeSet(docContent, "//div[@class = 'WB_cardwrap WB_feed_type S_bg2']")[[2]]

##get detail infomation of single weibo message
a <- getNodeSet(ans, "div/div[@class='WB_detail']")[[1]]
wb_info <- getNodeSet(a, "div[@class='WB_info']/a[@class='W_f14 W_fb S_txt1']")[[1]]
NickName <- iconv(xmlGetAttr(wb_info, "nick-name"), "utf-8", "gbk")
title <- iconv(xmlGetAttr(wb_info, "title"), "utf-8", "gbk")
content <- xmlValue(getNodeSet(a, "div[@class = 'WB_text W_f14']")[[1]])

wb_expand <- getNodeSet(a, "div[@class='WB_feed_expand']/div[@class='WB_expand S_bg1']")[[1]]
wb_expandInfo <- getNodeSet(wb_expand, "div[@class='WB_info']/a[@class='W_fb S_txt1']")[[1]]
exNickName <- iconv(xmlGetAttr(wb_expandInfo, "nick-name"), "utf-8", "gbk")
extitle <- iconv(xmlGetAttr(wb_expandInfo, "title"), "utf-8", "gbk")
exContent <- xmlValue(getNodeSet(wb_expand, "div[@class='WB_text']")[[1]])

getNodeSet(wb_expand, "div[@class='WB_func clearfix']")
commentInfo <- getNodeSet(wb_expand, "div[@class='WB_func clearfix']/div[@class='WB_handle W_fr']/ul/li/span/a")
transferN <- xmlValue(commentInfo[[1]])
commentN <- xmlValue(commentInfo[[2]])
# goodsN <- paste("赞", xmlValue(commentInfo[[3]]), sep = "")

placeInfo <- getNodeSet(wb_expand, "div[@class='WB_func clearfix']/div[@class='WB_from S_txt2']/a")
time <- xmlGetAttr(placeInfo[[1]], "title")
place <- xmlValue(placeInfo[[2]])


exinfo <- data.frame(time, place, transferN, commentN, goodsN)
## 此处能用到S4类最好了，pipe通道
## initial CNKI ip login---------------------------------
## 中国知网initial login
login <- function(){
  myHttpheader<- c(
    "User-Agent" = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0",
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language" = "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
    "Connection"="keep-alive",
    "Host" = "tongji.cnki.net")
  ch <- getCurlHandle()#带上百宝箱开始上路
  curlSetOpt(curl = ch, ssl.verifypeer = FALSE, 
             # followlocation = TRUE, 
             cookiejar = "cookies_cnki.txt", #cookiefile = "cookies_cnki.txt", 
             httpheader = myHttpheader)
  url_root <- "http://tongji.cnki.net/kns55/Dig/dig.aspx"
  page_root <- getURL(url_root, curl = ch)#ch应该会记录cookie信息
  if (length(grep("中山大学", page_root)>0)) 
    cat("ip验证成功，可以使用CNKI！\n") else stop("身份验证失败\n")
  #如果身份验证失败，则终止程序运行！
  ch#quickly return
}

extractData <- function(page){
  trs <- htmlParse(page, encoding = "utf-8") %>% getNodeSet(., "//table/tr")
  if (length(trs) == 0){
    # warning("cnki数据库存在异常，请检查!")
    return(FALSE)
  }
  df <- lapply(trs, function(tr) xpathSApply(tr, "td", xmlValue))
  
  # rowspan <- getNodeSet(trs[[1]], "td[@rowspan]")#据此判断是何种类型数据
  ## trs需要仔细处理
  # years <- df[[1]][-1] %>% gsub("年", "", .) %>% as.numeric()
  years <- rep(xpathSApply(trs[[1]], path = "td", xmlValue) %>% gsub("年|\\s", "", .), #同时移除编码错误的空格 
               xpathSApply(trs[[1]], path = "td", xmlGetAttr, name = "colspan") %>% as.numeric())
  df[[1]] <- years
  data <- do.call(cbind, df) %>% t %>% data.frame(.,stringsAsFactors = F)
  data
  # colnames(data) <- data[1, ]; data <- data[-1, ]
  # data
  #write.table(data, file = "text.txt", col.names = F, row.names = F, sep = "\t", quote = F)
  # countyInfo <- data[, 1:3]
  # list(years = years, countyInfo = countyInfo, data = data)#quickly return
}

getNongye_data <- function(items, countyId, fname, sleep = 5){
  searchTarget <- paste0(paste(items, collapse = ";"), ";")
  searchTarget <- iconv(searchTarget, "gbk", "utf-8") %>% charToRaw() %>% toupper() %>% paste("%", ., collapse = "", sep = "")
  prov <- paste0(paste(countyId, collapse = ";"), ";")
  
  ## year style table url
  url <-  paste0("http://tongji.cnki.net/kns55/Dig/SubDig/Ajax/DigResultUIBLL.ashx?",
                 sprintf("areaSelType=xjSel&dataSource=all&initial=initial&postDefTar=&postTar=%s&postYear=full&postZones=%s&tablestyle=area",
                         searchTarget, prov %>% URLencode(reserved = T)))
  ## area style table url
  url_area <- paste0("http://tongji.cnki.net/kns55/Dig/SubDig/Ajax/DigResultUIBLL.ashx?",
                     sprintf("postZones=%s&postTar=%s&postYear=full&tablestyle=area&areaSelType=xjSel&postDefTar=&dataSource=all",
                             prov %>% URLencode(reserved = T), searchTarget))
  refer <- paste0("http://tongji.cnki.net/kns55/Dig/DigResult.aspx?",
                  sprintf("postZones=%s&postTar=%s&postYear=full&areaSelType=xjSel&postDefTar=",
                          prov %>% URLencode(reserved = T), searchTarget))
  
  params <- list(areaSelType = "xjSel", dataSource = "all", initial = "initial", postDefTar = "", 
                 postTar = paste0(paste(x[[j]]$items, collapse = ";"), ";"), 
                 postYear = "full", 
                 postZones = prov, 
                 tablestyle = "area")
  ## refer的请求对参数的传递至关重要！
  tmp <- getURL(refer, curl = ch, Referer = "http://tongji.cnki.net/kns55/Dig/dig.aspx")
  # page <- getURL(url, curl = ch)
  # page <- postForm("http://tongji.cnki.net/kns55/Dig/SubDig/Ajax/DigResultUIBLL.ashx", .params = params, curl = ch,
  #                  .opts = curlOptions(Referer = refer, verbose = F))#postForm传递参数出现数据混乱
  page <- getURL(url_area, curl = ch, Referer = refer)
  
  if (nchar(page) < 1000){
    warnings("返回结果异常")
    cat(sprintf("%s\n", page))
    #break#结果异常时立马终止程序
    # stop("返回结果异常，为防止ip被封请请马上处理！")
  }else{
    dfOut <- extractData(page)
    write.table(dfOut, file = fname, col.names = F, row.names = F, sep = ",", quote = F)
    if (length(dfOut) > 1) return(TRUE)
  }
  return(FALSE)
}

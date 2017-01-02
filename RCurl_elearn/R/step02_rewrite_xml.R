rm(list = ls())
source('R/MainFunction.R', encoding = 'UTF-8')

page <- read_html("RCurl_elearn/第一次学习活动-已批改_files/launcher.html")
trs <- xml_find_all(page, '//ul[@id="contributorList"]/li[position()>1]')
# tr <- trs[[1]]
getGradeInfo <- function(tr){
  user <- gsub(" ", "_", tr %>% xml_find_all("a") %>% xml_text())
  haveGrade <- tr %>% {length(xml_find_all(., "span/img")) == 0}
  href <- xml_find_first(tr, "a") %>% xml_attr("href")
  data.frame(user, haveGrade, href, stringsAsFactors = F)
}

gradeInfo <- ldply(trs, getGradeInfo) %>% subset(!haveGrade)

## 读取分数
grade <- read.xlsx("gradeInfo.xlsx")
x <- cbind(gradeInfo, grade[, c(1, 2, 4)])

fnames <- dir("RCurl_elearn/第一次学习活动/", pattern = "*.txt", full.names = T)
Id <- llply(paste0(gradeInfo$user, ".txt"), grep, basename(fnames), .progress = "text")

# txts <- foreach(id = Id, i=icount()) %do% {
#   if (length(id) != 1) {
#     cat(i, sep= "\n")
#   }else{
#     node <- read_html(fnames[id]) %>% xml_find_all("//div[@class='vtbegenerated']")
#     x <-  xml_find_all(node, "p") %>% xml_text()
#     if (length(x) == 0) x <- xml_text(node)
#     ps <- laply(x, function(x) sprintf("<p>%s</p>", x))
#     add <- sprintf("<hr><p>[%d] %s</p>", i, gradeInfo$user[i])
#     txt <- paste(c(add, ps), collapse = "")
#     gsub("Â|ã", "", txt)
#   }
# }

# divs <- paste(c('<head><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body>',
#               txts[sapply(txts, length) != 0], "</body>"), 
#               collapse="")
# save_html(divs, "第一次学习活动.html")
# 
# 
# 
# gradeInfo$grade <- NA
# gradeInfo$grade[Id_chaoxi] <- 75
# openxlsx::write.xlsx(gradeInfo, file = "gradeInfo_chaoxi.xlsx")

## 去除抄袭之后的
txts <- foreach(id = Id, i=icount()) %do% {
  if (length(id) != 1) {
    cat(i, sep= "\n")
  }else{
    node <- read_html(fnames[id]) %>% xml_find_all("//div[@class='vtbegenerated']")
    x <-  xml_find_all(node, "p") %>% xml_text()
    if (length(x) == 0) x <- xml_text(node)
    ps <- laply(x, function(x) sprintf("<p>%s</p>", x))
    add <- sprintf("<hr><p>[%d] %s</p>", i, gradeInfo$user[i])
    txt <- paste(c(add, ps), collapse = "")
    gsub("Â|ã", "", txt)
  }
}

Id_chaoxi <- grep("In the past, illiterate referred to those who could not read nor write|The development of modern science and technology has changed our way of life", txts)

txts <- txts[-Id_chaoxi]; txts <- txts[sapply(txts, length) != 0]
divs <- paste(c('<head><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body>',
                txts, "</body>"), 
              collapse="")
save_html(divs, "第一次学习活动_trim抄袭.html")

# for(i in seq_along(Id)){
  id <- Id[[i]]
#   if (length(id) != 1) {
#     cat(i, sep= "\n")
#   }else{
#     x <- read_lines(fnames[id]) 
#     add <- sprintf("<hr><p>[%d] %s</p>", i, gradeInfo$user[i])
#     txt <- paste(c(add, x), collapse = "")
#   }
# }
info <- read.xlsx("gradeInfo.xlsx")
which(info$grade > 100)
summary(info$grade)
Id_chaoxi <- which(!is.na(info$grade))

page <- read_html("第一次学习活动.html")
openxlsx::write.xlsx(gradeInfo, file = "gradeInfo.xlsx")

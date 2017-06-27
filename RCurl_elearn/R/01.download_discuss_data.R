
# source('R/MainFunction.R', encoding = 'UTF-8')

## 01 控制面板→需要评分, 选择需要批改的课程
course_id <- "_406_1"
url <- paste0("http://elearning.ne.sysu.edu.cn/webapps/gradebook/do/instructor/viewNeedsGrading?course_id=", course_id)
p1 <- GET(url) %>% content()
Items <- xml_find_all(p1, '//select[@name="itemFilter"]/option[position()>1]') %T>% print

## 02. 选择对应的作业题目，并进行登录
i <- 3
itemFilter <- Items[[i]] %>% xml_attr("value")

## select Items:
# course_id: _405_1, 大英2
#          : _406_1, 大英3

param2 <- list(
  course_id             = course_id,
  categoryFilter        = "allCategories",
  dateFilterSelect      = "allDates",
  dateSubmitted_datetime= "",
  itemFilter            = itemFilter,
  pickdate              = "",
  pickname              = "",
  studentFilter         = "allStudents"
)
p2 <- POST("http://elearning.ne.sysu.edu.cn/webapps/gradebook/do/instructor/viewNeedsGrading", 
          body = param2, encode = "form") %>% content()

attemptId <- xml_find_all(p2, '//tbody[@id="listContainer_databody"]/tr/th/a') %>% xml_attr("attemptid")

## 03. 登陆查询需要改作业的全部人员
url_root <- "http://elearning.ne.sysu.edu.cn/webapps/gradebook/do/instructor/performGrading"
param3 <- list(
  course_id            	=  course_id,
  source               	= "cp_gradebook_needs_grading",
  cancelGradeUrl       	= "/webapps/gradebook/do/instructor/viewNeedsGrading?course_id=_405_1",
  mode                 	= "invokeFromNeedsGrading",
  viewInfo             	= "需要评分",
  attemptId            	= "_5918115_1",
  groupAttemptId       	= ""
)
param3$attemptId <- attemptId[1]

p3 <- GET(url_root, query = param3, verbose()) %>% content()

## 04. 获取(需要批改)作业的学生href
# save_html(p3)

li_current <- xml_find_first(p3, '//ul[@id="contributorList"]/li[@class=" currentBlog "]')
xml_remove(li_current)

# lis <- xml_find_all(p3, '//ul[@id="contributorList"]/li')
nodes <- xml_find_all(p3, '//ul[@id="contributorList"]/li/a') #[position()>1]
spans <- xml_find_all(p3, '//ul[@id="contributorList"]/li/span[@class="gradingStatus"]') #[position()>1]

NeedGrade <- sapply(spans, xml_children) %>% sapply(length)

Info <- list(id = seq_along(nodes),
             user = xml_text(nodes), 
             href = paste0("http://elearning.ne.sysu.edu.cn/webapps/discussionboard/do/", xml_attr(nodes, "href")), 
             NeedGrade = NeedGrade)
# %>% {do.call(cbind.data.frame, c(., stringsAsFactors = F))}
info.all <- transpose(Info)[Info$NeedGrade == 1]
info <- info.all[1:64]
# info <- subset(Info, NeedGrade == 1) %>% set_rownames(NULL)

## 05. write discuss into html 
outdir = "RCurl_elearn/data/txt/"
txts <- llply(info, download_essay, outdir = outdir, .progress = "text")

# xx <- mapply(simply_xml, txts, info)
xx <- mapply(simply_txt, 
             dir(outdir, full.names = T, pattern = "*.txt"), 
             info)
text <- paste(c('<head><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body>',
                xx, "</body>"), collapse="")
save_html(text, "1.html")
rm(xx, txts, text)

df <- transpose(info) %>% llply(unlist) %>% 
{do.call(cbind.data.frame, c(., stringsAsFactors = F))}
df$score <- ""

write.xlsx(df, file = "1.xlsx")

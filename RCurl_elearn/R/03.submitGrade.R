
## global variables for post score data
# inputs <- 

## 提交讨论题的分数

x <- read.xlsx("1.xlsx")
# 
# Id <- match(gsub(" ", " ", info$user), x$user) %>% {.[!is.na(.)]}
# x <- x[Id, ]
# already login -------------------------------------------------------------------
errorId <- list();i = 1
for (i in 1:nrow(x)){
  cat(sprintf("[%d]: %s\n", x$id[i], x$user[i]))
  url <- x$href[i]; fenshu <- x$score[i]
  if (is.na(fenshu)) next
  
  tryCatch({
    p <- GET(url) %>% content(encoding = "UTF-8")
    ## 构造提交参数
    inputs <- html_inputs(p, '//form[@id="blogGradingForm"]/div/input')
    
    inputs$grade_version <- str_extract(p, "(?<=gradeVersion=)\\d{6,}")
    inputs <- c(
      inputs,
      collabGradeField      = "",
      old_collabGradeField  = "",
      gradeCommentField     = "",
      old_gradeCommentField = "",
      gradeNotes            = "",
      old_gradeNotes        = ""
    )
    
    ## 判断是否已经提交过分数, if true have grade
    grade <- xml_find_first(p, '//span[@id="blogGradeValue"]') %>% xml_text %T>% print
    haveGrade <- length(grep("--", grade)) == 0
    if (haveGrade) {
      message("Already have grade!")
    }else{
      cat(sprintf("have no grade."))
      
      inputs$collabGradeField <- fenshu
      # p <- postForm("http://elearning.ne.sysu.edu.cn/webapps/blackboard/execute/gradeCollab",
                    # .params=inputs, curl=ch, referer = url, style="post") %T>% print
      p <- POST("http://elearning.ne.sysu.edu.cn/webapps/blackboard/execute/gradeCollab", 
      	body = inputs, encode = "form", referer = url) %>% 
        content("text", encoding = "UTF-8") %>% fromJSON() %>% str() %>% print()
    }
  },
  error=function(e) {
    errorId[[i]] <- i
    message(sprintf("[%04d] ERROR: %s", i, e))
  })
}

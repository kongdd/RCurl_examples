# already login -------------------------------------------------------------------
errorId <- list();i = 1
for (i in 331:nrow(x)){
  cat(sprintf("[%d]---------\n", i))
  x[i, ]#user info
  url <- x$href[i]; fenshu <- x$grade[i]
  if (is.na(fenshu)) next
  
  tryCatch({
    page <- getURL(url, curl = ch) 
    doc <- page %>% read_html 
    
    ## 构造提交参数
    inputs <- xml_find_all(doc, '//form[@id="blogGradingForm"]/div/input') %>% 
    {setNames(as.list(xml_attr(., "value")), xml_attr(., "name"))}
    # inputs <- inputs[order(inputs$name), ] %$% {setNames(as.list(value), name)}
    inputs$grade_version <- str_extract(page, "(?<=gradeVersion=)\\d{6,}")
    inputs <- c(
      inputs,
      collabGradeField = "",
      old_collabGradeField = "",
      gradeCommentField    = "",
      old_gradeCommentField = "",
      gradeNotes = "",
      old_gradeNotes       = ""
    )
    
    ## 判断是否已经提交过分数, if true have grade
    grade <- xml_text(xml_find_first(doc, '//span[@id="blogGradeValue"]')) %>% print
    haveGrade <- grade %>% {length(grep("--", .)) == 0}
    if (haveGrade) {
      message("Already have grade!")
    }else{
      cat(sprintf("have no grade."))
      
      inputs$collabGradeField <- fenshu
      p <- postForm("http://elearning.ne.sysu.edu.cn/webapps/blackboard/execute/gradeCollab",
                    .params=inputs, curl=ch, referer = url, style="post") %T>% print
    }
  }, 
  error=function(e) {
    errorId[[i]] <- i
    message(sprintf("[%04d] ERROR: %s", i, e))
  })
}

# http://elearning.ne.sysu.edu.cn/webapps/portal/frameset.jsp?tab_tab_group_id=_2_1&url=%2Fwebapps%2Fblackboard%2Fexecute%2Flauncher%3Ftype%3DCourse%26id%3D_406_1%26url%3D
# http://elearning.ne.sysu.edu.cn/webapps/portal/frameset.jsp?tab_tab_group_id=_2_1&url=%2Fwebapps%2Fblackboard%2Fexecute%2Flauncher%3Ftype%3DCourse%26id%3D_406_1%26url%3D

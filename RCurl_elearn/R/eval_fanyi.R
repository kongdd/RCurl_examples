# --------------- 本程序用于批量批改blackboard学习活动中的翻译题 --------------------
#                      Writed By Dongdong KONG, 2017-01-01
# -----------------------------------------------------------------------------------
get_users <- function(li){
  id = xml_attr(li, "id")
  user <- xml_find_all(li, "div/h3") %>% xml_text() %>% gsub("\\s", "", .)
  status <- xml_find_all(li, "div/h3/img") %>% xml_attr("alt")
  answer <- xml_find_all(li, "div/table/tbody/tr/td[@id='meta_value_2']") %>% xml_text()
  tryCatch({
    answer_new <- read_xml(answer) %>% xml_text()
    answer <- answer_new
  }, error = function(e)e)
  data.frame(id, user, status, answer, stringsAsFactors = F)
}

params <- list(
      resultId = "_127318511_1",
      grade    = "2",
      feedBack = "",
      "_rubricEvaluation"                           = "",
      "blackboard.platform.security.NonceUtil.nonce" = "c1aaf6a3-d5d4-425e-804f-414d13711439",
      course_id= "_406_1",
      action   = "saveQuestionResults"
    )
url_list <- sprintf("http://elearning.ne.sysu.edu.cn/webapps/assessment/do/gradeQuestions?course_id=_406_1&filter=ALL&questionId=_1042%d_1&outcomeDefinitionId=_100427_1&source=cp_gradebook_needs_grading", 137:166)[-c(1, 2, 11)]
# url <- list(
#   "1" = "http://elearning.ne.sysu.edu.cn/webapps/assessment/do/gradeQuestions?course_id=_406_1&filter=ALL&questionId=_1042137_1&outcomeDefinitionId=_100427_1&source=cp_gradebook_needs_grading",
#   "2" = "http://elearning.ne.sysu.edu.cn/webapps/assessment/do/gradeQuestions?questionId=_1042138_1&course_id=_406_1&filter=ALL&outcomeDefinitionId=_100427_1&source=cp_gradebook_needs_grading"
# )

result <- list()
for (k in 2:length(url_list)){
  urls <- url_list[k] %>% c(., laply(2:5, function(i) paste0(., "&pageIndex=", i, "&resultsPerPage=200")))
  # users_node <- doc %>% xml_find_all('//select[@id="userSelect"]/option')
  # userInfo <- data.frame(user = xml_text(users_node), value = xml_attr(users_node, "value"), stringsAsFactors = F)
  userInfo <- list()
  for (i in 1:5){
    cat("request webpage ...\n")
    p <- getURL(urls[i], curl = ch)
    # save_html(p, "RCurl_elearn/1.html")
    doc <- read_html(p)
    lis <- xml_find_all(doc, '//li[@class="clearfix liItem "]')
    info <- ldply(lis, get_users)
    userInfo[[i]] <- info
    nonce <- xml_find_all(doc, "//input[@id='gradeQuestionNonce']") %>% xml_attr("value")
    # nonces <- xml_find_all(doc, "//input[@name='blackboard.platform.security.NonceUtil.nonce']")

    j=1
    params$blackboard.platform.security.NonceUtil.nonce <- nonce
    params$resultId <- info$id[i]
    # params$blackboard.platform.security.NonceUtil.nonce <- xml_attr(nonces[1], "value")
    res <- postForm("http://elearning.ne.sysu.edu.cn/webapps/assessment/do/gradeQuestions", 
                    .params=params, curl = ch, style="post") %T>% print
    tryCatch({
      for (j in 1:nrow(info)){
        cat(sprintf("[%d-%d-%d] %s\n", k, i, j, info$user[j]))
        if (info$status[j] == "需要评分"){
          params$resultId <- info$id[j]
          params$blackboard.platform.security.NonceUtil.nonce <- fromJSON(res)$new_nonce  
          res <- postForm("http://elearning.ne.sysu.edu.cn/webapps/assessment/do/gradeQuestions", 
                          .params=params, curl = ch, style="post", verbose = F) %T>% print
        }
      }
    }, 
    error=function(e) {
      errorId[[i]] <- i
      message(sprintf("[%04d] ERROR: %s", i, e))
    })
  }
  result[[k]] <- setNames(userInfo, 1:5) %>% {.[sapply(., length) > 0]} %>% melt
}

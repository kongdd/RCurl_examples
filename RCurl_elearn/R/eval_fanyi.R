# --------------- 本程序用于批量批改blackboard学习活动中的翻译题 --------------------
#                      Writed By Dongdong KONG, update 2017-06-27
# -----------------------------------------------------------------------------------

get_users <- function(li){
  id <- xml_attr(li, "id")
  user <- xml_find_all(li, "div/h3") %>% xml_text() %>% gsub("\\s", "", .)
  status <- xml_find_all(li, "div/h3/img") %>% xml_attr("alt")
  answer <- xml_find_all(li, "div/table/tbody/tr/td[@id='meta_value_2']") %>% xml_text()
  tryCatch({
    answer_new <- read_xml(answer) %>% xml_text()
    answer <- answer_new
  }, error = function(e)e)
  data.frame(id, user, status, answer, stringsAsFactors = F)
}

## 选择按问题进行评分

p <- read_html("C:/Users/kongdd/Desktop/Blackboard Learn_files/viewQuestions.htm")
trs <- xml_find_all(p, '//tbody[@id="listContainer_databody"]/tr/td[4]/a')[1:10]

questions <- xml_attr(trs, "href") %>% str_extract("_\\d{6,}_1")

url_list <- sprintf("http://elearning.ne.sysu.edu.cn/webapps/assessment/do/gradeQuestions?questionId=%s&course_id=_406_1&filter=ALL&outcomeDefinitionId=_119627_1&anonymousMode=false&source=cp_gradebook_needs_grading", 
                questions)

params <- list(
      resultId = "_127318511_1",
      grade    = "2",
      feedBack = "",
      "_rubricEvaluation"                            = "",
      "blackboard.platform.security.NonceUtil.nonce" = "c1aaf6a3-d5d4-425e-804f-414d13711439",
      course_id= "_406_1",
      action   = "saveQuestionResults"
    )

errorId <- numeric()
k = 1; i = 1
result <- list()
for (k in 1:length(url_list)){
  urls <- url_list[k] %>% c(., laply(2:7, function(i) paste0(., "&pageIndex=", i, "&resultsPerPage=200")))
  # users_node <- doc %>% xml_find_all('//select[@id="userSelect"]/option')
  # userInfo <- data.frame(user = xml_text(users_node), value = xml_attr(users_node, "value"), stringsAsFactors = F)
  userInfo <- list()
  for (i in 1:7){
    cat("request webpage ...\n")
    p <- GET(urls[i]) %>% content()
    # p <- getURL(urls[i], curl = ch)
    # save_html(p, "RCurl_elearn/1.html")
    # doc <- read_html(p)
    lis <- xml_find_all(p, '//li[@class="clearfix liItem "]')
    info <- ldply(lis, get_users)
    userInfo[[i]] <- info
    nonce <- xml_find_all(p, "//input[@id='gradeQuestionNonce']") %>% xml_attr("value")
    # nonces <- xml_find_all(doc, "//input[@name='blackboard.platform.security.NonceUtil.nonce']")

    j=1
    params$blackboard.platform.security.NonceUtil.nonce <- nonce
    params$resultId <- info$id[i]
    
    res <- POST("http://elearning.ne.sysu.edu.cn/webapps/assessment/do/gradeQuestions",
                body = params, encode = "form") %>% 
      content() %T>% print
    
    tryCatch({
      for (j in 1:nrow(info)){
        cat(sprintf("[%d-%d-%d] %s\n", k, i, j, info$user[j]))
        if (info$status[j] == "需要评分"){
          params$resultId <- info$id[j]
          params$blackboard.platform.security.NonceUtil.nonce <- fromJSON(res)$new_nonce  
          res <- POST("http://elearning.ne.sysu.edu.cn/webapps/assessment/do/gradeQuestions",
                      body = params, encode = "form") %>%
            content() %T>% print
        }
      }
    }, 
    error=function(e) {
      errorId[i] <<- i
      message(sprintf("[%04d] ERROR: %s", i, e))
    })
  }
  result[[k]] <- setNames(userInfo, 1:7) %>% {.[sapply(., length) > 0]} %>% melt
}

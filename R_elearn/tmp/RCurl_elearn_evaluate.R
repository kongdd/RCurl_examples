rm(list = ls())
library(V8)
library(xml2)
library(stringr)
source('R/MainFunction.R', encoding = 'UTF-8')

## global environment
#  仅用于处理抄袭情况
params_grade <- list(
  blackboard.platform.security.NonceUtil.nonce = "619443c6-ea55-44be-8a45-e8564dd6e3ff",
  collabGradeField     = "75", 
  course_id            = "_405_1", 
  course_user_id       = "_3702330_1", 
  gradeCommentField    = "", 
  gradeNotes           = "", 
  grade_action         = "grade", 
  grade_version        = "21333884", 
  groupAttemptId       = "", 
  group_id             = "", 
  lastViewedTime       = "1482913780533", 
  link_id_ref          = "4679b0bd-50e1-4872-9a0b-f5737b86b4d3", 
  old_collabGradeField = "", 
  old_gradeCommentField = "", 
  old_gradeNotes       = "", 
  postGradeHandlerClassName = "blackboard.webapps.blackboard.collab.DiscussionPostGradeHandler", 
  postGradeHandlerParams = "forum_id=_53996_1&user_id=_125104_1&author_id=_224406_1"
)

# login -------------------------------------------------------------------
get_info <- function(tr){
  user <- xml_text(tr)
  href <- xml_attr(tr, "href")
  data.frame(user, href, stringsAsFactors = F)
}

doc <- read_html("RCurl_elearn/第一次/message.htm")
trs <- xml_find_all(doc, '//ul[@id="contributorList"]/li[position()>1]/a')
info <- ldply(trs, get_info, .progress = "text")

i = 150
info[i, ]
url <- info$href[i]
# params <- inputs[match(names(params_grade), names(inputs)) %>% {.[!is.na(.)]}]
# params$gradeCommentField <- ""
# params %<>% c(., gradeCommentField = "", gradeNotes = "")
# params$grade_version <- grade_version
# params <- params[order(names(params))]

p <- straighten("curl 'http://elearning.ne.sysu.edu.cn/webapps/blackboard/execute/gradeCollab' -H 'Accept: text/javascript, text/html, application/xml, text/xml, */*' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3' -H 'Connection: keep-alive' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Cookie: JSESSIONID=94BC4488E69816474EF564E23C00B3AD.root; safedog-flow-item=AE46F7B8895D4633E2C87C0C0809A2EB; session_id=0FADF58F3A460532B6D546374FA029C9; JSESSIONID=76E5624CB225544BEFD831489AA4494E.root; xythosdrive=0' -H 'DNT: 1' -H 'Host: elearning.ne.sysu.edu.cn' -H 'Referer: http://elearning.ne.sysu.edu.cn/webapps/discussionboard/do/message?forum_id=53996&layer=thread&action=collect_forward&nav=discussion_board&origRequestId=9D38B7ABF717E67A76C242EFD776E525.root_1482913780274&conf_id=_413_1&user_id=_224406_1&course_id=_405_1&type=user_forum&pCallBackUrl=%2Fwebapps%2Fdiscussionboard%2Fdo%2Fforum%3Faction%3Dlist_threads%26course_id%3D_405_1%26conf_id%3D_413_1%26forum_id%3D53996%26nav%3Ddiscussion_board&keep=true&' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:50.0) Gecko/20100101 Firefox/50.0' -H 'X-Prototype-Version: 1.7' -H 'X-Requested-With: XMLHttpRequest' --data 'grade_action=grade&course_id=_405_1&group_id=&link_id_ref=4679b0bd-50e1-4872-9a0b-f5737b86b4d3&postGradeHandlerClassName=blackboard.webapps.blackboard.collab.DiscussionPostGradeHandler&postGradeHandlerParams=forum_id%3D_53996_1%26user_id%3D_125104_1%26author_id%3D_224406_1&grade_version=21333884&course_user_id=_3702330_1&groupAttemptId=&lastViewedTime=1482913780533&collabGradeField=79&old_collabGradeField=&gradeCommentField=&old_gradeCommentField=&gradeNotes=&old_gradeNotes=&blackboard.platform.security.NonceUtil.nonce=619443c6-ea55-44be-8a45-e8564dd6e3ff'")
getURL("http://elearning.ne.sysu.edu.cn/webapps/blackboard/execute/gradeCollab",
         curl = ch, referer = url, 
         .opts = list(httpheader= c('Content-Type' = "text/x-json;charset=UTF-8"), 
                      postfields = toJSON(params))) %T>% {print(html_body(.))}

curlPerform("http://elearning.ne.sysu.edu.cn/webapps/blackboard/execute/gradeCollab",
            httpheader=c('Content-Type' = "text/x-json;charset=UTF-8"),
            postfields=toJSON(params),
            customrequest = 'POST', 
            verbose = TRUE, curl =ch, 
            ssl.verifypeer = FALSE)

fname <- sprintf("%s%04d_%s.txt", outdir, i, gsub(" ", "_", info$user[i]))
write_lines(x, fname)

## 作文进行重新整理
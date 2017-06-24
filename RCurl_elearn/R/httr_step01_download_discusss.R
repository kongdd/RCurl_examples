# rm(list = ls())
library(parallel)
library(purrr)
source('R/MainFunction.R', encoding = 'UTF-8')

## global FUNCTIONS --------------------------------------
get_info <- function(tr){
  user <- xml_text(tr)
  href <- xml_attr(tr, "href")
  data.frame(user, href, stringsAsFactors = F)
}

get_Infos <- function(file){
  p <- read_html(file)
  
  trs <- xml_find_all(p, '//ul[@id="contributorList"]/li/a') #[position()>1]
  info <- ldply(trs, get_info, .progress = "text")
  
  xlist <- transpose(info) 
  xlist <- llply(seq_along(xlist), function(i){
    c(id = i, xlist[[i]])
  }) %>% set_names(seq_along(.))
  
  return(list(Info = info, xx = xlist))
}

download_essay <- function(x, outdir){
  file <- sprintf("%s%04d_%s.txt", outdir, x$id, gsub(" ", "_", x$user))
  if (!file.exists(file)){
    tryCatch({
      p <- GET(x$href) %>% content()
      txt <- xml_find_all(p, '//div[@id="collectionContainer"]')
      
      readr::write_lines(as.character(txt), file)
      # writeLines(txt, file)
    },
    error=function(e) {
      #   # errorId[[i]] <- i
      #   # message(sprintf("[%04d] ERROR: %s", i, e))
      message(e)
    })
  }
}


Id_finished <- function(outdir){
  files <- dir(outdir)
  str_extract(files, "\\d{1,4}") %>% as.numeric()
}
## ---------------------------------------------------

file <- "RCurl_elearn/data/2017a/第二次学习活动/Blackboard Learn_files/launcher.html"
outdir <- paste0(dirname(dirname(file)), "/data/")

xx <- get_Infos(file)
## parellel model

pkgs <- c("httr", "xml2", "magrittr")
cl <- makeCluster(8, outfile = "log.txt")
clusterExport(cl, c("pkgs"))
tmp <- clusterEvalQ(cl, {
  lapply(pkgs, library, character.only = T)
  source("RCurl_elearn/R/login_blackboard_httr.R")
})

tmp <- parLapplyLB(cl, xlist, download_essay, outdir)
tmp <- parLapplyLB(cl, xlist[-Id_finished(outdir)], download_essay, outdir)


## GET user info
# List of 16
## 01 控制面板→需要评分
url <- "http://elearning.ne.sysu.edu.cn/webapps/gradebook/do/instructor/viewNeedsGrading?course_id=_405_1"
p <- GET(url) %>% content()
Items <- xml_find_all(p, '//select[@name="itemFilter"]/option[position()>1]') %T>% print

## 02. 选择对应的作业题目，并进行登录
i <- 2
itemFilter <- Items[[i]] %>% xml_attr("value")
## select Items:
param2 <- list(
  course_id             = "_405_1",
  categoryFilter        = "allCategories",
  dateFilterSelect      = "allDates",
  dateSubmitted_datetime= "",
  itemFilter            = itemFilter,
  pickdate              = "",
  pickname              = "",
  studentFilter         = "allStudents"
)
p <- POST("http://elearning.ne.sysu.edu.cn/webapps/gradebook/do/instructor/viewNeedsGrading", 
          body = param2, encode = "form") %>% content()

## 
xml_find_all(p, "//table")
# courseMembershipId: student Id
save_html(p)

xml_find_all(p, "//table/tbody/tr[1]/td[2]/span") %>% 
  {xml_attrs(.)[[1]][-(1:2)]}

tmp <- url2params(url)

# param <- {
#   layer                	= "forum"
#   currentUserInfo      	= "2016秋入学专科 吴慧英 (活动)"
#   conf_id              	= "_413_1"
#   numAttempts          	= "1626"
#   type                 	= "user_forum"
#   attempt_id           	= "_5918115_1"
#   callBackUrl          	= "/webapps/gradebook/do/instructor/viewNeedsGrading?course_id=_405_1&courseMembershipId=_3928655_1&outcomeDefinitionId=_114127_1"
#   forum_id             	= "_61110_1"
#   currentAttemptIndex  	= "1"
#   nav                  	= "discussion_board_entry"
#   action               	= "collect_forward"
#   origRequestId        	= "0D68B9644B97B73FA532AC7B5119169C.root_1498061370964"
#   user_id              	= "_227280_1"
#   course_id            	= "_405_1"
#   sequenceId           	= "_405_1_0"
#   viewInfo             	= "需要评分"
# }
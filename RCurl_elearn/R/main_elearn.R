# source("RCurl_elearn/R/main_elearn.R", encoding = 'UTF-8')
## global FUNCTIONS --------------------------------------
# get_info <- function(tr){
#   user <- xml_text(tr)
#   href <- xml_attr(tr, "href")
#   data.frame(user, href, stringsAsFactors = F)
# }

# get_Infos <- function(file){
#   p <- read_html(file)
  
#   trs <- xml_find_all(p, '//ul[@id="contributorList"]/li/a') #[position()>1]
#   info <- ldply(trs, get_info, .progress = "text")
  
#   xlist <- transpose(info) 
#   xlist <- llply(seq_along(xlist), function(i){
#     c(id = i, xlist[[i]])
#   }) %>% set_names(seq_along(.))
  
#   return(list(Info = info, xx = xlist))
# }

download_essay <- function(x, outdir){
  ## Check Outdir
  if (dir.exists(outdir)) dir.create(outdir)
  
  if (str_sub(outdir, nchar, nchar) != "/")
    outdir %<>% paste0(., "/")
  
  file <- sprintf("%s%04d_%s.txt", outdir, x$id, gsub(" ", "_", x$user))
  if (!file.exists(file)){
    tryCatch({
      p <- GET(x$href) %>% content()
      txt <- xml_find_all(p, '//div[@id="collectionContainer"]')
      
      readr::write_lines(as.character(txt), file)
      return(txt)
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

#' 简化抓取下来的讨论内容
simply_xml <- function(p, userInfo){
  if (class(p) == "xml_nodeset"){
    node <- xml_find_all(p, "//div[@class='vtbegenerated']")
  
    x <- xml_find_all(node, "p") %>% xml_text()
    if (length(x) == 0) x <- xml_text(node)
  }else{
    x <- "Error in retrieve data ..."
  }

  head <- sprintf("<hr><p>[%d] %s</p>", userInfo$id, userInfo$user)
  ps <- sprintf("<p>%s</p>", x)
  txt <- paste(c(head, ps), collapse = "")

  return(txt)
}

simply_txt <-function(file, userInfo){
  node <- read_html(file, encoding = "UTF-8") %>% 
    xml_find_all("//div[@class='vtbegenerated']")
  simply_xml(node, userInfo) #quickly return
}
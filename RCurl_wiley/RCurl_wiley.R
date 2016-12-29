rm(list = ls())
source('R/MainFunction.R', encoding = 'UTF-8')
# library(xml2)

# https://services.readcube.com/reader/pdf?ticket=2bd114d5-5693-4a28-94b4-66df6241e03c

x <- c(1,3, 5) 
y <- c(3, 2, 10)
cbind(x, y)

file <- "hw1_data.csv"
x <- read.csv(file)

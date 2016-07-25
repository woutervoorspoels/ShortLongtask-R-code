## read in and pre-process data
require(data.table)
rm(list=ls())
#some constants
nN <- 
nD <- 15
data <- list()

### Depression
filelist <- list.files(path='Depr', pattern = '.*.txt')
filelist <- paste('Depr/',filelist,sep="")
nD <- length(filelist)
datalist <- lapply(filelist,FUN=read.table,skip=8,header=T)
#datafr = do.call("rbind", datalist)
data[[1]] <- rbindlist(datalist,idcol="index")

### Suicidal
filelist <- list.files(path='Suic', pattern = '.*.txt')
filelist <- paste('Suic/',filelist,sep="")
nS <- length(filelist)
datalist <- lapply(filelist,FUN=read.table,skip=8,header=T)
#datafr = do.call("rbind", datalist)
data[[2]] <- rbindlist(datalist,idcol="index")

### Normal

filelist <- list.files(path='HC', pattern = '.*.txt')
filelist <- paste('HC/',filelist,sep="")
nH <- length(filelist)
datalist <- lapply(filelist,FUN=read.table,skip=8,header=T)
#datafr = do.call("rbind", datalist)
data[[3]] <- rbindlist(datalist,idcol="index")

### combine and index
require(dplyr)
require(tidyr)
fullset <- rbindlist(data,idcol="group")
fullset <- as.data.frame(fullset)

## select the correct trials
d <- filter(fullset, task%in%c(2,4), action>0)


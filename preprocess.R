### get data in a right form for analysis
source(file='readAll.R')

## d is the data without intermezzo trials
## task 2 is the short task, task 4 is the long task
## TODO: quickly write the experimental design
## TODO: use rmarkdown! so we can ease up communication (also after publication)

#### look at data
head(d)
unique(d$index[d$group==1])
unique(d$index[d$group==2])
unique(d$index[d$group==3])

## group: 1: Depr, 2: Suic, 3: HC
groupSize <- c(15,12,22)
groupLabel <- c('Depressed','Suicidal','HC')
d$label <- factor(d$group)
levels(d$label) <- list('HC'=3, 'Depressed'=1,'Suicidal'=2)

## give all participants a unique id
d$index2 <- NA
d$index2[d$group==1] <- d$index[d$group==1]+30
d$index2[d$group==2] <- d$index[d$group==2]+50
d$index2[d$group==3] <- d$index[d$group==3]
d$id <- factor(d$index2)
levels(d$id) <- seq(1,49)


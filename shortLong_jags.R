### model the data ####
require(ggplot2)
require(dplyr)
require(tidyr)
require(rjags)
require(runjags)
## read in data
rm(list=ls())
source(file='preprocess.R')

head(d)

## for reasons of testing, reduce to one condition
## DONE 16/8: no more reduction
dred <- d

## get data in right format
ns <- max(as.numeric(dred$id))
ntrials.max <- 120

dred$id <- as.numeric(dred$id)

ntrials <- rep(NA,ns)
task <- matrix(data=NA,ns,ntrials.max+1)
action <- matrix(data=NA,ns,ntrials.max)
state <- matrix(data=NA,ns,ntrials.max)
reward <- matrix(data=NA,ns,ntrials.max)
Estate <- matrix(data=NA,ns,ntrials.max)
group <- rep(NA,ns)

stateTransition <- function(cstate,action){
  #a1: 1-2-3-1-2-3
  #a2: 1-3-2-1-
  if(!is.na(cstate)){
    
    if(action==0){
      nextstate <- c(2,3,1)
    }else if(action==1){
      nextstate <- c(3,1,2)
    }
    return(nextstate[cstate])
  }else{
    return(NA)
  }
}
 
for( i in 1:ns){
  temp <- filter(dred,id==i)%>%
    arrange(scan)
  ntrials[i] <- length(temp$scan)
  task[i,1:ntrials[i]] <- temp$task
  ##required?
  task[i,ntrials[i]+1] <- 99
  state[i,1:ntrials[i]] <- temp$state
  action[i,1:ntrials[i]] <- temp$action-1
  Estate[i,] <- unlist(Map(stateTransition,state[i,],action[i,]))
  reward[i,1:ntrials[i]] <- temp$reward
  group[i] <- temp$group[1] 
}

#### jags analyse
dataList <- list(
  nsubj=ns,
  task=task,
  ntrials=ntrials,
  action=action,
  state=state,
  Estate=Estate,
  reward=reward,
  group=group
)

## TODO: aanpassen voor hierarchisch
initsList <- function(){ 
  Galpha=runif(3,0.01,1)
  Ggamma=runif(3,0.01,1)
  Gtheta=runif(3,0.01,1)
  vars=runif(3,.2,.8)
  tau=runif(ns,.2,.5)
  return(list(Galpha=Galpha,Ggamma=Ggamma,Gtheta=Gtheta,
              varalpha=vars,vargamma=vars,vartheta=vars,tau=tau))
}

nadapt <- 1e3
nburnin <- 1e3
nsample <- 1e4

runJagsout <- run.jags( method = "parallel",
                        model = "Q-learning-switch.txt",
                        monitor = c("Galpha", "Ggamma", "Gtheta",
                                    "alpha","gamma","theta"),
                        data = dataList,
                        inits = initsList,
                        n.chains = 2,
                        thin = 1,
                        adapt = nadapt,
                        burnin = nburnin,
                        sample = nsample,
                        summarise=FALSE
)

summary(runJagsout)
codaSamples = as.mcmc.list(runJagsout)
gelman.diag(codaSamples)
allSamples<-combine.mcmc(codaSamples)
colMeans(allSamples)
colnames(allSamples)
par(mfrow=c(2,2))
hist(allSamples[,'Ggamma[2]'],xlim=c(0,1))
hist(allSamples[,'Gtheta[2]'],xlim=c(0,1))
hist(allSamples[,'Ggamma[3]'],xlim=c(0,1))
hist(allSamples[,'Gtheta[3]'],xlim=c(0,1))
dev.off()
par(mfrow=c(1,2))
plot(as.numeric(allSamples[,'Gtheta[1]']), as.numeric(allSamples[,'Ggamma[1]']),pch=1, xlim=c(0,1))
plot(as.numeric(allSamples[,'Gtheta[2]']), as.numeric(allSamples[,'Ggamma[2]']),pch=1, xlim=c(0,1))

### TODO: validate model !!!! 
## how to check the fit/adequacy of the model?
## interesting question
## who cares in this literature?



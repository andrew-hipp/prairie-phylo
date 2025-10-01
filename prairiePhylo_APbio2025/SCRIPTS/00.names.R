library(WorldFlora)

if(!exists('WFO.data')) {
  tempWFO = try(WFO.remember('classification.txt'))
  if(class(tempWFO) == 'try-error') {
    WFO.download(extra = "--no-check-certificate") # added 2025-02-28
  }
  rm(tempWFO)
}

dat.names <- dat.names.orig <- read.csv('DATA/dat.names_APbio25.csv')
dat.wfoMatch <-
  WFO.match(gsub('_', ' ', dat.names$treeName, fixed = T),
            WFO.data = WFO.data,
            counter = 1)
dat.wfoOne <- WFO.one(dat.wfoMatch)
dat.names$accepted <- dat.wfoOne$scientificName
dat.names$author <- dat.wfoOne$scientificNameAuthorship

write.csv(dat.wfoMatch, 'OUT/dat.wfoMatch.csv')
write.csv(dat.wfoOne, 'OUT/dat.wfoOne.csv')
write.csv(dat.names, 'OUT/dat.names.updated.csv')

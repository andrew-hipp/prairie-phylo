library(WorldFlora)

if(!exists('WFO.data')) {
  tempWFO = try(WFO.remember('classification.txt'))
  if(class(tempWFO) == 'try-error') {
    WFO.download(method = "wget", extra = "--no-check-certificate") # added 2025-02-28
  }
  rm(tempWFO)
}

dat.names <- read.csv('prairiePhylo_2.2/DATA/dat.names.barber25.csv')
dat.wfoMatch <-
  WFO.match(gsub('_', ' ', dat.names$treeName, fixed = T),
            WFO.data = WFO.data,
            counter = 1)
dat.wfoOne <- WFO.one(dat.wfoMatch)
dat.names$accepted <- dat.wfoOne$scientificName
dat.names$author <- dat.wfoOne$scientificNameAuthorship

write.csv(dat.wfoMatch, 'prairiePhylo_2.2/OUT/dat.wfoMatch.csv')
write.csv(dat.wfoOne, 'prairiePhylo_2.2/OUT/dat.wfoOne.csv')
write.csv(dat.names, 'prairiePhylo_2.2/OUT/dat.names.updated.csv')

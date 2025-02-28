library(ape)
library(phytools)
library(magrittr)

# get label.elements:
source('https://raw.githubusercontent.com/andrew-hipp/morton/master/R/label.elements.R')

## get Smith and Brown 2018 tree
if(!exists('dat.tr')) {
  smithBrownTree <- 'https://github.com/FePhyFoFum/big_seed_plant_trees/releases/download/v0.1/v0.1.zip'
  temp <- tempfile()
  download.file(smithBrownTree,temp)
  dat.tr <- read.tree(unz(temp, "v0.1/ALLMB.tre"))
  unlink(temp)
} # close if


## weld on singletons;
## at this point, only Symphyotrichum oolentangiense
dat.tr2 <- dat.tr
dat.tr2 <-
  drop.tip(dat.tr2, setdiff(dat.tr2$tip.label, dat.names$splicedTreeName))
dat.tr2 <- force.ultrametric(dat.tr2)

nodes <- c(
  Symphyotrichum_oolentangiense = 'Symphyotrichum_novae-angliae|Symphyotrichum_laeve'
) # close nodes

for(i in names(nodes)) {
  message(paste('... binding', i, 'to phylogeny'))
  nodeTemp <- findMRCA(dat.tr2, grep(nodes[i], dat.tr$tip.label, value = T))
  dat.tr2 <- bind.tip(dat.tr2, i, where = nodeTemp)
  rm(nodeTemp)
} # close for

## Fix Carex
dat.carex <- read.tree('https://raw.githubusercontent.com/andrew-hipp/2019-GCG/master/DATA/Carex10Fossil.divTree.tre')
dat.carex2 <-
  drop.tip(dat.carex,
            grep('Carex', dat.names$treeName, value = T) %>%
            paste(collapse = '|') %>%
            grep(x = dat.carex$tip.label, invert = T, value = T)
          ) # close drop.tip
dat.carex2$tip.label <-
  label.elements(dat.carex2, returnNum=1, fixed = T) %>% as.character

dat.tr3 <-
  drop.tip(dat.tr2,
            grep('Carex', dat.tr2$tip.label, value = T),
            trim.internal = F
          )

dat.subtreeDepth <-
  max(node.depth.edgelength(dat.tr3)) -
  node.depth.edgelength(dat.tr3)[which(dat.tr3$tip.label == '')]

carex.pos <- max(dat.carex2 %>% node.depth.edgelength) - dat.subtreeDepth

dat.tr3 <-
  bind.tree(dat.tr3, dat.carex2,
            where = which(dat.tr3$tip.label == ''),
            position = carex.pos)
dat.tr3 <- drop.tip(dat.tr3, '')

## write trees
dat.tr.analysis <- dat.tr.figures <- ladderize(dat.tr3)
dat.tr.analysis$tip.label <-
  dat.names$phylo.spp[match(dat.tr3$tip.label, dat.names$splicedTreeName)]
dat.tr.figures$tip.label <-
  dat.names$accepted[match(dat.tr3$tip.label, dat.names$splicedTreeName)]

write.tree(dat.tr.analysis, 'prairiePhylo_2.2/OUT/tr.analysis.tre')
write.tree(dat.tr.figures, 'prairiePhylo_2.2/OUT/tr.acceptedNames.tre')

#creating P value column

setwd("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-regenie2/")
#read in data
logCAC <- read.table("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-regenie2/DATA-logCAC-all.regenie.gz", header=T, stringsAsFactors=F)
INTCAC <- read.table("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-regenie2/DATA-INTCAC-all.regenie.gz", header=T, stringsAsFactors=F)

#calculate p value and put into dataframe
logCAC$P <- 10^(-logCAC$LOG10P)
INTCAC$P <- 10^(-INTCAC$LOG10P)

#write to file
write.table(logCAC, "/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-regenie2/DATA-logCAC-allP.regenie.gz", row.names=F, col.names=T, quote=F)
write.table(INTCAC, "/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-regenie2/DATA-INTCAC-allP.regenie.gz", row.names=F, col.names=T, quote=F)


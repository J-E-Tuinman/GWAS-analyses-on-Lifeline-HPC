# Script for preparing phenotype and covariate file for REGENIE step 1
# Based on script0_regenie_phenos.R, written by Peter van der Most, October 2025

#### Load data ####
DALL <- read.table(path to file filtered on individuals with genotype data plus CAC, logCAC and INT_CAC, header=T, stringsAsFactors = F)
#DALL$age2 <- DALL$age^2 # Possibly not required

#### data prep ####
Ddata <- read.csv(path to linkage file, header = T, stringsAsFactors = F)
Ddata <- merge(Ddata, DALL, all.x = F, all.y = F, by.x = "project_pseudo_id", by.y = "project_pseudo_id")

# add PCs
PCdata <- read.table(path to PC file,
                     header = T, stringsAsFactors = F)
# if necessary, change FID to 0 instead of 1
# PCdata$FID <- 0L
Ddata <- merge(Ddata, PCdata, by.x = "ID_column_in_linkage_file", by.y = "IID", all.x =T, all.y = F, sort = F)
rm(PCdata)

colnames(Ddata)[1] <- "IID"
Ddata <- Ddata[,c("FID", "IID", "age", "gender", "logCAC", "INT_CAC" paste0("PC", 1:10))] #Remember to add age2 if needed
write.table(Ddata, "dataF_data.txt", sep = "\t", quote = F, row.names = F)
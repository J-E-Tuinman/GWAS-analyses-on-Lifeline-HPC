# Script for preparing phenotype and covariate file for REGENIE step 1
# Based on script0_regenie_phenos.R, written by Peter van der Most, October 2025

#set working directory
setwd("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/")

#### Load data ####
DALL <- read.table("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/pheno_INT_log.txt", header=T, stringsAsFactors = F)
#DALL$age2 <- DALL$age^2 # Possibly not required

#load linkage file to link Imalife pseudo ID to UGLI pseudo ID
Dlink <- read.table("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/samples_new/both_id.txt", header=T, stringsAsFactors = F)

#add UGLI pseudo ID to DALL based on Imalife pseudo ID
DALL <- merge(DALL, Dlink[,-1], by.x = "project_pseudo_id", by.y = "project_pseudo_id_old", all.x = F, all.y = F)

#### data prep ####
#load UGLI linkage file and merge with DALL
Ddata <- read.table("Linkage_file_path", header = T, stringsAsFactors = F)
Ddata <- merge(Ddata, DALL, all.x = F, all.y = F, by.x = "PROJECT_PSEUDO_ID", by.y = "project_pseudo_id_LL")

#remove duplicates
Ddata <- Ddata[!duplicated(Ddata$PROJECT_PSEUDO_ID), ]

# add PCs
PCdata <- read.table("/groups/umcg-lifelines/tmp02/projects/ov19_0495/2_PCs/UGLI0-3_EUR_PCs.txt",
                     header = T, stringsAsFactors = F)
# if necessary, change FID to 0 instead of 1
# PCdata$FID <- 0L
Ddata <- merge(Ddata, PCdata, by.x = "Barcode", by.y = "IID", all.x =F, all.y = F, sort = F)
rm(PCdata)

colnames(Ddata)[1] <- "IID"
Ddata <- Ddata[,c("FID", "IID", "age", "gender", "INT_CAC", paste0("PC", 1:10))] #Remember to add age2 if needed
write.table(Ddata, "dataF_data_INTCAC.txt", sep = "\t", quote = F, row.names = F)


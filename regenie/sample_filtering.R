#set working directory
setwd("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/UGLI0-3")

#read in data
Fdata <- read.table("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/UGLI0-3/samples/pheno_INT_log.txt", header = T)
GSA_link <- read.csv("/groups/umcg-lifelines/prm03/projects/ov23_0782/linkage_files_202506/gsa_linkage_file_v2_OV23_0782.csv", header = T)
CYTO_link <- read.csv("/groups/umcg-lifelines/prm03/projects/ov23_0782/linkage_files_202506/cytosnp_linkage_file_v5_OV23_0782.csv", header = T)
AFFY_link <- read.csv("/groups/umcg-lifelines/prm03/projects/ov23_0782/linkage_file_202512/OV23_00782_affymetrix_linkage_file_v3.csv", header = T)

##CytoSNP prep##
CYTO <- merge(CYTO_link, Fdata, all.x = F, all.y = F, by = "project_pseudo_id")
#add PCs
PCcyto <- read.table("/groups/umcg-lifelines/rsc02/releases/cytosnp_genotypes/v4/PC/LL_CytoSNP_PCs.txt", header = T)
CYTO <- merge(CYTO, PCcyto, by.x = "cytosnp_ID", by.y = "IID", all.x = T, all.y = F)
rm(PCcyto)

colnames(CYTO)[1] <- "IID"
CYTO <- CYTO[,c("FID", "IID", "age", "gender", "logCAC", paste0("PC", 1:10))]
write.table(CYTO, "dataF_CS_log.txt", sep = "\t", quote = F, row.names = F)

##GSA prep##
GSA <- merge(GSA_link, Fdata, all.x = F, all.y = F, by = "project_pseudo_id")
#add PCs
PCGSA <- read.table("/groups/umcg-lifelines/rsc02/releases/gsa_genotypes/v2/Data/PC/PCA_eur.UGLI.eigenvec")
colnames(PCGSA)[3:22] <- paste0("PC", 1:10)
colnames(PCGSA)[1:2] <- c("FID", "IID")
GSA <- merge(GSA, PCGSA, by.x = "UGLI_ID", by.y = "IID", all.x = T, all.y = F)
rm(PCGSA)

colnames(GSA)[1] <- "IID"
GSA <- GSA[,c("FID", "IID", "age", "gender", "logCAC", paste0("PC", 1:10))]
write.table(GSA, "dataF_GSA_log.txt", sep = "\t", quote = F, row.names = F)

##Affy prep##
AFFY <- merge(AFFY_link[,-3], Fdata, all.x = F, all.y = F, by = "project_pseudo_id")
#add PCs
PCAFFY <- read.table("/groups/umcg-lifelines/rsc02/releases/affymetrix_genotypes/v3/PCs/PCs_UGLI2+3.txt")
colnames(PCAFFY)[3:22] <- paste0("PC", 1:10)
colnames(PCAFFY)[1:2] <- c("FID", "IID")
AFFY <- merge(AFFY, PCAFFY, by.x = "Barcode", by.y = "IID", all.x = T, all.y = F)
rm(PCAFFY)

colnames(AFFY)[1] <- "IID"
AFFY <- AFFY[, c("FID", "IID", "age", "gender", "logCAC", paste0("PC", 1:10))]
write.table(AFFY, "dataF_AFFY_log.txt", sep = "\t", quote = F, row.names = F)
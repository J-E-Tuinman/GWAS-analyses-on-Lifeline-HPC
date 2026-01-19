# Script to create a CytoSNP sample file for REGENIE/.bgen format
# Based on scriptL2c_P33R5
# Written by Peter van der Most, December 2022; updated June 2023; updated again October 2025
# Updated Januari 2026 to be used in ov23_0782 project


setwd("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/")
# The CytoSNP v5 bgen sample file is NOT formatted correctly: the 4th column is order,
# not gender, and regenie refuses values > 2. (That said, I am not sure REGENIE even uses this column.)
# Note: below file uses v4 linkage file, since v5 is not accesible for some reason
# Note: 


DPHENO <- read.csv("/groups/umcg-lifelines/prm03/projects/ov23_0782/dataset_order_202506/results/1b_q_1_results.csv",
                 header = T, colClasses = c("character", "character", "NULL", "NULL", "character", rep("NULL", 660)))#, nrow = 100)
DPHENO <- DPHENO[DPHENO$variant_id=="1a_v_1_anthro_8plus_v1",]
DPHENO$newgender <- ifelse(DPHENO$gender == "MALE", 1L, ifelse(DPHENO$gender == "FEMALE", 2L, 0L))

table(DPHENO$gender, useNA = "always")
table(DPHENO$newgender, useNA = "always")


# NOTE v5 linkage not accessible, so use v4
DLINK <- read.csv("/groups/umcg-lifelines/prm03/projects/ov23_0782/linkage_files_202506/cytosnp_linkage_file_v5_OV23_0782.csv",
                    header = T, stringsAsFactors = F)
DLINK <- merge(DLINK, DPHENO, all.x = T, all.y = F, by.x = 2, by.y = 1)
sum(is.na(DLINK$newgender)) # 14 missing


# check if we can find these in the aforementioned sample files
DHAP <- read.table("/groups/umcg-lifelines/rsc02/releases/cytosnp_genotypes/v4/data/chr9.sample", header = F, skip = 2)
colnames(DHAP) <- c("ID_1", "ID_2", "missing", "father", "mother", "sex", "plink_pheno")
table(DHAP$sex, useNA = "always") # 7 missing

(samples_without_sex <- DLINK$cytosnp_ID[is.na(DLINK$newgender)])


DHAP[DHAP$ID_2 %in% samples_without_sex,] # all have gender value
DHAP <- DHAP[,c("ID_2", "sex")]


DLINK2 <- merge(DLINK, DHAP, all.x = T, all.y = F, sort = F, by.x = "cytosnp_ID", by.y = "ID_2")

all(DLINK2$newgender == DLINK2$sex | is.na(DLINK2$newgender)) # 4 errors
DLINK2[DLINK2$newgender != DLINK2$sex & !is.na(DLINK2$newgender),] # all 4 have value 0 in DHAP,
# so they are not errors

# We assume that the phenotype files are correct and the sample file in the v4 genotypes are not.

table(DLINK2$sex)
DLINK2$sex[DLINK2$sex == 0] <- DLINK2$newgender[DLINK2$sex == 0]
table(DLINK2$sex)

rm(DHAP, DLINK, DPHENO, samples_without_sex)
DLINK2 <- DLINK2[,c("cytosnp_ID", "sex")]
gc()

# sample file
DS <- read.table("/groups/umcg-lifelines/rsc02/releases/cytosnp_imputed/v5/imputed_bgen/LL_cytosnp.sample",
                 header = F, skip = 2)
# DS has a double header, remember to add a D to column sex
colnames(DS) <- c("ID_1", "ID_2", "missing", "order")

all(DS$order == 1:nrow(DS)) # true, so we can use order column


DO <- merge(DS, DLINK2, by.x = 2, by.y = 1, all.x = T, all.y = F)
summary(DO) # 22 missing sex - because the bgen sample files contain 22 more samples the PLINK files.
# I cnanot explain this, except possibly through differences between v4 & v5
DO[is.na(DO$sex),] # they have LL IDs and are not obviously out of order...


#### Did some testing (code not shown): they are not in the linkage file, so even if there are phenotypes, we cannot use them.

DO$sex[is.na(DO$sex)] <- 0L

DO <- DO[order(DO$order), c("ID_1", "ID_2", "missing", "sex", "order")]
summary(DO) # no more missings
all(DO$order == 1:nrow(DO))

write.table(t(colnames(DO)[-5]), "CytoSNP_BGEN_sample.txt", row.names = F, col.names = F, quote = F, sep = " ")
write.table(t(c(0,0,0,"D")), "CytoSNP_BGEN_sample.txt", append = T, row.names = F, col.names = F, quote = F, sep = " ")
write.table(DO[,-5], "CytoSNP_BGEN_sample.txt", append = T, row.names = F, col.names = F, quote = F, sep = " ")

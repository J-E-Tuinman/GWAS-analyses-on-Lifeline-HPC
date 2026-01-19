### Filtering imal data on Europeans with valid CAC score ###

#set working directory
setwd("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3")

#read in data
ethnicity <- read.csv("/groups/umcg-lifelines/prm03/projects/ov23_0782/dataset_order_202506/results/1b_q_1_results.csv", header = T)
Fdata <- read.csv("/groups/umcg-lifelines/prm03/projects/ov23_0782/dataset_order_202506/results/imal_v_1_results.csv", header = T)

#filter on Europeans & valid CAC
Fdata <- Fdata[Fdata$cacscore_agatston_adu_m_1 != "$5", c("project_pseudo_id", "gender", "age", "cacscore_agatston_adu_m_1")]
ethnicity <- ethnicity[ethnicity$ethnicity_category_adu_q_1 == "1", c("project_pseudo_id", "ethnicity_category_adu_q_1")]
euro <- merge(Fdata, ethnicity, all.x = F, all.y = F, by = "project_pseudo_id")

#save file
write.table(euro, "imal_euro_filtered.txt", quote = F, sep = "\t", row.names = F)

#set working directory
setwd("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/")

#Generating residuals for INT transform
#load in applicable libraries
library(e1071) #for skewness and kurtosis functions
library(dplyr) #for data manipulation
#load in data
all <- read.table("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/samples_new/all_used_data.txt", header=T, stringsAsFactors = F)
all_log <- read.table("pheno_log.txt", header=T, stringsAsFactors=F)

#fit linear model to data
model <- lm(cacscore_agatston_adu_m_1 ~ age + gender, data = all)

#extract residuals
residuals <- resid(model)

#defining INT function
INV.form_avg <- function(x) {
    qnorm((rank(x, na.last="keep") -0.5)/sum(!is.na(x)))
}
#apply INT to residuals
all_INT <- all %>%
    mutate(INT_CAC = INV.form_avg(residuals))

#check normality (slight deviations are acceptable for GWAS)
print ("all")
mean(all_INT$INT_CAC, na.rm = T) #should be close to 0
sd(all_INT$INT_CAC, na.rm = T) #should be close to
skewness(all_INT$INT_CAC, na.rm = T) #should be close to 0
kurtosis(all_INT$INT_CAC, na.rm = T) #should be close to 3
#Open a PNG device (creates an image file)
png("histogram_all_INT_CAC.png", width = 800, height = 600)
# Create histogram
hist(all_INT$INT_CAC,
     main = "Histogram of all INT_CAC",
     xlab = "INT_CAC values",
     col = "lightgreen",
     border = "white")
# Close the device (saves the plot)
dev.off()
#Q-Q plot
png("qqplot_all_INT_CAC.png", width = 800, height = 600)
qqnorm(all_INT$INT_CAC, main = "All INT_CAC")
qqline(all_INT$INT_CAC)
dev.off()
#generate file with INT CAC scores
write.table(all_INT, "pheno_INT.txt", sep = "\t", row.names = F, quote = F)

#combine pheno_INT.txt with pheno_log.txt to have both phenotypes in one file
all_pheno <- merge(all_INT, all_log, by = c("project_pseudo_id","age","gender","cacscore_agatston_adu_m_1"), all = TRUE, sort = F)
write.table(all_pheno, "pheno_INT_log.txt", sep = "\t", row.names = F, quote = F)

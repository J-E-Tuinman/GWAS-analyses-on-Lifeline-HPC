#set working directory
setwd("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/UGLI0-3/output/")

#load in applicable libraries
library(e1071) #for skewness and kurtosis functions
library(dplyr) #for log transform

#Read in data
data <- read.table("/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/UGLI0-3/samples/imal_euro_filtered.txt", header=T, stringsAsFactors = F)

#Perform log transformation on CAC score
all_log <- data %>%
  mutate(logCAC = log(cacscore_agatston_adu_m_1 + 1))


#check normality (slight deviations are acceptable for GWAS)
print ("all")
mean(all_log$logCAC, na.rm = T) #should be around 0
sd(all_log$logCAC, na.rm = T) #should be around 1
skewness(all_log$logCAC, na.rm = T) #should be around 0
kurtosis(all_log$logCAC, na.rm = T) #should be around 3
# Open a PNG device (creates an image file)
png("histogram_all_logCAC.png", width = 800, height = 600)
# Create histogram
hist(all_log$logCAC,
     main = "Histogram of all logCAC",
     xlab = "logCAC values",
     col = "skyblue",
     border = "white")
# Close the device (saves the plot)
dev.off()
#Q-Q plot
png("qqplot_all_logCAC.png", width = 800, height = 600)
qqnorm(all_log$logCAC, main = "All logCAC")
qqline(all_log$logCAC)
dev.off()
#generate file with log CAC scores
write.table(all_log, "pheno_log.txt", sep = "\t", row.names = F, quote = F)


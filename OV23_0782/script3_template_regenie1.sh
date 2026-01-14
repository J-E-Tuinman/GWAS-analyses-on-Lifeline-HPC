#!/bin/bash
#SBATCH --job-name=DATA_PHENO
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=12G
#SBATCH --tmp=30GB
#SBATCH --cpus-per-task=8
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/DATA-PLINK/logs/log3_DATA_PHENO.txt
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/DATA-PLINK/logs/log3_DATA_PHENO.err
#SBATCH -t 00:40:00

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-PLINK/
gunzip dataG_DATA_v*.gz

# Prepare folders : DATA-regenie1 in advance
# It may not be necessary to use a separate temp folder for all as the temp files get unique names

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/
DIR_TEMP=./temp_DATA_PHENO	# for dumping low-mem index
mkdir -p $DIR_TEMP
# Note: be sure that the files in lowmem-prefix do NOT have overlapping names if you are running multiple phenotypes concurrently
# Note: for binary phenotypes, add argument --bt to below command. Binary uses 0/1 coding (with NA for missing)
# Note: missing phenotypes will be imputed in step1; unless argument --strict is used, which will remove samples with any missing phenotypes

module load regenie
regenie \
  --step 1 \
  --strict \
  --bed DATA-PLINK/dataG_DATA_v1 \
  --extract DATA-PLINK/dataG_DATA_v2.snplist \
  --keep DATA-PLINK/dataG_DATA_v2.id \
  --phenoFile dataF_DATA_PHENO.txt \
  --phenoCol PHENO \
  --covarFile dataF_DATA_PHENO.txt \
  --covarColList age,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
  --catCovarList gender\
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix ${DIR_TEMP}/temp_pred_PHENO \
  --threads 8 \
  --maxCatLevels 99 \
  --gz \
  --out DATA-regenie1/PHENO

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/DATA-PLINK
gzip dataG_DATA_v1.b*
cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output

#!/bin/bash
#SBATCH --job-name=DATA_INTCAC_step2
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=10G
#SBATCH --tmp=30GB
#SBATCH --cpus-per-task=4
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/logs/log4_regenie_DATA_INTCAC_step2.txt
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/logs/log4_regenie_DATA_INTCAC_step2.err
#SBATCH -t 24:00:00

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output
module load regenie
# Note: prepare folder: DATA-regenie2 in advance
# Note: for binary phenotypes, add argument --bt to below command. Binary uses 0/1 coding (with NA for missing)
# Note: the PART loop is required due to the .bgen files being split into 10 parts per chromosome for UGLI data
for CHR in `seq 1 22` 
do
  for PART in `seq 1 10` 
  do
      BGEN_FILE=/groups/umcg-lifelines/tmp02/projects/ov19_0495/3_Round2_Imputed_Genotypes_cleaned/BGEN/chr_${CHR}_part${PART}_UGLI0to3.bgen
      SAMPLE_FILE=/groups/umcg-lifelines/tmp02/projects/ov19_0495/3_Round2_Imputed_Genotypes_cleaned/BGEN/UGLI0to3.sample

      # Run regenie step 2
      # Note: again no age & sex present for this step due to the correction being applied when calculating residuals
  regenie \
    --step 2 \
    --bgen $BGEN_FILE \
    --sample $SAMPLE_FILE \
    --phenoFile dataF_data_INTCAC.txt \
    --phenoCol INT_CAC \
    --covarFile dataF_data_INTCAC.txt \
    --covarColList PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
    --pred DATA-regenie1/INT_CAC_pred.list \
    --bsize 400 \
    --minINFO 0.3 \
    --minMAC 2 \
    --threads 4 \
    --maxCatLevels 99 \
    --write-samples \
    --print-pheno \
    --gz \
    --out DATA-regenie2/DATA-INTCAC-chr${CHR}_part${PART}
  done
done


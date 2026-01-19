#!/bin/bash
#SBATCH --job-name=AFFY_logCAC_step2
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=10G
#SBATCH --tmp=30GB
#SBATCH --cpus-per-task=4
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/AFFY-regenie2/logs/log4_AFFY_logCAC.txt
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/AFFY-regenie2/logs/log4_AFFY_logCAC.err
#SBATCH -t 24:00:00

# Prepare folders in advance: AFFY-regenie2, AFFY-regenie2/logs

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output
module load regenie

for CHR in `seq 1 22` 
do
      BGEN_FILE=/groups/umcg-lifelines/rsc02/releases/affymetrix_imputed/v3/Imputed/BGEN/chr_${CHR}.bgen
      SAMPLE_FILE=/groups/umcg-lifelines/rsc02/releases/affymetrix_imputed/v3/Imputed/BGEN/chr_${CHR}.sample #SEX = NA

      # Run regenie step 2
  regenie \
    --step 2 \
    --bgen $BGEN_FILE \
    --sample $SAMPLE_FILE \
    --phenoFile dataF_AFFY_logCAC.txt \
    --phenoCol logCAC \
    --covarFile dataF_AFFY_logCAC.txt \
    --covarColList age,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
    --catCovarList gender \
    --pred AFFY-regenie1/logCAC_pred.list \
    --bsize 400 \
    --threads 4 \
    --maxCatLevels 99 \
    --write-samples \
    --print-pheno \
    --gz \
    --out AFFY-regenie2/AFFY-logCAC-chr${CHR}
done
#!/bin/bash
#SBATCH --job-name=GSA_logCAC_step2
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=10G
#SBATCH --tmp=30GB
#SBATCH --cpus-per-task=4
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/GSA-regenie2/logs/log4_GSA_logCAC.txt
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/GSA-regenie2/logs/log4_GSA_logCAC.err
#SBATCH -t 24:00:00

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output
module load regenie

for CHR in `seq 1 22` 
do
      BGEN_FILE=/groups/umcg-lifelines/rsc02/releases/gsa_imputed/v2/BGEN/chr_${CHR}.GSAr2.bgen
      SAMPLE_FILE=/groups/umcg-lifelines/rsc02/releases/gsa_imputed/v2/BGEN/chr_${CHR}.GSAr2.sample

      # Run regenie step 2
  regenie \
    --step 2 \
    --bgen $BGEN_FILE \
    --sample $SAMPLE_FILE \
    --phenoFile dataF_GSA_logCAC.txt \
    --phenoCol logCAC \
    --covarFile dataF_GSA_logCAC.txt \
    --covarColList age,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
    --catCovarList gender \
    --pred GSA-regenie1/logCAC_pred.list \
    --bsize 400 \
    --minINFO 0.3 \
    --minMAC 2 \
    --threads 4 \
    --maxCatLevels 99 \
    --write-samples \
    --print-pheno \
    --gz \
    --out GSA-regenie2/GSA-logCAC-chr${CHR}
done

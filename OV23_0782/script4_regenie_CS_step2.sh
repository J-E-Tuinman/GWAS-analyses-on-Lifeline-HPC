#!/bin/bash
#SBATCH --job-name=CS_logCAC_step2
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=10G
#SBATCH --tmp=30GB
#SBATCH --cpus-per-task=4
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/CS-regenie2/logs/log4_CS_logCAC.txt
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/CS-regenie2/logs/log4_CS_logCAC.err
#SBATCH -t 24:00:00

# Prepare folders in advance: CS-regenie2, CS-regenie2/logs

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output
module load regenie

for CHR in `seq 1 22` 
do
      BGEN_FILE=/groups/umcg-lifelines/rsc02/releases/cytosnp_imputed/v5/imputed_bgen/${CHR}.pbwt_reference_impute_qctools.bgen
      SAMPLE_FILE=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/CytoSNP_BGEN_sample.txt #Make separate sample file using script "script0_regenie_CS_samplefile.R". Here SEX = 1 or 2.

      # Run regenie step 2
  regenie \
    --step 2 \
    --bgen $BGEN_FILE \
    --sample $SAMPLE_FILE \
    --phenoFile dataF_CS_logCAC.txt \
    --phenoCol logCAC \
    --covarFile dataF_CS_logCAC.txt \
    --covarColList age,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
    --catCovarList gender \
    --pred CS-regenie1/logCAC_pred.list \
    --bsize 400 \
    --threads 4 \
    --maxCatLevels 99 \
    --write-samples \
    --print-pheno \
    --gz \
    --out CS-regenie2/CS-logCAC-chr${CHR}
done
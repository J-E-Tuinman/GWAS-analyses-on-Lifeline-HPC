#!/bin/bash
#SBATCH --time=00:55:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=regular
#SBATCH --mem=64GB
#SBATCH --tmp=30GB
#SBATCH --job-name=DATAprep
#SBATCH --output=log2_regenie_DATA_PLINK.txt
#SBATCH --error=log2_regenie_DATA_PLINK.err

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-PLINK
# Preparing genotype file for regenie step1
# Note for next time: running time is somewhat unpredictable: I've seen both 15+ mins and < 5 min


cd /groups/umcg-lifelines/tmp02/projects/ov19_0495/3_Round2_Imputed_Genotypes_cleaned/PLINK_prunedgenotypes/
cp UGLI0-3_HQSNPs_pruned.bed $TMPDIR
cp UGLI0-3_HQSNPs_pruned.bim $TMPDIR
cp UGLI0-3_HQSNPs_pruned.fam $TMPDIR

cd $TMPDIR


# Change name of file
# using PLINK 1.9 instead of 2, previous script required this due to merging bfiles
# possibly not required
module load PLINK/1.9-beta6-20190617
plink --bfile UGLI0-3_HQSNPs_pruned --make-bed --out dataG_DATA_v1

module purge
# loading PLINK2 because the no-id-header command is not recognized by PLINK 1
module load PLINK/2.0-alpha6.20-20250707
# performing QC and LD-pruning
plink2 \
  --bfile dataG_DATA_v1 \
  --geno 0.1 \
  --hwe 1e-6 \
  --mac 100 \
  --maf 0.01 \
  --mind 0.1 \
  --indep-pairwise 1000 100 0.9 \
  --out dataG_DATA_v2 \
  --no-id-header \
  --write-samples \
  --write-snplist


mv *.log /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-PLINK
gzip dataG_DATA_v1.b*
mv dataG_DATA_* /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-PLINK

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output


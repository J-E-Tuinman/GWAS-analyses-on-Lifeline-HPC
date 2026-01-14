#!/bin/bash
#SBATCH --time=00:55:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=regular
#SBATCH --mem=64GB
#SBATCH --tmp=30GB
#SBATCH --job-name=AFFY_prep
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/scripts/logs/log2_regenie_AFFY_PLINK.out
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/scripts/logs/log2_regenie_AFFY_PLINK.err

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/samples/
# Preparing genotype file for regenie step1
# Note for next time: running time is somewhat unpredictable: I've seen both 15+ mins and < 5 min
cp mergelist_GSA.txt $TMPDIR

cd /groups/umcg-lifelines/rsc02/releases/affymetrix_genotypes/v3/Genotypes/PLINK/
cp chr_*.bed $TMPDIR
cp chr_*.bim $TMPDIR
cp chr_*.fam $TMPDIR

cd $TMPDIR
rm chr_X*


# Change name of file
# using PLINK 1.9 instead of 2, previous script required this due to merging bfiles
# possibly not required
module load PLINK/1.9-beta6-20190617
plink --bfile chr_1 --merge-list mergelist_GSA.txt --make-bed --out dataG_AFFY_v1

module purge
# loading PLINK2 because the no-id-header command is not recognized by PLINK 1
module load PLINK/2.0-alpha6.20-20250707
# performing QC and LD-pruning
plink2 \
  --bfile dataG_AFFY_v1 \
  --geno 0.1 \
  --hwe 1e-6 \
  --mac 100 \
  --maf 0.01 \
  --mind 0.1 \
  --indep-pairwise 1000 100 0.9 \
  --out dataG_AFFY_v2 \
  --no-id-header \
  --write-samples \
  --write-snplist


mv *.log /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/AFFY-PLINK/logs/
gzip dataG_AFFY_v1.b*
mv dataG_AFFY_* /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/AFFY-PLINK/

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/samples/


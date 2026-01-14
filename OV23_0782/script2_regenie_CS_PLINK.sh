#!/bin/bash
#SBATCH --time=00:55:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=regular
#SBATCH --mem=64GB
#SBATCH --tmp=30GB
#SBATCH --job-name=CS_prep
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/scripts/logs/log2_regenie_CS_PLINK.out
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/scripts/logs/log2_regenie_CS_PLINK.err

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/samples/
# Preparing genotype file for regenie step1
# Note for next time: running time is somewhat unpredictable: I've seen both 15+ mins and < 5 min
cp mergelist_CS.txt $TMPDIR

cd /groups/umcg-lifelines/rsc02/releases/cytosnp_genotypes/v4/data_PLINK_format/
cp chr*.bed $TMPDIR
cp chr*.bim $TMPDIR
cp chr*.fam $TMPDIR

cd $TMPDIR
rm chrX*


# Change name of file
# using PLINK 1.9 instead of 2, previous script required this due to merging bfiles
# possibly not required
module load PLINK/1.9-beta6-20190617
plink --bfile chr1 --merge-list mergelist_CS.txt --make-bed --out dataG_CS_v1

module purge
# loading PLINK2 because the no-id-header command is not recognized by PLINK 1
module load PLINK/2.0-alpha6.20-20250707
# performing QC and LD-pruning
plink2 \
  --bfile dataG_CS_v1 \
  --geno 0.1 \
  --hwe 1e-6 \
  --mac 100 \
  --maf 0.01 \
  --mind 0.1 \
  --indep-pairwise 1000 100 0.9 \
  --out dataG_CS_v2 \
  --no-id-header \
  --write-samples \
  --write-snplist


mv *.log /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/CS-PLINK/logs/
gzip dataG_CS_v1.b*
mv dataG_CS_* /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/output/CS-PLINK/

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/samples/


#!/bin/bash
#SBATCH --job-name=GWAS_result_compression
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --tmp=40GB
#SBATCH --cpus-per-task=2
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/scripts/logs/GWAS_compression.log
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/scripts/logs/GWAS_compression.err
#SBATCH --time=04:00:00

# Set paths
WORKDIR=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-regenie2/
TMPDIR=${TMPDIR:-/scratch}

cd $TMPDIR

# Copy files to TMPDIR
cp $WORKDIR/DATA-INTCAC-chr*_part*_INT_CAC.regenie.gz .

# Merging seperate regenie step 2 result outputs into 1 summary statistics file
zcat DATA-INTCAC-chr1_part1_INT_CAC.regenie.gz | head -n 1 > DATA-INTCAC-all.regenie
for chr in {1..22}; do
  for part in {1..10}; do
    zcat DATA-INTCAC-chr${chr}_part${part}_INT_CAC.regenie.gz | tail -n +2 >> DATA-INTCAC-all.regenie
  done
done

# Compress and move back
gzip DATA-INTCAC-all.regenie
mv DATA-INTCAC-all.regenie.gz $WORKDIR/

echo "Done: $(date)"

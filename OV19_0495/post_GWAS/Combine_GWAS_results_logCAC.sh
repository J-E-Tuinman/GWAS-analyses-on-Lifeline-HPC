#!/bin/bash
#SBATCH --job-name=GWAS_result_compression
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --tmp=40GB
#SBATCH --cpus-per-task=2
#SBATCH --output=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/scripts/logs/GWAS_compression_logCAC.log
#SBATCH --error=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/scripts/logs/GWAS_compression_logCAC.err
#SBATCH --time=04:00:00


# Set paths
WORKDIR=/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/DATA-regenie2/
TMPDIR=${TMPDIR:-/scratch}

cd $TMPDIR

# Copy files to TMPDIR
cp $WORKDIR/DATA-logCAC-chr*_part*_logCAC.regenie.gz .

# Merging seperate regenie step 2 result outputs into 1 summary statistics file
zcat DATA-logCAC-chr1_part1_logCAC.regenie.gz | head -n 1 > DATA-logCAC-all.regenie
for chr in {1..22}; do
  for part in {1..10}; do
    zcat DATA-logCAC-chr${chr}_part${part}_logCAC.regenie.gz | tail -n +2 >> DATA-logCAC-all.regenie
  done
done
# Compress and move back
gzip DATA-logCAC-all.regenie
mv DATA-logCAC-all.regenie.gz $WORKDIR/

echo "Done: $(date)"

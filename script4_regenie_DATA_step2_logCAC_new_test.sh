#!/usr/bin/env bash
#SBATCH --job-name=regenie_merge
#SBATCH --time=48:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4

set -euo pipefail

module load PLINK/2.0-alpha6.20-20250707
module load BCFtools/1.22-GCCcore-13.3.0
module load regenie

# Paths
WORKDIR="/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output"
BGEN_DIR="/groups/umcg-lifelines/tmp02/projects/ov19_0495/3_Round2_Imputed_Genotypes_cleaned/BGEN"
TMP_DIR="${TMPDIR:-/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/tmp}"
SAMPLE_FILE="${BGEN_DIR}/UGLI0to3.sample"

mkdir -p "$TMP_DIR"
cd "$WORKDIR"

for CHR in $(seq 1 2); do
    echo "=== Chromosome ${CHR} ==="
    PARTS=$(ls ${BGEN_DIR}/chr_${CHR}_part*_UGLI0to3.bgen 2>/dev/null | sort -V)
    if [ -z "$PARTS" ]; then
        echo "No BGEN files for chr${CHR}, skipping."
        continue
    fi

    echo "Converting BGEN ? VCF for chr${CHR}"
    for f in $PARTS; do
        base=$(basename "$f" .bgen)
        plink2 \
          --bgen "$f" ref-first \
          --sample "$SAMPLE_FILE" \
          --export vcf bgz \
          --out "${TMP_DIR}/${base}"
    done

    echo "Concatenating VCFs for chr${CHR}"
    MERGED_VCF="${TMP_DIR}/chr_${CHR}_merged.vcf.gz"
    bcftools concat -Oz -o "$MERGED_VCF" ${TMP_DIR}/chr_${CHR}_part*_UGLI0to3.vcf.gz
    bcftools index "$MERGED_VCF"

    echo "Converting merged VCF ? BGEN for chr${CHR}"
    MERGED_BGEN="${TMP_DIR}/chr_${CHR}_merged.bgen"
    plink2 \
      --vcf "$MERGED_VCF" bgz \
      --make-bgen \
      --out "${TMP_DIR}/chr_${CHR}_merged"

    echo "Running Regenie step 2 for chr${CHR}"
    regenie \
      --step 2 \
      --bgen "${MERGED_BGEN}" \
      --sample "$SAMPLE_FILE" \
      --phenoFile dataF_data_logCAC.txt \
      --phenoCol logCAC \
      --covarFile dataF_data_logCAC.txt \
      --covarColList age,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
      --catCovarList gender \
      --pred DATA-regenie1/logCAC_pred.list \
      --bsize 400 \
      --minINFO 0.3 \
      --minMAC 2 \
      --threads 4 \
      --maxCatLevels 99 \
      --write-samples \
      --print-pheno \
      --gz \
      --out DATA-regenie2/DATA-logCAC-chr${CHR}

    echo "Cleaning temporary files for chr${CHR}"
    rm -f ${TMP_DIR}/chr_${CHR}_part*_UGLI0to3.vcf.gz* \
          "$MERGED_VCF" \
          "${MERGED_BGEN}"* 
done

echo "All chromosomes complete."

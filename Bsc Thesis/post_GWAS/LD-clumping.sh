#!/bin/bash
#SBATCH --job-name=LDclump_tmp
#SBATCH --output=LDclump_tmp_%A.out
#SBATCH --error=LDclump_tmp_%A.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --nodes=1

###############################################
# MODULES
###############################################
module purge
module load PLINK/2.0-alpha6.20-20250707

###############################################
# USER SETTINGS
###############################################

# Directory with 10-part-per-chromosome imputed data
IMPUTE_DIR="/imputed/BGEN"

# Prefix of imputed files like: chr1_part1.bgen / chr1_part1.sample
PREFIX="chr_"

# Clumping input (prepared summary stats)
CLUMPFILE="/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/annotation/logCAC_all.forclump"

# Final output directory (results only)
OUTDIR="/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/output/annotation/LD_clump_results"
mkdir -p "${OUTDIR}"

###############################################
# TMPDIR SETUP
###############################################

TMPDIR=$(mktemp -d /tmp/LDclump_${SLURM_JOBID}_XXXX)
echo "Using temporary directory: ${TMPDIR}"

# Auto-cleanup when the script ends for ANY reason
cleanup() {
    echo "Cleaning temporary directory ${TMPDIR}"
    rm -rf "${TMPDIR}"
}
trap cleanup EXIT

###############################################
# STEP 1 — Create 20k individual subset (once)
###############################################

echo "Creating 20k individual subset..."

# Extract sample IDs from chromosome 1 part 1
awk 'NR>2 {print $1, $2}' "${IMPUTE_DIR}/sample_file" \
    > "${TMPDIR}/all_ids.txt"

# Random subset of 20k individuals
shuf "${TMPDIR}/all_ids.txt" | head -20000 > "${TMPDIR}/keep20k.ids"

echo "Subset ready: ${TMPDIR}/keep20k.ids"

###############################################
# STEP 2 — PROCESS EACH CHROMOSOME
###############################################

for CHR in 16; do
    echo "=== Processing chromosome ${CHR} ==="

    ###################################################
    # 2A. Convert 10 imputed parts to PLINK2 pfiles
    ###################################################

    for PART in {1..10}; do
        IN_BGEN="${IMPUTE_DIR}/${PREFIX}${CHR}_part${PART}.bgen"
        IN_SAMPLE="${IMPUTE_DIR}/.sample"

        if [ ! -f "${IN_BGEN}" ]; then
            echo "WARNING: Missing file ${IN_BGEN}"
            continue
        fi

        plink2 \
            --bgen "${IN_BGEN}" ref-first \
            --sample "${IN_SAMPLE}" \
            --make-pgen \
            --threads 2 \
            --out "${TMPDIR}/chr${CHR}_part${PART}"
    done
    
    for f in chr6_part*.psam; do
    echo "$f: $(wc -l < $f)";
done

    ###################################################
    # 2B. Merge the 10 pfiles → one chr-level pfile
    ###################################################

    ls "${TMPDIR}/chr${CHR}_part"*.pgen | sed 's/.pgen//' \
        > "${TMPDIR}/chr${CHR}_pmerge_list_raw.txt"

    BASE="${TMPDIR}/chr${CHR}_part1"
    grep -v "chr${CHR}_part1" \
        "${TMPDIR}/chr${CHR}_pmerge_list_raw.txt" \
        > "${TMPDIR}/chr${CHR}_pmerge_list.txt"

    plink2 \
        --pfile "${BASE}" \
        --pmerge-list "${TMPDIR}/chr${CHR}_pmerge_list.txt" \
        --make-pgen \
        --threads 2 \
        --out "${TMPDIR}/chr${CHR}_all_imputed"

    ###################################################
    # 2C. Create 20k subset reference for LD
    ###################################################

    plink2 \
        --pfile "${TMPDIR}/chr${CHR}_all_imputed" \
        --keep "${TMPDIR}/keep20k.ids" \
        --make-pgen \
        --threads 2 \
        --out "${TMPDIR}/chr${CHR}_all_imputed_20k"

    ###################################################
    # 2D. Filter summary stats to chromosome
    ###################################################

    awk -v C=${CHR} 'NR==1 || $1==C' "${CLUMPFILE}" \
        > "${TMPDIR}/chr${CHR}.forclump"

    ###################################################
    # 2E. LD CLUMPING
    ###################################################

    plink2 \
        --pfile "${TMPDIR}/chr${CHR}_all_imputed_20k" \
        --clump "${TMPDIR}/chr${CHR}.forclump" \
        --clump-field P \
        --clump-p1 5e-8 \
        --clump-p2 5e-7 \
        --clump-r2 0.1 \
        --clump-kb 250 \
        --threads 2 \
        --out "${TMPDIR}/chr${CHR}_clump"

    # Copy clump results to OUTDIR
    cp "${TMPDIR}/chr${CHR}_clump.clumps" "${OUTDIR}/"

done

###############################################
# STEP 3 — COLLECT ALL LEAD SNPs
###############################################

echo "Collecting genome-wide lead SNPs..."

> "${OUTDIR}/lead_snps.txt"

for CHR in 16; do
    CLUMPFILE_CHR="${OUTDIR}/chr${CHR}_clump.clumps"
    if [ -f "${CLUMPFILE_CHR}" ]; then
        awk 'NR>1 {print $3}' "${CLUMPFILE_CHR}" >> "${OUTDIR}/lead_snps_${CHR}.txt"
    fi
done

echo "Lead SNP list written to: ${OUTDIR}/lead_snps.txt"
echo "Script completed successfully. Temporary files removed."

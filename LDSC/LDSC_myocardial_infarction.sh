#!/bin/bash
#SBATCH --job-name=LDSC_myocardial_infarction
#SBATCH --time=04:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --output=ldsc_%j.out
#SBATCH --error=ldsc_%j.err


################################################################################
# FILE PATHS
################################################################################

# LDSC installation directory (contains ldsc/ folder with ldscore package)
LDSC_DIR="/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/python_ldsc_env/ldsc"
export PYTHONPATH="$LDSC_DIR:$PYTHONPATH"

FILE1="/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/references/ldsc/logCAC.ldsc.txt"
FILE2="/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/references/ldsc/Myocardial_Infarction_fixed_clean.ldsc.txt"
# Reference files (eur_w_ld_chr + w_hm3.snplist)
REFDIR="/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/references/ldsc"

OUTDIR="/groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/ldsc_output/"

################################################################################
# 1. load modules
################################################################################
module purge
module load Python/3.10.4-GCCcore-11.3.0
module load Anaconda3

# activate your venv
source /apps/software/Anaconda3/2024.02-1/etc/profile.d/conda.sh
conda activate ldsc

# ensure LDSC package is visible
export PYTHONPATH=$LDSC_DIR:$PYTHONPATH

echo "Python version:"
python --version


################################################################################
# 2. Move everything to TMPDIR and load environment
################################################################################


cp $FILE1 $TMPDIR/
cp $FILE1 $TMPDIR/
cp $REFDIR/w_hm3.snplist $TMPDIR/

mkdir $TMPDIR/eur_w_ld_chr
cp $REFDIR/eur_w_ld_chr/* $TMPDIR/eur_w_ld_chr/

cd $TMPDIR



################################################################################
# 4. Munge (harmonize) both phenotypes
################################################################################
#Make sure the files contain at least (bare minimum) the following columns: SNP (rsID), A1, A2, P
echo "Munging (harmonizing)..."

python $LDSC_DIR/munge_sumstats.py \
    --sumstats $FILE1 \
    --snp SNP \
    --a1 A1 \
    --a2 A2 \
    --p P \
    --N-col N \
    --merge-alleles w_hm3.snplist \
    --chunksize 500000 \
    --out logCAC.clean

python $LDSC_DIR/munge_sumstats.py \
    --sumstats $FILE2 \
    --snp SNP \
    --a1 A1 \
    --a2 A2 \
    --p P \
    --N-col N \
    --merge-alleles w_hm3.snplist \
    --chunksize 500000 \
    --out myocardial_infarction.clean

############################################################
# HERITABILITY
############################################################

echo "Running h2 for logCAC..."

python $LDSC_DIR/ldsc.py \
    --h2 logCAC.clean.sumstats.gz \
    --ref-ld-chr eur_w_ld_chr/ \
    --w-ld-chr  eur_w_ld_chr/ \
    --out logCAC_h2

echo "Running h2 for INTCAC..."

python $LDSC_DIR/ldsc.py \
    --h2 myocardial_infarction.clean.sumstats.gz \
    --ref-ld-chr eur_w_ld_chr/ \
    --w-ld-chr  eur_w_ld_chr/ \
    --out myocardial_infarction_h2

############################################################
# GENETIC CORRELATION
############################################################

echo "Running genetic correlation logCAC <-> INTCAC..."

python $LDSC_DIR/ldsc.py \
    --rg logCAC.clean.sumstats.gz,myocardial_infarction.clean.sumstats.gz \
    --ref-ld-chr eur_w_ld_chr/ \
    --w-ld-chr eur_w_ld_chr/ \
    --out log_vs_myocardial_infarction_rg

############################################################
# SAVE OUTPUT
############################################################

mkdir -p $OUTDIR
cp logCAC_h2* $OUTDIR/
cp myocardial_infarction_h2* $OUTDIR/
cp log_vs_myocardial_infarction_rg* $OUTDIR/
cp logCAC.clean.sumstats.gz $OUTDIR/
cp myocardial_infarction.clean.sumstats.gz $OUTDIR/
cp $FILE1 $OUTDIR/
cp $FILE2 $OUTDIR/

echo "DONE."

################################################################################
# 7. Cleanup
################################################################################

echo "LDSC pipeline completed."
conda deactivate

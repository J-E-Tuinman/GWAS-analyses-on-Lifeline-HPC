#!/bin/bash
#SBATCH --time=00:02:00
#SBATCH --nodes=1
#SBATCH --partition=short
#SBATCH --job-name=batch

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/scripts
cat script3_template_regenie1_INTCAC.sh | sed "s/DATA/DATA/g;s/PHENO/INT_CAC/g"  > tempL3_DATA_INTCAC.sh

sbatch tempL3_DATA_INTCAC.sh

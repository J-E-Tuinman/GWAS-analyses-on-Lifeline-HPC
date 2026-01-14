#!/bin/bash
#SBATCH --time=00:02:00
#SBATCH --nodes=1
#SBATCH --partition=short
#SBATCH --job-name=batch

cd /groups/umcg-lifelines/tmp02/projects/ov23_0782/jtuinman/UGLI0-3/scripts/
# changing lines in 'script3_template_regenie1.sh' for easy reuse for different Datasets and phenotypes
cat script3_template_regenie1.sh | sed "s/DATA/GSA/g;s/PHENO/logCAC/g"  > tempL3_GSA_logCAC.sh
cat script3_template_regenie1.sh | sed "s/DATA/CS/g;s/PHENO/logCAC/g"  > tempL3_CS_logCAC.sh
cat script3_template_regenie1.sh | sed "s/DATA/AFFY/g;s/PHENO/logCAC/g"  > tempL3_AFFY_logCAC.sh

sbatch tempL3_GSA_logCAC.sh
sbatch tempL3_CS_logCAC.sh
sbatch tempL3_AFFY_logCAC.sh


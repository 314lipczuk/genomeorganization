#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=20
#SBATCH --job-name=Visualize_TE
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail


# TODO: load the IBU module instead
module load R-bundle-CRAN/2023.11-foss-2021a
module load SAMtools/1.13-GCC-10.3.0

ANNOTATION_DIR="$RESULTDIR/EDTA_annotation"
cd $ANNOTATION_DIR

samtools faidx 



# For cicumsision one, look up the new script they uploaded today

# NOTE:
# do all TIRs, no helitron


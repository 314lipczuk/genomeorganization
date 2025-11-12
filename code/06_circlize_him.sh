#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=20
#SBATCH --job-name=Circlize_him
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

module load R-bundle-IBU/2023072800-foss-2021a-R-4.2.1 # works for circlize
module load SAMtools/1.13-GCC-10.3.0

Rscript code/circlize_me.R 
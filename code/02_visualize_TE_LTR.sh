#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=20
#SBATCH --job-name=Visualize_TE_LTR
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

#module load R/4.3.2-foss-2021a
module load R-bundle-CRAN/2023.11-foss-2021a

set -e

ANNOTATION_DIR="$RESULTDIR/EDTA_annotation"
TE_sort="$RESULTDIR/TE_sorter"
mkdir -p $TE_sort
cd $TE_sort

apptainer exec --bind /data /data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif TEsorter \
  "$ANNOTATION_DIR/assembly_primary_contig.fa.mod.EDTA.raw/assembly_primary_contig.fa.mod.LTR.raw.fa" -db rexdb-plant

Rscript "$CODEDIR/plot_LTR_clades.R" 


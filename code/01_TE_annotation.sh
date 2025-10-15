#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=20
#SBATCH --job-name=TE_Annotation
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

ANNOTATION_DIR="$RESULTDIR/EDTA_annotation"
mkdir -p $ANNOTATION_DIR
cd $ANNOTATION_DIR

apptainer exec \
--bind /data \
  /data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif \
  EDTA.pl \
  --genome $ASSEMBLY_PATH \
  --species others \
  --step all \
  --sensitive 1 \
  --cds "$BASEDIR/data/TAIR10_cds_20110103_representative_gene_model_updated" \
  --anno 1 \
  --threads 20
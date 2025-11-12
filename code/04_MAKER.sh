#!/bin/bash
#SBATCH --time=7-00
#SBATCH --mem=6g
#SBATCH --cpus-per-task=2
#SBATCH --job-name=MAKER_prep
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

ANNOTATION_DIR="$RESULTDIR/ANNOTATION"

# TODO: change this after my EDTA runs
EDTA_RES_PATH="/data/courses/assembly-annotation-course/CDS_annotation/example_EDTA_data/edta_annotation"
genome="assembly"
set -e
mkdir -p "$ANNOTATION_DIR"
cd "$ANNOTATION_DIR"
pwd

apptainer exec --bind /data \
  --bind "$ANNOTATION_DIR":"$ANNOTATION_DIR" \
  /data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif \
  maker -CTL

FILE="$ANNOTATION_DIR/maker_opts.ctl"
cat > "$FILE" <<- EOM
#-----Genome (these are always required)
genome=$ASSEMBLY_PATH
#genome sequence (fasta file or fasta embeded in GFF3 file)
#-----EST Evidence (for best results provide a file for at least one)
est=$TRANSCRIPTOME_PATH
#set of ESTs or assembled mRNA-seq in fasta format. Use this for evidence based gene prediction
#-----Protein Homology Evidence (for best results provide a file for at least one)
protein=/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10.fa,/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa
#protein sequence file in fasta format (i.e. from mutiple organisms). Use this for evidence based gene prediction
#-----Repeat Masking (leave values blank to skip repeat masking)
model_org=
#select a model organism for DFam masking in RepeatMasker **IMPORTANT!** switch if off
rmlib=$EDTA_RES_PATH/$genome.mod.EDTA.TElib.fa
#provide an organism specific repeat library in fasta format for RepeatMasker

repeat_protein=/data/courses/assembly-annotation-course/CDS_annotation/data/PTREP20
#provide a fasta file of transposable element proteins for RepeatRunner

#-----Gene Prediction
augustus_species=arabidopsis
#Augustus gene prediction species model, for ab-initio gene prediction
est2genome=1 
#infer gene predictions directly from ESTs, 1 = yes, 0 =no
protein2genome=1
#infer predictions from protein homology, 1 = yes, 0= no
#-----External Application Behavior Options
cpus=1 
#max number of cpus to use in BLAST and RepeatMasker. We will run MAKER with MPI, so here we set it to 1
#-----MAKER Behavior Options
alt_splice=1
#Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
EOM


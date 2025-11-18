#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH --job-name=GENESPACE_prep
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

set -euo pipefail

# ---------------------------------------------------------
# Environment & paths
# ---------------------------------------------------------

cd "$RESULTDIR/GFF/final"
ACCESSION="Mh-0"  
GENESPACE_DIR="$RESULTDIR/GENESPACE"
mkdir -p "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide"

# Input files
#GFF="filtered.genes.Uniprot.gff3"         # or filtered.genes.renamed.gff3 if Step09 not run
#PROT="protein.filtered.Uniprot.fasta"     # or protein.renamed.filtered.fasta
GFF="filtered.genes.renamed.gff3"
#PROT="results/GFF/final/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
PROT="results/GFF/final/protein.longest_per_gene.fasta"


grep -P "\tgene\t" $GFF > temp_genes.gff3
awk 'BEGIN{OFS="\t"} {split($9,a,";"); split(a[1],b,"="); print $1, $4-1, $5, b[2]}' \
  temp_genes.gff3 > $GENESPACE_DIR/bed/${ACCESSION}.bed

cp $BASEDIR/$PROT $GENESPACE_DIR/peptide/${ACCESSION}.fa

ACCESSION="Taz-0"  
GFF="/data/courses/assembly-annotation-course/CDS_annotation/data/Lian_et_al/gene_gff/selected/Taz-0.EVM.v3.5.ann.protein_coding_genes.gff"
PROT="/data/courses/assembly-annotation-course/CDS_annotation/data/Lian_et_al/protein/selected/Taz-0.protein.faa"

grep -P "\tgene\t" $GFF > temp_genes.gff3
awk 'BEGIN{OFS="\t"} {split($9,a,";"); split(a[1],b,"="); print $1, $4-1, $5, b[2]}' \
  temp_genes.gff3 > $GENESPACE_DIR/bed/${ACCESSION}.bed

cp $PROT $GENESPACE_DIR/peptide/${ACCESSION}.fa

ACCESSION="Kar-1"  
GFF="/data/courses/assembly-annotation-course/CDS_annotation/data/Lian_et_al/gene_gff/selected/Kar-1.EVM.v3.5.ann.protein_coding_genes.gff"
PROT="/data/courses/assembly-annotation-course/CDS_annotation/data/Lian_et_al/protein/selected/Kar-1.protein.faa"

grep -P "\tgene\t" $GFF > temp_genes.gff3
awk 'BEGIN{OFS="\t"} {split($9,a,";"); split(a[1],b,"="); print $1, $4-1, $5, b[2]}' \
  temp_genes.gff3 > $GENESPACE_DIR/bed/${ACCESSION}.bed
cp $PROT $GENESPACE_DIR/peptide/${ACCESSION}.fa

cp /data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10.bed  $GENESPACE_DIR/bed/TAIR10.bed  
cp /data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10.fa $GENESPACE_DIR/peptide/TAIR10.fa
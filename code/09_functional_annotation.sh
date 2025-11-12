#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=12
#SBATCH --job-name=Functional_Annot
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

set -euo pipefail

# ---------------------------------------------------------------
# Load modules
# ---------------------------------------------------------------
module load BLAST+/2.15.0-gompi-2021a

# ---------------------------------------------------------------
# Define directories and paths
# ---------------------------------------------------------------
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"
cd "$RESULTDIR/GFF/final"

# Inputs
PROT="protein.longest_per_gene.fasta"
GFF="filtered.genes.renamed.gff3"

# Create local database directory
mkdir -p "$RESULTDIR/databases"

# Source FASTA locations (read-only course data)
COURSE_UNIPROT="$COURSEDIR/data/uniprot/uniprot_viridiplantae_reviewed.fa"
COURSE_TAIR="$COURSEDIR/data/TAIR10.fa"

# Local writable copies
UNIPROT_DB="$RESULTDIR/databases/uniprot_viridiplantae_reviewed.fa"
TAIR_DB="$RESULTDIR/databases/TAIR10.fa"

# ---------------------------------------------------------------
# Step 0. Copy databases locally if needed (to avoid permission errors)
# ---------------------------------------------------------------
if [ ! -f "$UNIPROT_DB" ]; then
  echo "Copying UniProt database to local directory..."
  cp "$COURSE_UNIPROT" "$UNIPROT_DB"
fi

if [ ! -f "$TAIR_DB" ]; then
  echo "Copying TAIR10 database to local directory..."
  cp "$COURSE_TAIR" "$TAIR_DB"
fi

# ---------------------------------------------------------------
# Step 1. Ensure BLAST databases are indexed
# ---------------------------------------------------------------
if [ ! -f "${UNIPROT_DB}.pin" ]; then
  echo "Indexing UniProt database..."
  makeblastdb -in "$UNIPROT_DB" -dbtype prot -title "uniprot_viridiplantae_reviewed"
else
  echo "UniProt BLAST database already indexed."
fi

if [ ! -f "${TAIR_DB}.pin" ]; then
  echo "Indexing TAIR10 database..."
  makeblastdb -in "$TAIR_DB" -dbtype prot -title "TAIR10_protein_DB"
else
  echo "TAIR10 BLAST database already indexed."
fi

# ---------------------------------------------------------------
# Step 2. BLASTp vs UniProt (reviewed viridiplantae)
# ---------------------------------------------------------------
echo ">>> Running BLASTp vs UniProt..."
blastp -query "$PROT" \
  -db "$UNIPROT_DB" \
  -num_threads $SLURM_CPUS_PER_TASK \
  -outfmt 6 -evalue 1e-5 -max_target_seqs 10 \
  -out blastp_uniprot.tsv

# Keep best hit per query
sort -k1,1 -k12,12g blastp_uniprot.tsv | sort -u -k1,1 --merge > blastp_uniprot.besthits

# Annotate FASTA and GFF
$MAKERBIN/maker_functional_fasta "$UNIPROT_DB" blastp_uniprot.besthits "$PROT" \
  > protein.filtered.Uniprot.fasta
$MAKERBIN/maker_functional_gff "$UNIPROT_DB" blastp_uniprot.besthits "$GFF" \
  > filtered.genes.Uniprot.gff3

# ---------------------------------------------------------------
# Step 3. BLASTp vs TAIR10 (optional comparison)
# ---------------------------------------------------------------
echo ">>> Running BLASTp vs TAIR10..."
blastp -query "$PROT" \
  -db "$TAIR_DB" \
  -num_threads $SLURM_CPUS_PER_TASK \
  -outfmt 6 -evalue 1e-5 -max_target_seqs 10 \
  -out blastp_tair10.tsv

sort -k1,1 -k12,12g blastp_tair10.tsv | sort -u -k1,1 --merge > blastp_tair10.besthits

$MAKERBIN/maker_functional_fasta "$TAIR_DB" blastp_tair10.besthits "$PROT" \
  > protein.filtered.TAIR10.fasta
$MAKERBIN/maker_functional_gff "$TAIR_DB" blastp_tair10.besthits "$GFF" \
  > filtered.genes.TAIR10.gff3

# ---------------------------------------------------------------
# Step 4. Completion summary
# ---------------------------------------------------------------
echo ">>> Functional annotation completed successfully."
echo "Outputs generated in $RESULTDIR/GFF/final:"
ls -lh *.besthits *.fasta *.gff3

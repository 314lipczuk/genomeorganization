#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=2
#SBATCH --job-name=extract_longest_isoform
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

set -euo pipefail

# ------------------------------------------------------------
# Step 07b – Extract longest isoform per gene from MAKER output
# ------------------------------------------------------------

cd "$RESULTDIR/GFF/final"

module load SeqKit/2.6.1

PROT="assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
TRANS="assembly.all.maker.transcripts.fasta.renamed.filtered.fasta"

echo ">>> Extracting longest isoform per gene..."
# For each gene (prefix before -R#), retain the longest sequence
seqkit fx2tab "$PROT" \
| awk -F'\t' '{len=length($2); split($1,a,"-R"); gene=a[1]; if(len>max[gene]){max[gene]=len; seq[gene]=$0}} END{for(i in seq) print seq[i]}' \
| seqkit tab2fx > protein.longest_per_gene.fasta

seqkit fx2tab "$TRANS" \
| awk -F'\t' '{len=length($2); split($1,a,"-R"); gene=a[1]; if(len>max[gene]){max[gene]=len; seq[gene]=$0}} END{for(i in seq) print seq[i]}' \
| seqkit tab2fx > transcript.longest_per_gene.fasta

echo ">>> Done. Longest isoforms saved:"
ls -lh protein.longest_per_gene.fasta transcript.longest_per_gene.fasta


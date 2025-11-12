#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --job-name=BUSCO
#SBATCH --cpus-per-task=20
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

set -e

cd "$RESULTDIR/GFF/final"

#PROTEIN="assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
PROTEIN="protein.longest_per_gene.fasta"

module load BUSCO/5.4.2-foss-2021a
mkdir -p "$RESULTDIR/busco_output"
busco \
  -f \
  -i "$PROTEIN" \
  -l brassicales_odb10 \
  -o "$RESULTDIR/busco_output" \
  -m proteins \
  --cpu "$SLURM_CPUS_PER_TASK"

module load AGAT/1.0.0-foss-2021a

mkdir -p "$RESULTDIR/agat"
agat_sp_statistics.pl -i filtered.genes.renamed.gff3 -o "$RESULTDIR/agat/annotation_stats.txt"
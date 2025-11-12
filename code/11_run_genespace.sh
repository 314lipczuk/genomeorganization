#!/bin/bash
#SBATCH --time=1-00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=GENESPACE
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# Load R with GENESPACE dependencies
#module load R-bundle-Bioconductor/2023.11-foss-2021a-R-4.3.2
#module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.


# Optional: if GENESPACE is installed in a container instead
# apptainer exec --bind /data /data/courses/assembly-annotation-course/CDS_annotation/containers/GENESPACE_latest.sif \
#   Rscript code/11_genespace_run.R

# Run directly (module mode)
#Rscript $BASEDIR/code/Genespace.R

CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/genespace_latest.sif"
genespaceR="$BASEDIR/code/Genespace.R"
cd $RESULTDIR/GENESPACE
cd bed
# Replace ":" with "_" in both GFF and FASTA files
sed -i 's/:/_/g' *.bed
for f in *-*; do mv "$f" "${f//-/_}"; done
cd ../peptide
sed -i 's/:/_/g' *.fa
for f in *-*; do mv "$f" "${f//-/_}"; done
#sed -i 's/-RA.*$//g' Mh_0.fa
#sed -i 's/-RB.*$//g' Mh_0.fa
#sed -i 's/-RC.*$//g' Mh_0.fa
#sed -i 's/-RD.*$//g' Mh_0.fa
#sed -i 's/-RE.*$//g' Mh_0.fa
#sed -i 's/-RF.*$//g' Mh_0.fa
#sed -i 's/-RH.*$//g' Mh_0.fa
sed -i 's/-R.*$//g' Mh_0.fa
cd ..

apptainer exec --bind /data --bind $SCRATCH:/temp $CONTAINER Rscript $genespaceR 
#!/bin/bash
#SBATCH --time=7-0
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --job-name=MAKER
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

ANNOTATION_DIR="$RESULTDIR/ANNOTATION"

# TODO: change this after my EDTA runs
#EDTA_RES_PATH="/data/courses/assembly-annotation-course/CDS_annotation/example_EDTA_data/edta_annotation"

set -e

mkdir -p "$ANNOTATION_DIR"
cd "$ANNOTATION_DIR"

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"
module load OpenMPI/4.1.1-GCC-10.3.0
module load AUGUSTUS/3.4.0-foss-2021a

mpiexec --oversubscribe -n 50 apptainer exec \
  --bind /data \
  --bind "$ANNOTATION_DIR":"$ANNOTATION_DIR" \
  ${COURSEDIR}/containers/MAKER_3.01.03.sif \
  maker -mpi --ignore_nfs_tmp -TMP "$SCRATCH" maker_opts.ctl maker_bopts.ctl \
  maker_evm.ctl maker_exe.ctl

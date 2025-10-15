#!/bin/bash
export BASEDIR="/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes"
export CODEDIR="$BASEDIR/code"
export DATADIR="$BASEDIR/data"
export LOGDIR="$BASEDIR/logs"
export RESULTDIR="$BASEDIR/results"
export ASSEMBLY_PATH="/data/users/ppilipczuk/GenomeAndTransAss/results/hifiasm/assembly_primary_contig.fa"
echo "sourced config.sh"

mkdir -p "$LOGDIR"
mkdir -p "$RESULTDIR"
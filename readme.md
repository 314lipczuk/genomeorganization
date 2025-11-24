# Genome Annotation Workflow

This repository holds Slurm job scripts and R helpers to annotate, assess, and compare a plant genome assembly.

## Entrypoint
`run.sh` sources `code/00_setup.sh` to set paths, timestamps log files, runs `shellcheck` on the target script, and submits the job to Slurm with `sbatch` using standardized log names.

## Usage Notes
Run `run.sh <script>` to submit any of the job scripts, and adjust the hardcoded paths and module loads to your cluster before running.

## Steps in `code/`
- `code/00_setup.sh`: exports base, code, data, log, and result directories plus assembly/transcript paths, then creates the log and result folders.
- `code/01_TE_annotation.sh`: runs EDTA in a container to annotate transposable elements on the assembly with supplied CDS evidence.
- `code/02_visualize_TE_LTR.sh`: classifies LTR elements with TEsorter and runs `plot_LTR_clades.R` to visualize clade-level identities.
- `code/03_visualize_TE.sh`: loads R and samtools and starts preparing TE visualization (script currently a placeholder after `samtools faidx`).
- `code/04_MAKER.sh`: generates MAKER control files with genome, transcript, protein, and repeat library inputs for downstream runs.
- `code/05_MAKER_RUN.sh`: launches MAKER via MPI inside the container, binding data paths and writing outputs in the annotation directory.
- `code/06_circlize_him.sh`: loads R dependencies and executes `circlize_me.R` to draw circular TE density plots.
- `code/07_merge_gff_filter_and_refine.sh`: merges MAKER outputs, renames IDs, runs InterProScan, filters annotations, and extracts matching protein/transcript FASTA files.
- `code/07b_extract_longest_isoform.sh`: keeps the longest isoform per gene from the filtered protein and transcript FASTA files using seqkit and awk.
- `code/08_busco.sh`: runs BUSCO on the protein set and reports annotation statistics with AGAT.
- `code/09_functional_annotation.sh`: builds local BLAST databases, runs BLASTp against UniProt and TAIR10, and writes functional annotations back to FASTA and GFF files.
- `code/10_genespace_prep.sh`: prepares BED and peptide files for GENESPACE by extracting gene intervals and copying peptide FASTA for the assembly and reference accessions.
- `code/11_run_genespace.sh`: cleans BED/FA headers and runs GENESPACE via the container to compute orthology and pangenome outputs defined in `Genespace.R`.
- `code/Genespace.R`: configures GENESPACE directories, runs the pipeline, saves a pangenome matrix, and counts core and lineage-specific genes.
- `code/circlize_me.R`: reads TE and gene annotations, ensures a FASTA index exists, and produces genome-wide circular TE density plots.
- `code/div.R`: loads the EDTA divergence landscape table, reshapes superfamily counts, and plots transposable element divergence in Mbp.
- `code/plot_LTR_clades.R`: merges LTR identity metrics with TEsorter classifications and plots identity distributions by Copia and Gypsy clades.
- `code/visualize_TE_annotations.R`: placeholder R script that currently reads a TE annotation GFF file for future plotting.

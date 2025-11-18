#!/usr/bin/env Rscript

# -------------------------------------------------------------
# Step 11 - Run GENESPACE Orthology and Synteny analysis
# Author: ppilipczuk
# -------------------------------------------------------------

library(GENESPACE)

# --- Paths ----------------------------------------------------
BASEDIR <- "/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes"
RESULTDIR <- file.path(BASEDIR, "results")
GENESPACE_DIR <- file.path(RESULTDIR, "GENESPACE")
BEDDIR <- file.path(GENESPACE_DIR, "bed")
PEPDIR <- file.path(GENESPACE_DIR, "peptide")

# --- Species configuration ------------------------------------
# Replace "PPI1" with your accession ID from step 10
# Add TAIR10 as reference (the course provides it)
wd <- GENESPACE_DIR
#gsConfig <- makeGsConfig(
#  wd = wd,
#  # Order defines how plots will be arranged
#  genomeIDs = c("TAIR10", "PPI1"),
#  # Names of each genome in figures
#  outgroupIDs = "TAIR10",
#  geneIDs = list(
#    TAIR10 = file.path(BEDDIR, "TAIR10.bed"),
#    PPI1   = file.path(BEDDIR, "PPI1.bed")
#  ),
#  pepPaths = list(
#    TAIR10 = file.path(PEPDIR, "TAIR10.fa"),
#    PPI1   = file.path(PEPDIR, "PPI1.fa")
#  ),
#  orgPaths = NULL,
#  orthofinderVersion = "2.5.4"
#)
#library(GENESPACE)

wd <- "/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes/results/GENESPACE"

gpar <- init_genespace(
  wd = wd,
  genomeIDs = c("TAIR10","Mh_0", "Taz_0", "Kar_1"),
  path2mcscanx = "/usr/local/bin"
)

#check_annotFiles(filepath = gpar$wd, genomeIDs = gpar$genomeIDs)
out <- run_genespace(gpar, overwrite = TRUE)

pangenome <- query_pangenes(out, bed = NULL, refGenome = "TAIR10", transform = TRUE, showArrayMem = TRUE, showNSOrtho = TRUE, maxMem2Show = Inf)
# save pangenome object as rds
saveRDS(pangenome, file = file.path(wd, "pangenome_matrix.rds"))
# --- Run GENESPACE --------------------------------------------
#message(">>> Running GENESPACE orthology pipeline ...")
#gs <- run_genespace(gsConfig)

pg <- pangenome$pangenes

# columns representing your genomes (depends on naming)
genomes <- c("TAIR10", "Taz_0", "Kar_1", "Mh_0")   # example

# count OGs present in all genomes
core_rows <- pangenome[
  rowSums(sapply(pangenome[, ..genomes], function(x) lengths(x) > 0)) == length(genomes)
]
n_core <- nrow(core_rows)
core_genes_mh0 <- sum(lengths(core_rows$Mh_0))
all_genes_mh0 <- sum(lengths(pangenome$Mh_0))
print("core mh0")
print(core_genes_mh0)

print("core genes in pan")
print(n_core)

mh0_specific_rows <- pangenome[
  lengths(pangenome$Mh_0) > 0 &
  lengths(pangenome$TAIR10) == 0 &
  lengths(pangenome$Taz_0) == 0 &
  lengths(pangenome$Kar_1) == 0
]

print("mh0_specific_rows")
print(mh0_specific_rows )

# --- Plots & summary ------------------------------------------
#message(">>> Generating synteny plots ...")
#plot_rawHits(gs, n = 100)
#plot_syntenicHits(gs)
#plot_pangenomeMatrix(gs)
#
#message(">>> GENESPACE run complete. Results written to:")
#print(gsConfig$wd)

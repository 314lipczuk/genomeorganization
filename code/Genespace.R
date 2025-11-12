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

print("abc")
#check_annotFiles(filepath = gpar$wd, genomeIDs = gpar$genomeIDs)
gs <- run_genespace(gpar, overwrite = TRUE)

# --- Run GENESPACE --------------------------------------------
#message(">>> Running GENESPACE orthology pipeline ...")
#gs <- run_genespace(gsConfig)

# --- Plots & summary ------------------------------------------
message(">>> Generating synteny plots ...")
plot_rawHits(gs, n = 100)
plot_syntenicHits(gs)
plot_pangenomeMatrix(gs)

message(">>> GENESPACE run complete. Results written to:")
print(gsConfig$wd)

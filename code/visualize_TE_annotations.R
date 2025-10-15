
library(tidyverse)
library(data.table)
library(cowplot)
library(circlize)

setwd("data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes/results/EDTA_annotation/assembly_primary_contig.fa.mod.EDTA.raw")
gff_file <- "assembly_primary_contig.fna.mod.LTR.intact.raw.gff3"
message("Reading GFF: ", gff_file)
anno <- read.table(gff_file, sep = "\t", header = FALSE)



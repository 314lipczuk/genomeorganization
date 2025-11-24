## Load the circlize package
#library(circlize)
#library(tidyverse)
#library(ComplexHeatmap)
#
#gff_file <- "/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes/results/EDTA_annotation/assembly_primary_contig.fa.mod.EDTA.TEanno.gff3"
#fai_file <- "/data/users/ppilipczuk/GenomeAndTransAss/results/hifiasm/assembly_primary_contig.fa.fai"
#
## Load the TE annotation GFF3 file
#gff_data <- read.table(gff_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
#
## Check the superfamilies present in the GFF3 file, and their counts
#gff_data$V3 %>% table()
#
#
## custom ideogram data
### To make the ideogram data, you need to know the lengths of the scaffolds.
### There is an index file that has the lengths of the scaffolds, the `.fai` file.
### To generate this file you need to run the following command in bash:
### samtools faidx assembly.fasta
### This will generate a file named assembly.fasta.fai
### You can then read this file in R and prepare the custom ideogram data
#
#custom_ideogram <- read.table(fai_file, header = FALSE, stringsAsFactors = FALSE)
#
#custom_ideogram$chr <- custom_ideogram$V1
#custom_ideogram$start <- 1
#custom_ideogram$end <- custom_ideogram$V2
#custom_ideogram <- custom_ideogram[, c("chr", "start", "end")]
#custom_ideogram <- custom_ideogram[order(custom_ideogram$end, decreasing = T), ]
#sum(custom_ideogram$end[1:20])
#
## Select only the first 20 longest scaffolds, You can reduce this number if you have longer chromosome scale scaffolds
#custom_ideogram <- custom_ideogram[1:14, ]
#
## Function to filter GFF3 data based on Superfamily (You need one track per Superfamily)
#filter_superfamily <- function(gff_data, superfamily, custom_ideogram) {
#    filtered_data <- gff_data[gff_data$V3 == superfamily, ] %>%
#        as.data.frame() %>%
#        mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
#        select(chrom, start, end, strand) %>%
#        filter(chrom %in% custom_ideogram$chr)
#    return(filtered_data)
#}
#
#pdf("R_visualizations/plots/02-TE_density.pdf", width = 10, height = 10)
#gaps <- c(rep(1, length(custom_ideogram$chr) - 1), 5) # Add a gap between scaffolds, more gap for the last scaffold
#circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
## Initialize the circos plot with the custom ideogram
#circos.genomicInitialize(custom_ideogram)
#
## Plot te density
#circos.genomicDensity(filter_superfamily(gff_data, "Gypsy_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "darkgreen", track.height = 0.07, window.size = 1e5)
#circos.genomicDensity(filter_superfamily(gff_data, "Copia_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "darkred", track.height = 0.07, window.size = 1e5)
#circos.genomicDensity(filter_superfamily(gff_data, "tRNA_SINE_retrotransposon", custom_ideogram), count_by = "number", col = "darkblue", track.height = 0.07, window.size = 1e5)
#circos.genomicDensity(filter_superfamily(gff_data, "L1_LINE_retrotransposon", custom_ideogram), count_by = "number", col = "purple", track.height = 0.07, window.size = 1e5)
#circos.genomicDensity(filter_superfamily(gff_data, "Mutator_TIR_transposon", custom_ideogram), count_by = "number", col = "orange", track.height = 0.07, window.size = 1e5)
#
#
#circos.clear()
#
#lgd <- Legend(
#    title = "Superfamily", at = c("Gypsy_LTR_retrotransposon", "Copia_LTR_retrotransposon", "tRNA_SINE_retrotransposon", "L1_LINE_retrotransposon", "Mutator_TIR_transposon"),
#    legend_gp = gpar(fill = c("darkgreen", "darkred", "darkblue", "purple", "orange"))
#)
#draw(lgd, x = unit(16, "cm"), y = unit(20, "cm"), just = c("center"))
#
#dev.off()
#
#
## Now plot all your most abundant TE superfamilies in one plot
#
## Plot the distribution of Athila and CRM clades (known centromeric TEs in Brassicaceae).
## You need to run the TEsorter on TElib to get the clades classification from the TE library

#!/usr/bin/env Rscript

# -------------------------------------------------------------
# Genome-wide TE density visualization using circlize
# Author: ppilipczuk
# -------------------------------------------------------------

library(circlize)
library(tidyverse)
library(ComplexHeatmap)
library(grid)

# --- PATHS (adapted to your setup) ---
gff_file <- "/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes/results/EDTA_annotation/assembly_primary_contig.fa.mod.EDTA.TEanno.gff3"
#fai_file <- "/data/users/ppilipczuk/GenomeAndTransAss/results/hifiasm/assembly_primary_contig.fa.fai"

gff_file <- "/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes/results/EDTA_annotation/assembly_primary_contig.fa.mod.EDTA.TEanno.gff3"
assembly_fasta <- "/data/users/ppilipczuk/GenomeAndTransAss/results/hifiasm/assembly_primary_contig.fa"
fai_file <- paste0(assembly_fasta, ".fai")
output_dir <- "/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes/results/plots"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)


gff_annotation <- "/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes/results/GFF/final/filtered.genes.renamed.gff3"
annotation_data <- read.table(gff_annotation, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# -------------------------------------------------------------
# Generate .fai index if it doesn't exist
# -------------------------------------------------------------
if (!file.exists(fai_file)) {
  message("FASTA index (.fai) not found, generating with samtools faidx ...")
  cmd <- paste("samtools faidx", shQuote(assembly_fasta))
  status <- system(cmd)
  if (status != 0) {
    stop("samtools faidx failed. Check that samtools is installed and accessible.")
  }
  if (!file.exists(fai_file)) {
    stop("FASTA index still not found after running samtools.")
  }
} else {
  message("Found existing FAI file: ", fai_file)
}


# --- Load TE annotation ---
message("Reading TE annotation GFF3: ", gff_file)
#gff_data <- read.table(gff_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE, comment.char = "")
gff_data <- read.table(
  gff_file,
  header = FALSE,           # GFF3 doesn’t have a header
  sep = "\t",
  comment.char = "#",       # skip comment lines starting with #
  quote = "",
  fill = TRUE,              # fill missing columns if any
  stringsAsFactors = FALSE
)

# keep only valid rows with at least 9 columns
gff_data <- gff_data[ncol(gff_data) >= 9, 1:9]
colnames(gff_data) <- paste0("V", 1:9)

colnames(gff_data)[1:9] <- paste0("V", 1:9)

# --- Quick summary of superfamilies ---
message("Superfamily counts:")
print(table(gff_data$V3))

# --- Prepare ideogram data from .fai ---
message("Reading FASTA index (fai): ", fai_file)
custom_ideogram <- read.table(fai_file, header = FALSE, stringsAsFactors = FALSE)
custom_ideogram <- custom_ideogram %>%
  transmute(chr = V1, start = 1, end = V2) %>%
  arrange(desc(end))

# Select top scaffolds (largest contigs)
N <- 14
custom_ideogram <- custom_ideogram[1:min(N, nrow(custom_ideogram)), ]
message("Using ", nrow(custom_ideogram), " longest scaffolds for plotting.")

# --- Helper: filter one TE superfamily ---
filter_superfamily <- function(gff_data, superfamily, ideogram) {
  gff_data %>%
    filter(V3 == superfamily, V1 %in% ideogram$chr) %>%
    transmute(chrom = V1, start = V4, end = V5, strand = V7)
}

# --- Output directory and file ---
output_dir <- "/data/users/ppilipczuk/OrganizationAndAnnotationOfEkuaryoticGenomes/results/plots"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
pdf(file.path(output_dir, "02_TE_density.pdf"), width = 10, height = 10)

# --- Initialize circular layout ---
gaps <- c(rep(1, nrow(custom_ideogram) - 1), 5)
circos.clear()
circos.par(start.degree = 90, gap.after = gaps, track.margin = c(0, 0))
circos.genomicInitialize(custom_ideogram)

# --- Plot TE density tracks ---
message("Drawing genomic density tracks...")

te_colors <- c(
  "gene"="black",
  "Gypsy_LTR_retrotransposon" = "darkgreen",
  "Copia_LTR_retrotransposon" = "darkred",
  "tRNA_SINE_retrotransposon" = "darkblue",
  "L1_LINE_retrotransposon" = "purple",
  "Mutator_TIR_transposon" = "orange"
)

circos.genomicDensity(filter_superfamily(annotation_data, "gene", custom_ideogram), count_by = "number", col = "black", track.height = 0.07, window.size = 1e5)
for (sf in names(te_colors)) {
  df <- filter_superfamily(gff_data, sf, custom_ideogram)
  if (nrow(df) > 0) {
    circos.genomicDensity(df,
      count_by = "number", col = te_colors[[sf]],
      track.height = 0.07, window.size = 1e5
    )
  } else {
    message("Warning: No entries for ", sf)
  }
}

# --- Legend ---
circos.clear()
lgd <- Legend(
  title = "Superfamily",
  at = names(te_colors),
  legend_gp = gpar(fill = unname(te_colors))
)
draw(lgd, x = unit(16, "cm"), y = unit(20, "cm"), just = c("center"))

dev.off()

message("TE density circular plot saved to: ", file.path(output_dir, "02_TE_density.pdf"))

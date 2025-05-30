# --------------------------- #
# pcadapt Outlier Detection (R)
# --------------------------- #
# This script performs a PCA-based outlier detection using the pcadapt R package.
# It uses the VCF with 75 samples before removing the 2 contaminated samples.
#
# Requirements:
# - R with the pcadapt and qvalue packages installed
#
# Data:
# - BED file: Final_CtoT_GtoA_SNP.bed
# - Metadata file: pika_10populations_metadata.txt
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
# Load required libraries
library(pcadapt)
library(qvalue)
library(ggplot2)

# --------------------------- #
# Perform PCA analysis
# --------------------------- #
# Load genotype data from the BED file
pika_bed <- "../data/old-data/Final_CtoT_GtoA_SNP.bed"
pika_pcadapt <- read.pcadapt(pika_bed, type = "bed")

# Run PCA with 5 principal components
pika_pcadapt_pca <- pcadapt(input = pika_pcadapt, K = 5)
print("Summary of pcadapt results (old):")
summary(pika_pcadapt_pca)

# --------------------------- #
# Generate plots
# --------------------------- #
# Load population metadata
metadata <- read.table('../data/old-data/pika_10populations_metadata.txt', header = FALSE)
pop_ids <- metadata[, 2]

# Extract PCA scores and add metadata
pika_pcadapt_pca_scores <- as.data.frame(pika_pcadapt_pca$scores)
colnames(pika_pcadapt_pca_scores) <- paste0("PC", 1:ncol(pika_pcadapt_pca_scores))
pika_pcadapt_pca_scores$Population <- pop_ids

# Separate location and time from population labels
pika_pcadapt_pca_scores$Site <- sub("_[HM]$", "", pika_pcadapt_pca_scores$Population)
pika_pcadapt_pca_scores$Time <- sub("^.*_", "", pika_pcadapt_pca_scores$Population)

# Score plot for the first two PCs (old)
png("pcadapt-results/old_pika_pcadapt_projection1v2.png", width = 10, height = 10, units = "in", res = 300)
ggplot(pika_pcadapt_pca_scores, aes(x = PC1, y = PC2, color = Site, shape = Time)) +
    geom_point(size = 3) +
    geom_point(data = pika_pcadapt_pca_scores[c(45, 60), ],
            shape = 21, size = 6, color = "red", stroke = 1) +
    geom_text(data = pika_pcadapt_pca_scores[c(45, 60), ],
            aes(label = c("58503_MTJE_H", "208251_YOSE_M")),
            hjust = 0, vjust = -1, size = 5, color = "black") +
    theme_bw() +
    theme(
        plot.title = element_text(hjust = 0.5, size = 18),
        axis.title = element_text(size = 16),
        axis.text = element_text(size = 14),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 14),
        legend.position = "right"
    )
dev.off()
print("Old score plot (PC1 vs. PC2) saved")

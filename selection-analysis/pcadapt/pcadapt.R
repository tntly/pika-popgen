# --------------------------- #
# pcadapt Outlier Detection (R)
# --------------------------- #
# This script performs a PCA-based outlier detection using the pcadapt R package.
# It includes PCA analysis, visualization, and outlier detection with q-values.
#
# Requirements:
# - R with the pcadapt and qvalue packages installed
#
# Data:
# - BED file: pika_73ind_4.8Msnp_10pop.bed
# - Metadata file: pika_10pop_metadata.txt
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
# Load required libraries
library(pcadapt)
library(qvalue)

# --------------------------- #
# Perform PCA analysis
# --------------------------- #
# Load genotype data from the BED file
pika_bed <- "../data/pika_73ind_4.8Msnp_10pop.bed"
pika_pcadapt <- read.pcadapt(pika_bed, type = "bed")

# Run PCA with 20 principal components to determine the number of PCs to retain
pika_pcadapt_pca <- pcadapt(input = pika_pcadapt, K = 20)
png("pcadapt-results/pika_pcadapt_screeplot_k20.png", width = 10, height = 10, units = "in", res = 300)
plot(pika_pcadapt_pca, option = "screeplot")  
dev.off()
print("Scree plot (K = 20) saved")

# Run PCA with 5 principal components
pika_pcadapt_pca <- pcadapt(input = pika_pcadapt, K = 5)
print("Summary of pcadapt results:")
summary(pika_pcadapt_pca)

# --------------------------- #
# Generate plots
# --------------------------- #
# Scree plot: visualize variance explained by each principal component
png("pcadapt-results/pika_pcadapt_screeplot_k5.png", width = 10, height = 10, units = "in", res = 300)
plot(pika_pcadapt_pca, option = "screeplot")  
dev.off()
print("Scree plot (K = 5) saved")

# Load population metadata
metadata <- read.table("../data/pika_10pop_metadata.txt", header = FALSE)
pop_ids <- metadata[, 2]

# Score plot for the first two PCs
png("pcadapt-results/pika_pcadapt_projection1v2.png", width = 10, height = 10, units = "in", res = 300)
plot(pika_pcadapt_pca, option = "scores", i = 1, j = 2, pop = pop_ids)
dev.off()
print("Score plot (PC1 vs. PC2) saved")

# Score plot for the fourth and fifth PCs
png("pcadapt-results/pika_pcadapt_projection4v5.png", width = 10, height = 10, units = "in", res = 300)
plot(pika_pcadapt_pca, option = "scores", i = 4, j = 5, pop = pop_ids)
dev.off()
print("Score plot (PC4 vs. PC5) saved")

# Manhattan plot: visualize p-values across the genome
png("pcadapt-results/pika_pcadapt_manhattan.png", width = 10, height = 10, units = "in", res = 300)
plot(pika_pcadapt_pca, option = "manhattan")
dev.off()
print("Manhattan plot saved")

# Q-Q plot: visualize the distribution of p-values
png("pcadapt-results/pika_pcadapt_qqplot.png", width = 10, height = 10, units = "in", res = 300)
plot(pika_pcadapt_pca, option = "qqplot")
dev.off()
print("Q-Q plot saved")

# Histogram of p-values: assess uniformity of distribution
png("pcadapt-results/pika_pcadapt_pvalues_hist.png", width = 10, height = 10, units = "in", res = 300)
hist(pika_pcadapt_pca$pvalues, xlab = "p-values", main = NULL, breaks = 50, col = "orange")
dev.off()
print("Histogram of p-values saved")

# Test statistic distribution: assess the distribution of test statistics
png("pcadapt-results/pika_pcadapt_stat_dist.png", width = 10, height = 10, units = "in", res = 300)
plot(pika_pcadapt_pca, option = "stat.distribution")
dev.off()
print("Distribution of test statistics saved")

# --------------------------- #
# Identify outliers
# --------------------------- #
# Transforms p-values into q-values
# pika_pcadapt_padj <- p.adjust(pika_pcadapt_pca$pvalues, method = "bonferroni")
# alpha <- 0.01   # Significance threshold for outlier detection
# outliers <- which(pika_pcadapt_padj < alpha)
# print("Number of outliers found:")
# length(outliers)

pika_pcadapt_qval <- qvalue(pika_pcadapt_pca$pvalues)$qvalues
alpha <- 0.01   # Significance threshold for outlier detection
outliers <- which(pika_pcadapt_qval < alpha)
print("Number of outliers found:")
length(outliers)

# Save outliers to a file
write.table(outliers, file = "pcadapt-results/pika_pcadapt_outliers.txt", 
            row.names = FALSE, col.names = FALSE)
print("Outliers saved to pika_pcadapt_outliers.txt")

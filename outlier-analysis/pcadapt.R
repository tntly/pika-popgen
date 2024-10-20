# --- INSTALL REQUIRED PACKAGES ---
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
if (!requireNamespace("pcadapt", quietly = TRUE)) {
  install.packages("pcadapt")
}
# answer "yes" twice regarding a personal library if asked
# choose OH as the mirror by entering the appropriate number when prompted

# Load the necessary libraries for the analysis
library(pcadapt)

# --- PCA ANALYSIS ---
# pcadapt uses an ordination approach to find sites in a data set that are outliers with respect to background population structure

# Load in the data
pikas_bed <- "/home/tly/outlier-analysis/data/Final_CtoT_GtoA_SNP.bed"
pikas_pcadapt <- read.pcadapt(pikas_bed, type = "bed")

# Run PCA analysis with K = 5 principal components
pikas_pcadapt_pca <- pcadapt(input = pikas_pcadapt, K = 5)
print("Summary of PCA results:")
summary(pikas_pcadapt_pca)

# --- PLOTS ---

# Scree plot: visualize variance explained by each principal component
png("/home/tly/outlier-analysis/results/pcadapt/pcadapt_pikas_k5plot.png")
plot(pikas_pcadapt_pca, option = "screeplot")  
dev.off()
print("Scree plot saved as pcadapt_pikas_k5plot.png")

# Score plot: investigate axis projections
# Load population metadata
metadata <- read.table("/home/tly/outlier-analysis/data/pika_10populations_metadata.txt", header = FALSE)
poplist.names <- metadata[, 2]
print("Population metadata loaded:")
print(poplist.names)

# Projections of individuals on the first 2 principal components
png("/home/tly/outlier-analysis/results/pcadapt/pcadapt_pikas_projection1v2.png")
plot(pikas_pcadapt_pca, option = "scores", i = 1, j = 2, pop = poplist.names)
dev.off()
print("Score plot (PC1 vs PC2) saved as pcadapt_pikas_projection1v2.png")

# Projections of individuals on the 4th and 5th components
png("/home/tly/outlier-analysis/results/pcadapt/pcadapt_starlings_projection4v5.png")
plot(pikas_pcadapt_pca, option = "scores", i = 4, j = 5, pop = poplist.names)
dev.off()
print("Score plot (PC4 vs PC5) saved as pcadapt_starlings_projection4v5.png")

# Manhattan plot: visualize p-values across the genome
png("/home/tly/outlier-analysis/results/pcadapt/pcadapt_pikas_manhattan.png")
plot(pikas_pcadapt_pca, option = "manhattan")
dev.off()
print("Manhattan plot saved as pcadapt_pikas_manhattan.png")

# Q-Q plot: visualize the distribution of p-values
png("/home/tly/outlier-analysis/results/pcadapt/pcadapt_pikas_qqplot.png")
plot(pikas_pcadapt_pca, option = "qqplot")
dev.off()
print("Q-Q plot saved as pcadapt_pikas_qqplot.png")

# Histogram of p-values: assess uniformity of distribution
png("/home/tly/outlier-analysis/results/pcadapt/pcadapt_pikas_pvalues.png")
hist(pikas_pcadapt_pca$pvalues, xlab = "p-values", main = NULL, breaks = 50, col = "orange")
dev.off()
print("Histogram of p-values saved as pcadapt_pikas_pvalues.png")

# --- IDENTIFY OUTLIERS ---

# Adjust p-values using Bonferroni correction
pikas_pcadapt_padj <- p.adjust(pikas_pcadapt_pca$pvalues, method = "bonferroni")
# Set significance threshold for outlier detection
alpha <- 0.05
outliers <- which(pikas_pcadapt_padj < alpha)

print("Number of outliers found:")
length(outliers)

write.table(outliers, file = "/home/tly/outlier-analysis/results/pcadapt/pikas_pcadapt_outliers.txt")
print("Outliers saved to pikas_pcadapt_outliers.txt")

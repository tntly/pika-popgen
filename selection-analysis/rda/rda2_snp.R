# --------------------------- #
# SNP Outlier Detection from RDA – Analysis 2 of 2
# --------------------------- #
# This script identifies SNPs with extreme loadings along the first RDA axis
# from the second RDA model, which used the environmental variables:
# - ppt_sum
# - vpdmin_min
# - winter_tmax_max
#
# The workflow includes:
# - Extracting SNP loadings from RDA1
# - Detecting outlier SNPs based on z-score threshold
# - Correlating each outlier SNP with environmental variables
# - Assigning the strongest predictor per SNP
# - Saving annotated outlier SNPs to file
#
# Data:
# - pika_rda_012_freq.Rdata (contains pika_allele_freq)
# - pika_rda_2.Rdata (contains pika_rda and env_data_lfmm_U)
# --------------------------- #

# --------------------------- #
# Environment Setup
# --------------------------- #
library(LEA)
library(psych)
library(tidyverse)
library(vcfR)
library(vegan)

# Load RDA model and related data
load("pika_rda_012_freq.Rdata")
load("pika_rda_2.Rdata")

# --------------------------- #
# Identify Outlier SNPs
# --------------------------- #
# Extract SNP loadings from RDA1
pika_rda_loadings <- scores(pika_rda, choices = 1, display = "species")

# Function to identify outliers based on z-score threshold
# x: vector of loadings
# z: threshold in terms of standard deviations from the mean
identify_outliers <- function(x, z) {
    bounds <- mean(x) + c(-1, 1) * z * sd(x)
    x[x < bounds[1] | x > bounds[2]]
}

# Get SNPs with loading beyond +-2.5 SDs
pika_rda_outliers <- identify_outliers(x = pika_rda_loadings[, 1], z = 2.5)
print("Number of outlier SNPs for ppt_sum + vpdmin_min + winter_tmax_max + Condition(V1 + V2):")
length(pika_rda_outliers)

# Create annotated data frame of outlier SNPs
pika_rda_outliers_df <- cbind.data.frame(
    snp_id = names(pika_rda_outliers),
    RDA1 = unname(pika_rda_outliers)
)

# --------------------------- #
# Correlation with Environment
# --------------------------- #
# Create matrix to store correlations (SNP x env vars)
corr_matrix <- matrix(nrow = nrow(pika_rda_outliers_df), ncol = 3)
colnames(corr_matrix) <- c("ppt_sum", "vpdmin_min", "winter_tmax_max")

# Compute correlations for each SNP with each env variable
for (i in 1:nrow(pika_rda_outliers_df)) {
    snp_id <- pika_rda_outliers_df[i, "snp_id"]
    snp_vector <- pika_allele_freq[, snp_id]
    
    corr_matrix[i, ] <- apply(env_data_lfmm_U[, colnames(corr_matrix)], 2,
                            function(x) cor(x, snp_vector))
}

# Add correlations to data frame
pika_rda_outliers_df <- cbind(pika_rda_outliers_df, corr_matrix)

# Determine the environmental variable with the strongest correlation (absolute)
for (i in 1:nrow(pika_rda_outliers_df)) {
    abs_corrs <- abs(pika_rda_outliers_df[i, 3:5])
    max_var <- names(which.max(abs_corrs))
    
    pika_rda_outliers_df[i, "predictor"] <- max_var
    pika_rda_outliers_df[i, "correlation"] <- max(abs_corrs)
}

# Show count of outliers per top predictor
print("Top predictor per outlier SNP:")
table(pika_rda_outliers_df$predictor)

# --------------------------- #
# Save Results
# --------------------------- #
write.table(pika_rda_outliers_df,
            file = "rda-results/pika_rda_outliers_2.txt",
            sep = "\t", row.names = FALSE, quote = FALSE)
print("Saved: pika_rda_outliers_2.txt")

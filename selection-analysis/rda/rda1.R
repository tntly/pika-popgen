# --------------------------- #
# RDA Analysis of Pika Allele Frequencies (R) – Analysis 1 of 2
# --------------------------- #
# This script performs the first of 2 redundancy analyses (RDA) on allele frequency data
# for American pika populations using climate-related environmental variables as predictors.
#
# This script uses the following environmental variables:
# - ppt_sum
# - vpdmin_min
# - elev
#
# The workflow includes:
# - Loading and processing genotype data from a VCF file
# - Calculating population-level allele frequencies
# - Loading and scaling environmental data
# - Running LFMM to extract latent factors (population structure)
# - Fitting the RDA model
# - Visualizing results (screeplot, ordination)
# - Model diagnostics (adjusted R², VIF)
# - Significance testing (overall model, axes, terms)
# - Saving results for downstream use
#
# The second script (Analysis 2 of 2) repeats the RDA process using an alternative
# environmental variable set that includes winter_tmax_max instead of elev.
#
# Requirements:
# - R with the LEA, psych, tidyverse, vcfR, and vegan packages installed
#
# Data:
# - VCF file: pika_73ind_4.8Msnp_10pop.vcf
# - Environmental data: pika_10pop_env_data_POP.txt
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
# Load required libraries
library(LEA)
library(psych)
library(tidyverse)
library(vcfR)
library(vegan)

# --------------------------- #
# Data Preparation
# --------------------------- #
# Load raw genotype and environmental data, process it into the required format (e.g., recoding genotypes to 012, 
# calculating allele frequencies, and scaling environmental variables), and save the processed results

# --- Genotype Data Processing ---
# Read the VCF file into a vcfR object and extract genotype data
pika_vcfR <- read.vcfR("../data/pika_73ind_4.8Msnp_10pop.vcf")
pika_gt <- extract.gt(pika_vcfR)

# Preview genotype matrix dimensions and frequency distribution
print("Dimensions of the genotype matrix:")
dim(pika_gt)
print("First 10 columns of the genotype matrix:")
head(pika_gt[, 1:10])
print("Frequency table of the genotype matrix:")
table(as.vector(pika_gt))

# Recode genotypes to 012 format
pika_gt_012 <- matrix(NA, nrow = nrow(pika_gt), ncol = ncol(pika_gt), dimnames = dimnames(pika_gt))

pika_gt_012[pika_gt %in% c("0/0", "0|0")] <- 0
pika_gt_012[pika_gt %in% c("0/1", "0|1", "1/0", "1|0")] <- 1
pika_gt_012[pika_gt %in% c("1/1", "1|1")] <- 2
pika_gt_012[is.na(pika_gt_012)] <- 9 # Missing data encoded as 9

print("Frequency table of the 012 matrix:")
table(as.vector(pika_gt_012))

# Transpose 012 matrix for downstream analysis
t_pika_gt_012 <- t(pika_gt_012) %>% as.data.frame()
print("Dimensions of the transposed 012 matrix:")
dim(t_pika_gt_012)
print("First 10 columns of the transposed 012 matrix:")
head(t_pika_gt_012[, 1:10])

# --- Population Allele Frequency Calculation ---
# Load population metadata and calculate allele frequencies per population
metadata <- read.table("../data/pika_10pop_metadata.txt", col.names = c("sample_id", "pop_id"))
pika_allele_freq <- as.data.frame(apply(t_pika_gt_012, 2,
                                function(x) by(x, as.character(metadata$pop_id), mean)) / 2)

print("Structure of the population allele frequency data:")
str(pika_allele_freq)

# Save processed genotype data
save(t_pika_gt_012, pika_allele_freq, file = "pika_rda_012_freq.Rdata")
print("Saved: pika_rda_012_freq.Rdata")

# --- Load Processed Genotype Data (For Resuming Analysis) ---
# Load the previously saved genotype/allele frequency
# load("pika_rda_012_freq.Rdata")

# --- Environmental Data Processing ---
# Load and scale environmental variables
env_data <- read.table("../data/pika_10pop_env_data_POP.txt", header = TRUE, sep = "\t")
env_data <- env_data %>%
    select(ppt_sum, vpdmin_min, elev) %>%
    scale() %>% as.data.frame()

# Run PCA on allele frequencies to determine optimal K for LFMM and save screeplot
pika_rda_pca <- rda(pika_allele_freq, scale = TRUE)
png("rda-results/pika_rda_pca_screeplot.png", width = 10, height = 8, units = "in", res = 300)
screeplot(pika_rda_pca, bstick = TRUE, type = "barplot")
dev.off()
print("Saved: pika_rda_pca_screeplot.png")

# Run LFMM analysis at the population level and extract latent factors
pika_lfmm <- lfmm2(pika_allele_freq, env_data, 2)
print("LFMM analysis at the population level completed")
pika_lfmm_U <- as.data.frame(pika_lfmm@U)

# Combine environmental data with latent factors and visualize correlations
env_data_lfmm_U <- bind_cols(env_data, pika_lfmm_U)
png("rda-results/pika_rda_env_corr.png", width = 10, height = 8, units = "in", res = 300)
pairs.panels(env_data_lfmm_U)
dev.off()
print("Saved: pika_rda_env_corr.png")

# --------------------------- #
# RDA Analysis
# --------------------------- #
# Run RDA using population allele frequencies as the response
# and environmental variables as predictors, while conditioning on latent factors (V1 and V2)
pika_rda <- rda(pika_allele_freq ~ ppt_sum + vpdmin_min + elev + Condition(V1 + V2),
                data = env_data_lfmm_U, scale = TRUE)
print("RDA analysis completed")
print(pika_rda)

# --------------------------- #
# Visualization: Screeplot
# --------------------------- #
# Generate a screeplot to visualize the eigenvalues of the constrained axes,
# indicating the variance explained by the RDA model
png("rda-results/pika_rda_screeplot.png", width = 10, height = 8, units = "in", res = 300)
screeplot(pika_rda, main = "Eigenvalues of Constrained Axes")
dev.off()
print("Saved: pika_rda_screeplot.png")

# --------------------------- #
# Model Summaries and Diagnostics
# --------------------------- #
# Display the RDA model summary to inspect the overall fit, calculate the adjusted R-squared,
# and assess multicollinearity using VIF
summary(pika_rda)
RsquareAdj(pika_rda)    # Adjusted R-squared
vif.cca(pika_rda)       # VIF (values < 10 indicate acceptable multicollinearity)

# --------------------------- #
# Ordination Plot: Scaling 3
# --------------------------- #
# Create an ordination plot using scaling 3 to visualize the RDA results
png("rda-results/pika_rda_scaling3.png", width = 10, height = 8, units = "in", res = 300)
ordiplot(pika_rda, scaling = 3, main = "Pika RDA - Scaling 3", type = "text")
dev.off()
print("Saved: pika_rda_scaling3.png")

# --------------------------- #
# RDA Model Significance Testing
# --------------------------- #
# Assess the statistical significance of the RDA model using permutation tests

# Full model significance test
pika_rda_signif_full <- anova.cca(pika_rda)
print("Full model significance test:")
print(pika_rda_signif_full)

# Significance test for individual constrained axes
pika_rda_signif_axis <- anova.cca(pika_rda, by = "axis")
print("Significance of individual constrained axes:")
print(pika_rda_signif_axis)

# Significance test for each explanatory term
pika_rda_signif_term <- anova.cca(pika_rda, by = "term")
print("Significance of explanatory terms:")
print(pika_rda_signif_term)

# --------------------------- #
# Save RDA Results
# --------------------------- #
# Save the final RDA model and significance test results for future reference or downstream analysis
save(env_data_lfmm_U, pika_rda, pika_rda_signif_full, pika_rda_signif_axis, pika_rda_signif_term,
    file = "pika_rda.Rdata")
print("Saved: pika_rda_1.Rdata")

# --------------------------- #
# RDA Analysis of Pika Allele Frequencies (R) – Analysis 2 of 2
# --------------------------- #
# This script performs a second redundancy analysis (RDA) on pika allele frequency data,
# using an alternative set of environmental variables:
# - ppt_sum
# - vpdmin_min
# - winter_tmax_max
#
# The workflow includes:
# - Loading and scaling environmental data
# - Running LFMM to extract latent factors
# - Fitting the RDA model
# - Visualizing results (screeplot, ordination)
# - Model diagnostics and significance testing
# - Saving results
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
library(LEA)
library(psych)
library(tidyverse)
library(vcfR)
library(vegan)

# --------------------------- #
# Load Processed Genotype Data
# --------------------------- #
# Load pre-processed allele frequency data
load("pika_rda_012_freq.Rdata")

# --------------------------- #
# Environmental Data Processing
# --------------------------- #
# Load and scale the alternative set of environmental variables
env_data <- read.table("../data/pika_10pop_env_data_POP.txt", header = TRUE, sep = "\t")
env_data <- env_data %>%
    select(ppt_sum, vpdmin_min, winter_tmax_max) %>%
    scale() %>% as.data.frame()

# --------------------------- #
# LFMM Analysis to Estimate Latent Factors
# --------------------------- #
# Run LFMM with K = 2 to capture latent structure
pika_lfmm <- lfmm2(pika_allele_freq, env_data, 2)
print("LFMM analysis (2nd env set) completed")
pika_lfmm_U <- as.data.frame(pika_lfmm@U)

# Combine scaled environmental data with latent factors
env_data_lfmm_U <- bind_cols(env_data, pika_lfmm_U)

# Visualize correlation between latent factors and environmental variables
png("rda-results/pika_rda_env_corr_2.png", width = 10, height = 8, units = "in", res = 300)
pairs.panels(env_data_lfmm_U)
dev.off()
print("Saved: pika_rda_env_corr_2.png")

# --------------------------- #
# RDA Analysis
# --------------------------- #
# Run RDA with the new environmental variables and latent factors
pika_rda <- rda(pika_allele_freq ~ ppt_sum + vpdmin_min + winter_tmax_max + Condition(V1 + V2),
                data = env_data_lfmm_U, scale = TRUE)
print("RDA (2nd env set) completed")
print(pika_rda)

# --------------------------- #
# Visualization: Screeplot
# --------------------------- #
png("rda-results/pika_rda_screeplot_2.png", width = 10, height = 8, units = "in", res = 300)
screeplot(pika_rda, main = "Eigenvalues of Constrained Axes")
dev.off()
print("Saved: pika_rda_screeplot_2.png")

# --------------------------- #
# Model Summaries and Diagnostics
# --------------------------- #
summary(pika_rda)
RsquareAdj(pika_rda)    # Adjusted R-squared
vif.cca(pika_rda)       # VIF (values < 10 indicate acceptable multicollinearity)

# --------------------------- #
# Ordination Plot: Scaling 3
# --------------------------- #
png("rda-results/pika_rda_scaling3_2.png", width = 10, height = 8, units = "in", res = 300)
ordiplot(pika_rda, scaling = 3, main = "Pika RDA - Scaling 3", type = "text")
dev.off()
print("Saved: pika_rda_scaling3_2.png")

# --------------------------- #
# RDA Model Significance Testing
# --------------------------- #
# Overall model test
pika_rda_signif_full <- anova.cca(pika_rda)
print("Full model significance test (2nd env set):")
print(pika_rda_signif_full)

# Test for individual constrained axes
pika_rda_signif_axis <- anova.cca(pika_rda, by = "axis")
print("Significance of individual axes:")
print(pika_rda_signif_axis)

# Test for each environmental term
pika_rda_signif_term <- anova.cca(pika_rda, by = "term")
print("Significance of individual terms:")
print(pika_rda_signif_term)

# --------------------------- #
# Save Results
# --------------------------- #
# Save all RDA results for this run
save(env_data_lfmm_U, pika_rda, pika_rda_signif_full, pika_rda_signif_axis, pika_rda_signif_term,
    file = "pika_rda_2.Rdata")

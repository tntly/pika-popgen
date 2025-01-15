# --------------------------- #
# BayeScan Outlier Detection (R)
# --------------------------- #
# This script generates plots and identifies outliers based on BayeScan results.
#
# Requirements: BayeScan's R plotting functions
# 
# Data: Output files from BayeScan run
# --------------------------- #

# Load BayeScan plotting functions
source("~/programs/BayeScan2.1/R functions/plot_R.r")

# Initialize total SNP counter
total_SNPs <- 0
# Read the list of subsamples
subsamples <- readLines("bayescan1-results-fst/subsamples.txt")

# Loop through each subsample and generate plots and outlier tables
for (subsample in subsamples) {
  # Extract the subsample number using regex
  subsample_num <- sub(".*_(\\d+).*", "\\1", subsample)
  cat(sprintf("Processing subsample number: %s\n", subsample_num))

  # Define plot and outlier file paths
  plot_path <- sprintf("bayescan-plots/bayescan_pika_subsample_%s.png", subsample_num)
  outlier_path <- sprintf("bayescan2-results/bayescan2-outliers/pika_bayescan_outliers_%s.txt", subsample_num)

  # Create and save the plot
  png(plot_path, width = 10, height = 10, units = "in", res = 300)
  pika_bayescan <- plot_bayescan(subsample, FDR = 0.01)
  dev.off()

 # Save outliers to a file
  write.table(pika_bayescan$outliers, file = outlier_path, row.names = FALSE, col.names = FALSE)
  
  # Update total SNP counter
  total_SNPs <- total_SNPs + pika_bayescan$nb_outliers

  # Print progress
  cat(sprintf("Number of outliers found: %d\n", pika_bayescan$nb_outliers))
}

# Print total SNP count
cat(sprintf("Total number of SNPs across all subsamples: %d\n", total_SNPs))

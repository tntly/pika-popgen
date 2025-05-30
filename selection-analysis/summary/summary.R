# --------------------------- #
# Summary of Outlier Overlap Across Methods
# --------------------------- #
# This script summarizes SNP outlier overlaps across four detection methods:
# - pcadapt (population structure)
# - BayeScan (FST-based)
# - BayPass (GEA with vpdmin_min)
# - RDA (GEA with vpdmin_min)
#
# Requirements:
# - R with UpSetR package installed
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
library(UpSetR)
library(ggplot2)
library(ComplexUpset)

# --------------------------- #
# Load outlier SNP IDs
# --------------------------- #
# Each list contains SNP IDs identified as outliers by the corresponding method
pcadapt <- scan("../pcadapt/pcadapt-results/pika_pcadapt_outlier_SNPIDs.txt", what = "", quiet = TRUE)
bayescan <- scan("../bayescan/bayescan2-results/pika_bayescan_outlier_SNPIDs.txt", what = "", quiet = TRUE)
baypass <- scan("../baypass/baypass-results/pika_baypass_gea2_vpdmin_min_outlier_SNPIDs.txt", what = "", quiet = TRUE)
rda <- scan("../rda/rda-results/pika_rda_2_vpdmin_min_outlier_SNPIDs.txt", what = "", quiet = TRUE)

# Combine into a named list for UpSetR
all_outliers <- list(
  pcadapt = pcadapt,
  BayeScan = bayescan,
  BayPass = baypass,
  RDA = rda
)

# Union of all SNPs detected by either pcdapt or BayeScan
pcadapt_bayescan_union <- sort(unique(c(pcadapt, bayescan)))
# Union of all SNPs detected by BayPass or RDA
baypass_rda_union <- sort(unique(c(baypass, rda)))

# Logical presence/absence table for UpSetR
upset_data_pcadapt_bayescan <- data.frame(
  SNP = pcadapt_bayescan_union,
  pcadapt = pcadapt_bayescan_union %in% pcadapt,
  BayeScan = pcadapt_bayescan_union %in% bayescan
)
upset_data_baypass_rda <- data.frame(
  SNP = baypass_rda_union,
  BayPass = baypass_rda_union %in% baypass,
  RDA = baypass_rda_union %in% rda
)

# --------------------------- #
# Visualization
# --------------------------- #
# Generate an UpSet plot showing overlaps of outliers across all methods
png("summary-results/all_outliers_UpSetplot.png", width = 8, height = 10, units = "in", res = 300)
upset(
  data = fromList(all_outliers),
  order.by = "freq",
  empty.intersections = "on",
  point.size = 3.5,
  line.size = 2,
  mainbar.y.label = "Outlier Count",
  sets.x.label = "Total Outliers",
  text.scale = c(1.3, 1.3, 1, 1, 2, 1.3),
  number.angles = 30,
  nintersects = 11
)
dev.off()
print("Saved: all_outliers_UpSetplot.png")

# Generate a more complex UpSet plot for pcadapt vs BayeScan
png("summary-results/pcadapt_bayescan_UpSetplot.png", width = 10, height = 10, units = "in", res = 300)
(
upset(
  upset_data_pcadapt_bayescan,
  intersect = c("pcadapt", "BayeScan"),
  base_annotations = list(
    "Intersection size" = (
      intersection_size(
        text = list(size = 5),
        mapping = aes(fill = "bars_color")
      ) +
      ylab("Number of Outlier SNPs") +
      scale_fill_manual(values = c("bars_color" = "steelblue"), guide = "none") +
      theme(
        axis.title.y = element_text(size = 16),
        axis.text.y = element_text(size = 14)
      )
    )
  ),
  name = "Outlier Methods",
  set_sizes = FALSE
) +
  theme(
    axis.title.x = element_text(size = 16),
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14)
  )
)
dev.off()
print("Saved: pcadapt_bayescan_UpSetplot.png")

# Generate a more complex UpSet plot for BayPass vs RDA
png("summary-results/baypass_rda_UpSetplot.png", width = 10, height = 10, units = "in", res = 300)
(
upset(
  upset_data_baypass_rda,
  intersect = c("BayPass", "RDA"),
  base_annotations = list(
    "Intersection size" = (
      intersection_size(
        text = list(size = 5),
        mapping = aes(fill = "bars_color")
      ) +
      ylab("Number of Outlier SNPs") +
      scale_fill_manual(values = c("bars_color" = "steelblue"), guide = "none") +
      theme(
        axis.title.y = element_text(size = 16),
        axis.text.y = element_text(size = 14)
      )
    )
  ),
  name = "Outlier Methods",
  set_sizes = FALSE
) +
  theme(
    axis.title.x = element_text(size = 16),
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14)
  )
)
dev.off()
print("Saved: baypass_rda_UpSetplot.png")

# --------------------------- #
# Identify overlapping outliers
# --------------------------- #
# Find shared SNPs between selected method pairs

# pcadapt and BayeScan
pcadapt_bayescan_overlap <- intersect(all_outliers$pcadapt, all_outliers$BayeScan)

# BayPass and RDA
baypass_rda_overlap <- intersect(all_outliers$BayPass, all_outliers$RDA)

# --------------------------- #
# Save overlapping SNP lists
# --------------------------- #
write.table(pcadapt_bayescan_overlap,
            file = "summary-results/pcadapt_bayescan_overlapping_outliers.txt",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

write.table(baypass_rda_overlap,
            file = "summary-results/baypass_rda_overlapping_outliers.txt",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

print("Saved: overlapping outlier SNP lists")

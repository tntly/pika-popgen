#!/bin/bash
#SBATCH --job-name=bayescan2
#SBATCH --output=bayescan2-results/slurmout/bayescan2-%j.out
#SBATCH --error=bayescan2-results/slurmout/bayescan2-%j.err

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# BayeScan2 Analysis
# --------------------------- #
# This script processes BayeScan results and extracts outlier SNPs.
#
# Requirements: BayeScan, R
#
# Data: BayeScan's output files and VCF files
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
source ~/.bashrc
conda activate pika

# --------------------------- #
# Organize FST files
# --------------------------- #
DIR=~/selection-analysis
cd $DIR/bayescan

dest_dir=bayescan1-results-fst
mv bayescan1-results1/*.g_fst.txt $dest_dir
mv bayescan1-results2/*.g_fst.txt $dest_dir
mv bayescan1-results3/*.g_fst.txt $dest_dir
echo "FST files moved successfully."

# --------------------------- #
# Extract outliers
# --------------------------- #
# Prepare the sample sheet
ls $dest_dir/*.g_fst.txt > $dest_dir/subsamples.txt
# Run BayeScan analysis using R
Rscript bayescan2.R

# --------------------------- #
# Generate SNP identifier files
# --------------------------- #
cd $DIR/vcf-subsample/pika-vcf-70-subsamples
num_subsamples=$(wc -l < subsamples.txt)

for ((i = 1; i <= num_subsamples; i++)); do
    f=$(sed -n "${i}p" subsamples.txt)
    echo "Processing VCF file: $f"
    grep -v "^#" $f | cut -f 1-3 | awk '{print $0 "\t" NR}' > ../pika-SNPs-70-subsamples/pika_SNPs_subsample_${i}.txt
done

# --------------------------- #
# Match outlier files with SNP data
# --------------------------- #
cd $DIR/bayescan/bayescan2-results/bayescan2-outliers
ls pika_bayescan_outliers_*.txt > subsamples.txt

ls $DIR/vcf-subsample/pika-SNPs-70-subsamples/pika_SNPs_subsample_*.txt > $DIR/vcf-subsample/pika-SNPs-70-subsamples/subsamples.txt
subsamples_SNPs=$DIR/vcf-subsample/pika-SNPs-70-subsamples/subsamples.txt

for ((i = 1; i <= num_subsamples; i++)); do
  f1_outliers=$(sed -n "${i}p" subsamples.txt)
  f2_SNPs=$(sed -n "${i}p" $subsamples_SNPs)
  echo "Matching files: $f1_outliers and $f2_SNPs"
  awk 'FNR == NR {a[$1]; next} (($4) in a)' $f1_outliers $f2_SNPs | \
    cut -f 3 > ../bayescan2-outlier-SNPIDs/pika_bayescan_outlier_SNPIDs_${i}.txt
done

# Merge all outlier SNP IDs
cd ../bayescan2-outlier-SNPIDs
cat pika_bayescan_outlier_SNPIDs_*.txt > ../pika_bayescan_outlier_SNPIDs.txt
echo "All outlier SNP IDs combined."

#!/bin/bash
#SBATCH --job-name=pcadapt
#SBATCH --output=slurmout/pcadapt-%j.out
#SBATCH --error=slurmout/pcadapt-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# pcadapt Analysis
# --------------------------- #
# This script prepares genomic data and runs the pcadapt R package for outlier detection.
#
# Requirements: PLINK, R
#
# Data:
# - VCF file: pika_73ind_4.8Msnp_10pop.vcf
# - BED file: pika_73ind_4.8Msnp_10pop.bed
# - Metadata file: pika_10pop_metadata.txt
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
# Load conda environment with required dependencies
source ~/.bashrc
conda activate pika

# Set working directory
DIR=~/selection-analysis
cd $DIR/pcadapt

# --------------------------- #
# Prepare genotype data file
# --------------------------- #
# Convert VCF to BED format using PLINK if necessary
# zcat $DIR/data/pika_73ind_4.8Msnp_10pop.vcf.gz > $DIR/data/pika_73ind_4.8Msnp_10pop.vcf
# ~/programs/plink_linux_x86_64_20240818/plink \
#   --vcf $DIR/data/pika_73ind_4.8Msnp_10pop.vcf \
#   --make-bed --allow-extra-chr --const-fid \
#   --out $DIR/data/pika_73ind_4.8Msnp_10pop

# --------------------------- #
# Run pcadapt analysis
# --------------------------- #
echo "Starting pcadapt analysis in R..."
Rscript old_pcadapt.R
Rscript pcadapt.R

# --------------------------- #
# Identify outlier SNPs
# --------------------------- #
# Extract SNP information from the VCF file
# The SNP IDs will be matched later with detected outliers
echo "Extracting non-header lines from VCF and formatting for SNP IDs..."
grep -v "^#" $DIR/data/pika_73ind_4.8Msnp_10pop.vcf | \
  cut -f 1-3 | \
  awk '{print $0 "\t" NR}' > $DIR/data/pika_10pop_SNPs.txt

# Match outlier SNP line numbers with corresponding SNP IDs
echo "Matching outlier SNP line numbers with SNP IDs..."
awk 'FNR == NR {a[$1]; next} (($4) in a)' \
  pcadapt-results/pika_pcadapt_outliers.txt \
  $DIR/data/pika_10pop_SNPs.txt | \
  cut -f 3 > pcadapt-results/pika_pcadapt_outlier_SNPIDs.txt

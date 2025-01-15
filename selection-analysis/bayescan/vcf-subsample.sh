#!/bin/bash
#SBATCH --job-name=vcf-subsample
#SBATCH --output=slurmout/vcf-subsample-%j.out
#SBATCH --error=slurmout/vcf-subsample-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# VCF Subsampling for BayeScan Analysis
# --------------------------- #
# This script splits a large VCF file into smaller subsets for downstream analysis.
#
# Data:
# - Large VCF file: pika_73ind_4.8Msnp_10pop.vcf
# --------------------------- #

# --------------------------- #
# Set up working directory
# --------------------------- #
DIR=~/selection-analysis
cd $DIR/vcf-subsample

# --------------------------- #
# Prepare VCF file components
# --------------------------- #
# Extract the VCF header
grep '^#' $DIR/data/pika_73ind_4.8Msnp_10pop.vcf > pika_vcf_header.txt

# Extract the VCF variants (no header)
grep -v '^#' $DIR/data/pika_73ind_4.8Msnp_10pop.vcf > pika_vcf_variants.txt

# --------------------------- #
# Set parameters and create subdirectories
# --------------------------- #
step=70   # Number of subsamples to generate
mkdir pika-vcf-${step}-subsamples-variants    # Directory for variant files
mkdir pika-vcf-${step}-subsamples             # Directory for final VCF subsets

# --------------------------- #
# Generate subsampled VCF Files
# --------------------------- #
for i in $(seq 1 $step); do
  echo "Processing subsample ${i}..."

  # Extract every 70th variant starting from line $i
  sed -n "${i}~${step}p" pika_vcf_variants.txt > \
    pika-vcf-${step}-subsamples-variants/pika_subsample_${i}_variants.txt

  # Combine the header and selected variants to create the final VCF subset
  cat pika_vcf_header.txt \
    pika-vcf-${step}-subsamples-variants/pika_subsample_${i}_variants.txt > \
    pika-vcf-${step}-subsamples/pika_subsample_${i}.vcf
done

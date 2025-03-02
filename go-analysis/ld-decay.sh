#!/bin/bash
#SBATCH --job-name=ld-decay
#SBATCH --output=slurmout/ld-decay-%j.out
#SBATCH --error=slurmout/ld-decay-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# Linkage Disequilibrium Decay Analysis
# --------------------------- #
# This script calculates linkage disequilibrium decay and plots the results.
#
# Requirements: PopLDdecay
#
# Data:
# - VCF file: filtered_snps_73ind.vcf.gz
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
# Load conda environment with required dependencies
source ~/.bashrc
conda activate pika

# --------------------------- #
# LD decay calculation
# --------------------------- #
# Calculate LD decay
echo "Calculating linkage disequilibrium decay..."
~/programs/PopLDdecay/bin/PopLDdecay \
    -InVCF ~/wgs-pika/filter-vcf/pika_10pop_noLDprune.vcf.gz \
    -OutStat pika_73ind_LDdecay.stat.gz

# Plot LD decay
echo "Plotting linkage disequilibrium decay..."
perl ~/programs/PopLDdecay/bin/Plot_OnePop.pl \
    -inFile pika_73ind_LDdecay.stat.gz \
    -output pika_73ind_LDdecay_plot

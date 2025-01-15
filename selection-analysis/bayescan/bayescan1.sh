#!/bin/bash
#SBATCH --job-name=bayescan1
#SBATCH --output=bayescan1-results3/slurmout/bayescan1-%j.out
#SBATCH --error=bayescan1-results3/slurmout/bayescan1-%j.err

#SBATCH --ntasks=1
#SBATCH --array=46-70
#SBATCH --cpus-per-task=28
#SBATCH --mem=64GB

# --------------------------- #
# BayeScan Analysis
# --------------------------- #
# This script runs BayeScan in parallel using SLURM array jobs
# on multiple subsets of genetic data in GESTE format.
#
# Requirements: BayeScan installed and executable
#
# Data: GESTE files
#
# Usage:
# - Run this script sequentially three times with different SLURM array ranges and output directories
# - Adjust the '--array' range, '--output', '--error', and BayeScan output directory accordingly
#   - SLURM array ranges: 1-20, 21-45, 46-70 
# --------------------------- #

# --------------------------- #
# Set up working directory
# --------------------------- #
DIR=~/selection-analysis
cd $DIR/bayescan/geste-files

# --------------------------- #
# Prepare input file
# --------------------------- #
# Create a sample sheet with the GESTE files
ls *.geste > subsamples.txt
subsamples=subsamples.txt

# Select the file for the current SLURM task based on the array index
f=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $subsamples)
echo "Processing file: $f"

# --------------------------- #
# Run BayeScan
# --------------------------- #
~/programs/BayeScan2.1/binaries/BayeScan2.1_linux64bits \
    $f \
    -od $DIR/bayescan/bayescan1-results3 \
    -pr_odds 100

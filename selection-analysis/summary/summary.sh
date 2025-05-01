#!/bin/bash
#SBATCH --job-name=summary
#SBATCH --output=slurmout/summary-%j.out
#SBATCH --error=slurmout/summary-%j.err

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# Load conda environment with required dependencies
source ~/.bashrc
conda activate pika

# Compare outlier overlap
Rscript summary.R

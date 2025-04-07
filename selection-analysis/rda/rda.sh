#!/bin/bash
#SBATCH --job-name=rda
#SBATCH --output=slurmout/rda-%j.out
#SBATCH --error=slurmout/rda-%j.err

#SBATCH --partition=himem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=500GB

# Load conda environment with required dependencies
source ~/.bashrc
conda activate pika

# Execute R script for RDA analysis
Rscript rda1.R

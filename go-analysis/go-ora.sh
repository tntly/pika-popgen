#!/bin/bash
#SBATCH --job-name=go-ora
#SBATCH --output=slurmout/go-ora-%j.out
#SBATCH --error=slurmout/go-ora-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# Load conda environment with required dependencies
source ~/.bashrc
conda activate pika

# Set working directory
DIR=~/go-analysis
cd $DIR

# Execute R script for GO term enrichment analysis
Rscript go-ora.R

# Extract gene names from prioritized genes CSV
sed '1d' go-ora-results/go_ora_prioritized_genes.csv | cut -d ',' -f 1 > go-ora-results/go_ora_prioritized_genes.txt

# Extract gene names from Schmidt and Russello (2025) data
sed '1d' data/schmidt_russello_2025_genes.csv |  cut -d ',' -f 3 > data/schmidt_russello_2025_genes.txt

# Find overlapping genes between both datasets
comm -12 <(sort go-ora-results/go_ora_prioritized_genes.txt) <(sort data/schmidt_russello_2025_genes.txt)

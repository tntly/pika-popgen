#!/bin/bash
#SBATCH --job-name=baypass
#SBATCH --output=slurmout/baypass-%j.out
#SBATCH --error=slurmout/baypass-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# BayPass Analysis Pipeline
# --------------------------- #
# This script prepares genetic data and runs BayPass for genotype-environment association analysis
#
# Requirements: PLINK, BayPass
#
# Data:
# - PED file: pika_73ind_4.8Msnp_10pop.ped
# - Metadata file: pika_10pop_metadata.txt
# --------------------------- #

# --------------------------- #
# Prepare input files
# --------------------------- #
# Set working directory
DIR=~/outlier-analysis
cd $DIR/baypass

# Reorder metadata columns to match PLINK format (POP first, IND second)
awk '{print $2 "\t" $1}' $DIR/data/pika_10pop_metadata.txt > pika_10pop_metadata_POPIND.txt

# Remove the first two columns (family ID and individual ID) from the PED file
cut -d ' ' -f 3- $DIR/data/pika_73ind_4.8Msnp_10pop.ped > x.delete

# Merge reordered metadata with the modified PED file
paste pika_10pop_metadata_POPIND.txt x.delete > pika_73ind_4.8Msnp_10pop.ped
rm x.delete

# Copy required PLINK files
cp $DIR/data/pika_73ind_4.8Msnp_10pop.map .
cp $DIR/data/pika_73ind_4.8Msnp_10pop.log .

# Calculate allele frequencies Using PLINK
~/programs/plink_linux_x86_64_20240818/plink \
  --file pika_73ind_4.8Msnp_10pop \
  --allow-extra-chr --freq --family \
  --out pika_73ind_4.8Msnp_10pop

# Convert PLINK output to BayPass format
# - Extract relevant columns and format allele counts
# - Each population's reference and alternative allele counts are processed
# - Output a single file formatted for BayPass
echo "Creating genotype data file in Baypass format..."
tail -n +2 pika_73ind_4.8Msnp_10pop.frq.strat | \
  awk '{$9 = $8 - $7} 1' | \
  awk '{print $7, $9}' | \
  tr "\n" " " | \
  sed 's/ /\n/20; P; D' > pika_10pop_geno_baypass.txt

# --------------------------- #
# Run BayPass core model to generate covariance matrix
# --------------------------- #
~/programs/baypass_public-master/sources/g_baypass \
  -npop 10 \
  -gfile pika_10pop_geno_baypass.txt \
  -outprefix baypass-results/pika_10pop_baypass \
  -nthreads 16

#!/bin/bash
#SBATCH --job-name=baypass
#SBATCH --output=slurmout/baypass-%j.out
#SBATCH --error=slurmout/baypass-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# BayPass Analysis
# --------------------------- #
# This script prepares genetic data and runs BayPass for genotype-environment association analysis.
#
# Requirements: PLINK, BayPass
#
# Data:
# - PED file: pika_73ind_4.8Msnp_10pop.ped
# - Metadata files: pika_10pop_metadata.txt, pika_10pop_SNPs.txt
# - Environmental data files: pika_10pop_env1_baypass.txt, pika_10pop_env2_baypass.txt
# --------------------------- #

# --------------------------- #
# Prepare genotype data file
# --------------------------- #
# Set working directory
DIR=~/selection-analysis
cd $DIR/baypass

# Reorder metadata columns to match PLINK format (POP first, IND second)
awk '{print $2, $1}' $DIR/data/pika_10pop_metadata.txt > pika_10pop_metadata_POPIND.txt

# Remove the first two columns (family ID and individual ID) from the PED file
cut -d ' ' -f 3- $DIR/data/pika_73ind_4.8Msnp_10pop.ped > x.delete

# Merge reordered metadata with the modified PED file
paste -d ' ' pika_10pop_metadata_POPIND.txt x.delete > pika_73ind_4.8Msnp_10pop.ped
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
# Run BayPass core model
# --------------------------- #
# This step estimates the covariance matrix using the core model
~/programs/baypass_public-master/sources/g_baypass \
  -npop 10 \
  -gfile pika_10pop_geno_baypass.txt \
  -outprefix baypass-results/pika_10pop_baypass \
  -nthreads 16

# --------------------------- #
# Run BayPass under the AUX covariate model
# --------------------------- #
# GEA analysis 1: Using ppt_sum, vpdmin_min, and elev as covariates
~/programs/baypass_public-master/sources/g_baypass \
  -npop 10 \
  -gfile pika_10pop_geno_baypass.txt \
  -efile pika_10pop_env1_baypass.txt \
  -auxmodel \
  -omegafile baypass-results/pika_10pop_baypass_mat_omega.out \
  -outprefix baypass-results/pika_10pop_baypass_gea1 \
  -nthreads 16

# GEA analysis 2: Using ppt_sum, vpdmin_min, and winter_tmax_max as covariates
~/programs/baypass_public-master/sources/g_baypass \
  -npop 10 \
  -gfile pika_10pop_geno_baypass.txt \
  -efile pika_10pop_env2_baypass.txt \
  -auxmodel \
  -omegafile baypass-results/pika_10pop_baypass_mat_omega.out \
  -outprefix baypass-results/pika_10pop_baypass_gea2 \
  -nthreads 16

# --------------------------- #
# Filter outliers with estimated Bayes Factors > 25
# --------------------------- #
# Filter outliers for GEA analysis 1
echo "Filtering outliers with Bayes Factors > 25..."
cat baypass-results/pika_10pop_baypass_gea1_summary_betai.out | \
  awk '$6 > 25' > baypass-results/pika_baypass_gea1_BF25.txt

# Filter outliers for GEA analysis 2
cat baypass-results/pika_10pop_baypass_gea2_summary_betai.out | \
  awk '$6 > 25' > baypass-results/pika_baypass_gea2_BF25.txt

# --------------------------- #
# Identify outlier SNP IDs
# --------------------------- #
# Match filtered outliers from GEA 1 with SNP IDs
echo "Matching outlier SNP line numbers with SNP IDs..."
awk 'FNR == NR {a[$2]; next} (($4) in a)' \
  baypass-results/pika_baypass_gea1_BF25.txt \
  $DIR/data/pika_10pop_SNPs.txt | \
  cut -f 3 > baypass-results/pika_baypass_gea1_outlier_SNPIDs.txt

# Match filtered outliers from GEA 2 with SNP IDs
awk 'FNR == NR {a[$2]; next} (($4) in a)' \
  baypass-results/pika_baypass_gea2_BF25.txt \
  $DIR/data/pika_10pop_SNPs.txt | \
  cut -f 3 > baypass-results/pika_baypass_gea2_outlier_SNPIDs.txt

# --------------------------- #
# Identify outlier SNP IDs for vpdmin_min from GEA 2
# --------------------------- #
# Filter outliers for vpdmin_min
echo "Filtering outliers for vpdmin_min from GEA 2..."
cat baypass-results/pika_baypass_gea2_BF25.txt | \
  awk '$1 == 2' > baypass-results/pika_baypass_gea2_BF25_vpdmin_min.txt

# Match filtered outliers for vpdmin_min with SNP IDs
echo "Matching outlier SNP line numbers with SNP IDs for vpdmin_min..."
awk 'FNR == NR {a[$2]; next} (($4) in a)' \
  baypass-results/pika_baypass_gea2_BF25_vpdmin_min.txt \
  $DIR/data/pika_10pop_SNPs.txt | \
  cut -f 3 > baypass-results/pika_baypass_gea2_vpdmin_min_outlier_SNPIDs.txt
  
#!/bin/bash
#SBATCH --job-name=pcadapt
#SBATCH --output=/home/tly/outlier-analysis/results/pcadapt/pcadapt-%j.out
#SBATCH --error=/home/tly/outlier-analysis/results/pcadapt/pcadapt-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# Load modules required for script commands
module purge
module load R-4.3.1

# Step 1: Unzip VCF file if needed
# zcat /home/tly/outlier-analysis/data/Final_CtoT_GtoA_SNP.vcf.gz > \
# /home/tly/outlier-analysis/data/Final_CtoT_GtoA_SNP.vcf

# Step 2: Convert VCF file to BED format using PLINK
# /home/tly/programs/plink_linux_x86_64_20240818/plink \
# --vcf /home/tly/outlier-analysis/data/Final_CtoT_GtoA_SNP.vcf \
# --make-bed --allow-extra-chr --const-fid \
# --out /home/tly/outlier-analysis/data/Final_CtoT_GtoA_SNP

# Step 3: Execute R script for pcadapt analysis
Rscript /home/tly/outlier-analysis/scripts/pcadapt.R

# Step 4
# Extract lines that don't start with '#' from the VCF file
# Cut the first 3 columns (CHROM, POS, ID)
# Use awk to add a 4th column with line numbers (NR) and save the output to a new file
grep -v "^#" /home/tly/outlier-analysis/data/Final_CtoT_GtoA_SNP.vcf | \
cut -f 1-3 | \
awk '{print $0 "\t" NR}' > /home/tly/outlier-analysis/data/pika_10populations_SNPs.txt

# Step 5
# Skip the header line and extract the 2nd column (outlier SNP numbers) from the pcadapt output
# Save the results to a new file
awk 'NR > 1 {print $2}' /home/tly/outlier-analysis/results/pcadapt/pikas_pcadapt_outliers.txt > \
/home/tly/outlier-analysis/results/pcadapt/pikas_pcadapt_outliers_numbers.txt

# Step 6
# Match outlier SNP numbers (from the 1st file) with the corresponding entries in the 2nd file (pika_10populations_SNPs.txt)
# Then, cut and save the 3rd column (SNP IDs) to a new file
awk 'FNR == NR {a[$1]; next} (($4) in a)' \
/home/tly/outlier-analysis/results/pcadapt/pikas_pcadapt_outliers_numbers.txt \
/home/tly/outlier-analysis/data/pika_10populations_SNPs.txt | \
cut -f 3 > /home/tly/outlier-analysis/results/pcadapt/pcadapt_outlierSNPIDs.txt

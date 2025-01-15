#!/bin/bash
#SBATCH --job-name=vcf-to-bayescan
#SBATCH --output=slurmout/vcf-to-bayescan-%j.out
#SBATCH --error=slurmout/vcf-to-bayescan-%j.err

#SBATCH --partition=himem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=256GB

# --------------------------- #
# VCF to BayeScan Conversion
# --------------------------- #
# This script converts VCF files to the BayeScan format using PGDSpider.
#
# Requirements: PGDSpider
#
# Data: VCF files
# --------------------------- #

# --------------------------- #
# Set up working directory
# --------------------------- #
DIR=~/selection-analysis
cd $DIR/vcf-subsample/pika-vcf-70-subsamples

# --------------------------- #
# Create sample sheet
# --------------------------- #
ls *.vcf > subsamples.txt
subsamples=subsamples.txt

# --------------------------- #
# Convert VCF files to BayeScan format
# --------------------------- #
num_subsamples=$(wc -l < $subsamples)
for i in $(seq 1 $num_subsamples); do
  # Get the VCF file name for the current iteration
  f=$(sed -n "${i}p" $subsamples)
  echo "Processing file: $f"

  # Remove the .vcf extension to get the subsample name
  name=$(basename "$f" .vcf)
  echo "Sample name: $name"

  # Define the output file path
  output="$DIR/bayescan/geste-files/${name}.geste"
  echo "Output path: $output"

  # Convert the VCF file using PGDSpider
  java -Xmx1024m -Xms512m -jar ~/programs/PGDSpider_3.0.0.0/PGDSpider3-cli.jar \
    -inputfile "$f" -inputformat VCF \
    -outputfile "$output" -outputformat GESTE_BAYE_SCAN \
    -spid $DIR/bayescan/vcf-to-bayescan/vcf_to_bayescan.spid
done

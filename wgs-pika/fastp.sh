#!/bin/bash
#SBATCH --job-name fastp
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/fastp/fastp-%j.out

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --array 1-5
#SBATCH --mem 64GB

# Change directories to where the fastq files are located
cd /home/tly/wgs-pika/modern/modern-samples/

# Create the sample sheet
# paste <(ls *R1*) <(ls *R2*) > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/modern/modern-samples/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/modern/results/fastp/"

# Load modules required for script commands
module purge
module load intel-python3

# Construct the names of the paired-end files
# CUMV_20322_S32_L006_R1_001.fastq.gz  
f1=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples | awk '{print $1}')
echo $f1
# CUMV_20322_S32_L006_R2_001.fastq.gz
f2=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples | awk '{print $2}')
echo $f2

# Extract the sample names
# CUMV_20322
name=$(echo $f1 | awk -F_ '{print $1"_"$2}')
echo $name

# Define the file paths for the output files
output_f1="${output_dir}trimmed_${f1}"
echo $output_f1
output_f2="${output_dir}trimmed_${f2}"
echo $output_f2

# Define the file paths for the HTML and JSON files
json="${output_dir}reports/${name}.json"
echo $json
html="${output_dir}reports/${name}.html"
echo $html

# Run fastp
fastp \
-i $f1 -I $f2 \
-o $output_f1 -O $output_f2 \
-j $json -h $html \
-w $SLURM_CPUS_PER_TASK

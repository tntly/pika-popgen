#!/bin/bash
#SBATCH --job-name bwa-map
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/bwa-map/bwa-map-%j.out
#SBATCH --error /home/tly/wgs-pika/modern/scripts/slurm-outputs/bwa-map/bwa-map-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --array 1-5
#SBATCH --mem 64GB

# Load modules required for script commands
module purge
module load bwa

# Change directories to where the trimmed fastq files are located
cd /home/tly/wgs-pika/modern/results/fastp/

# Create the sample sheet
# paste <(ls *R1*) <(ls *R2*) > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/modern/results/fastp/samples.txt"

# Define the reference genome
ref_genome="/home/tly/wgs-pika/reference/GCA_014633375.1_OchPri4.0_genomic.fna"

# Define the output directory
output_dir="/home/tly/wgs-pika/modern/results/bwa-map/"

# Index the genome assembly
# bwa index $ref_genome

# Construct the names of the paired-end files
# trimmed_CUMV_20322_S32_L006_R1_001.fastq.gz 
f1=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples | awk '{print $1}') 
echo $f1
# trimmed_CUMV_20322_S32_L006_R2_001.fastq.gz
f2=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples | awk '{print $2}')
echo $f2

# Extract the sample names
# trimmed_CUMV_20322
name=$(echo $f1 | awk -F_ '{print $1"_"$2"_"$3}')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "bwa mem -t $SLURM_CPUS_PER_TASK $ref_genome $f1 $f2 > ${output}.sam"

bwa mem -t $SLURM_CPUS_PER_TASK $ref_genome $f1 $f2 > ${output}.sam

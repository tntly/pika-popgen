#!/bin/bash
#SBATCH --job-name bwa
#SBATCH --output bwa-%j.out
#SBATCH --error bwa-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --array 1-10

#SBATCH --mem 100GB

# Load modules required for script commands
module purge
module load bwa

# Change directories to where the fastp (trimmed) files are located
cd /home/tly/wgs-pika/results/fastp/

# Create the sample sheet
# paste <(ls *R1*) <(ls *R2*) > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/results/fastp/samples.txt"

# Define the reference genome
ref_genome="/home/tly/wgs-pika/reference/GCF_014633375.1_OchPri4.0_genomic.fna"

# Define the output directory
output_dir="/home/tly/wgs-pika/results/bwa-sam/"

# Index the genome assembly
# bwa index $ref_genome

# Construct the names of the paired-end files
# trimmed_27552_S1_L004_R1_001.fastq.gz
f1=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples | awk '{print $1}') 
# trimmed_27552_S1_L004_R2_001.fastq.gz
f2=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples | awk '{print $2}')
echo $f1
echo $f2

# Extract the sample names
# trimmed_27552_S1
name=$(echo $f1 | sed 's/_L004_R1_001.fastq.gz//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "bwa mem -t $SLURM_CPUS_PER_TASK $ref_genome $f1 $f2 > ${output}.sam"

bwa mem -t $SLURM_CPUS_PER_TASK $ref_genome $f1 $f2 > ${output}.sam

#!/bin/bash
#SBATCH --job-name bwa
#SBATCH --output bwa-%j.out
#SBATCH --error bwa-%j.err
#SBATCH --cpus-per-task 16
#SBATCH --mem 100GB

# Change directories to where the fastp (trimmed) files are located
cd /home/tly/wgs-pika/results/trimmed-fastp/

# Define the reference genome
ref_genome="/home/tly/wgs-pika/reference/GCF_014633375.1_OchPri4.0_genomic.fna"

# Define the output directory
output_dir="/home/tly/wgs-pika/results/mappings-bwa/"

# Load modules required for script commands
module purge
module load bwa

# Index the genome assembly
# bwa index $ref_genome

# Construct the names of the first paired-end files
# trimmed_27552_S1_L004_R1_001.fastq.gz
for f1 in *_L004_R1_001.fastq.gz
do
  # Construct the names of the second paired-end files
  # trimmed_27552_S1_L004_R2_001.fastq.gz
  f2=$(echo $f1 | sed 's/_R1_/_R2_/')

  # Extract the sample names
  # trimmed_27552_S1
  name=$(echo $f1 | sed 's/_L004_R1_001.fastq.gz//')

  # Define the file path for the output file
  output="${output_dir}${name}"
  
  # Run bwa mem
  bwa mem -t $SLURM_CPUS_PER_TASK $ref_genome \
  $f1 $f2 > ${ouput}.sam
done

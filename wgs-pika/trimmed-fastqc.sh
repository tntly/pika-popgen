#!/bin/bash
#SBATCH --job-name trimmed-fastqc
#SBATCH --output trimmed-fastqc-%j.out
#SBATCH --cpus-per-task 16
#SBATCH --mem 100GB

# Change directories to where the fastp files are located
cd /home/tly/wgs-pika/results/fastp/

# Load modules required for script commands
module purge
module load fastqc

# Run FastQC
fastqc -o /home/tly/wgs-pika/results/trimmed-fastqc/ -t $SLURM_CPUS_PER_TASK *.fastq.gz

#!/bin/bash
#SBATCH --job-name fastqc
#SBATCH --output fastqc-%j.out
#SBATCH --cpus-per-task 8
#SBATCH --mem 10G

# Change directories to where the fastq files are located
cd /home/tly/wgs-pika/samples

# Load modules required for script commands
module purge
module load fastqc

# Run FastQC
fastqc -o /home/tly/wgs-pika/results/fastqc/ -t ${SLURM_CPUS_PER_TASK} *.fastq.gz
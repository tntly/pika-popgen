#!/bin/bash
#SBATCH --job-name fastqc
#SBATCH --cpus-per-task 8
#SBATCH --mem 8G

# Change directories to where the fastq files are located
cd /home/tly/wgs_pika/samples

# Load modules required for script commands
module purge
module load fastqc

# Run FastQC
fastqc -o /home/tly/wgs_pika/results/fastqc/ -t ${SLURM_CPUS_PER_TASK} *.fastq.gz
 

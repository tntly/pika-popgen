#!/bin/bash
#SBATCH --job-name fastqc
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/fastqc/fastqc-%j.out
#SBATCH --error /home/tly/wgs-pika/modern/scripts/slurm-outputs/fastqc/fastqc-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 64GB

# Change directories to where the fastq files are located
cd /home/tly/wgs-pika/modern/modern-samples/

# Load modules required for script commands
module purge
module load fastqc

# Run FastQC
fastqc -o /home/tly/wgs-pika/modern/results/fastqc/ -t $SLURM_CPUS_PER_TASK *.fastq.gz

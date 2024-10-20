#!/bin/bash
#SBATCH --job-name fastqc
#SBATCH --output fastqc-%j.out
#SBATCH --error fastqc-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 100GB

# Change directories to where the fastq files are located
cd /home/tly/wgs-pika/samples/

# Load modules required for script commands
module purge
module load fastqc

# Run FastQC
fastqc -o /home/tly/wgs-pika/results/fastqc/ -t $SLURM_CPUS_PER_TASK *.fastq.gz

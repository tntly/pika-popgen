#!/bin/bash
#SBATCH --job-name trimmed-multiqc
#SBATCH --output trimmed-multiqc-%j.out
#SBATCH --cpus-per-task 16
#SBATCH --mem 100GB

# Change directories to where the MultiQC report will be located
cd /home/tly/wgs-pika/results/trimmed-multiqc/

# Load modules required for script commands
module purge
module load intel-python3

# Run MultiQC
multiqc /home/tly/wgs-pika/results/trimmed-fastqc/

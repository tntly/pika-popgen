#!/bin/bash
#SBATCH --job-name trimmed-multiqc
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/trimmed-multiqc/trimmed-multiqc-%j.out
#SBATCH --error /home/tly/wgs-pika/modern/scripts/slurm-outputs/trimmed-multiqc/trimmed-multiqc-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 64GB

# Change directories to where the trimmed MultiQC report will be located
cd /home/tly/wgs-pika/modern/results/trimmed-multiqc

# Load modules required for script commands
module purge
module load intel-python3

# Run MultiQC
multiqc /home/tly/wgs-pika/modern/results/trimmed-fastqc

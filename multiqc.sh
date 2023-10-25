#!/bin/bash
#SBATCH --job-name multiqc
#SBATCH --output multiqc-%j.out
#SBATCH --mem 10G

# Change directories to where the MultiQC report will be located
cd /home/tly/wgs-pika/results/multiqc/

# Load modules required for script commands
module purge
module load intel-python3

# Run MultiQC
multiqc /home/tly/wgs-pika/results/fastqc/
#!/bin/bash
#SBATCH --job-name multiqc

# Change directories to where the MultiQC report will be located
cd /home/tly/wgs_pika/results/multiqc/

# Load modules required for script commands
module purge
module load intel-python3

# Run MultiQC
multiqc /home/tly/wgs_pika/results/fastqc/
#!/bin/bash
#SBATCH --job-name bam-trans
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/bam-trans/bam-trans-%j.out
#SBATCH --error /home/tly/wgs-pika/modern/scripts/slurm-outputs/bam-trans/bam-trans-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --array 1-5
#SBATCH --mem 64GB

# Load modules required for script commands
module purge
module load samtools

# Change directories to where the sam files are located
cd /home/tly/wgs-pika/modern/results/bwa-map/

# Create the sample sheet
# ls *.sam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/modern/results/bwa-map/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/modern/results/bam-trans/"

# Get the file names
# trimmed_CUMV_20322.sam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_CUMV_20322
name=$(echo $f | sed 's/.sam//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "samtools view $f -bo ${output}.bam"

samtools view $f -bo ${output}.bam

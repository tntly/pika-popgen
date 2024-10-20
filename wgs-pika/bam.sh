#!/bin/bash
#SBATCH --job-name bam
#SBATCH --output bam-%j.out
#SBATCH --error bam-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --array 1-20

#SBATCH --mem 100GB

# Load modules required for script commands
module purge
module load samtools

# Change directories to where the sam files are located
cd /home/tly/wgs-pika/results/bwa-sam/

# Create the sample sheet
# ls *.sam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/results/bwa-sam/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/results/bam/"

# Get the file names
# trimmed_27552_S1.sam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_27552_S1
name=$(echo $f | sed 's/.sam//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "samtools view $f -b -o ${output}.bam"

samtools view $f -b -o ${output}.bam

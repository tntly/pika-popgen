#!/bin/bash
#SBATCH --job-name SortSam
#SBATCH --output sort-bam-%j.out
#SBATCH --error sort-bam-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --array 1-20

#SBATCH --mem 100GB

# Load modules required for script commands
module purge

# Change directories to where the bam files are located
cd /home/tly/wgs-pika/results/bam/

# Create the sample sheet
# ls *.bam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/results/bam/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/results/sorted-bam/"

# Get the file names
# trimmed_27552_S1.bam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_27552_S1
name=$(echo $f | sed 's/.bam//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "java -jar /opt/picard/picard.jar SortSam -I $f -O ${output}_sorted.bam -SO queryname --TMP_DIR /gpfs/scratch/tly"

java -jar /opt/picard/picard.jar SortSam \
-I $f -O ${output}_sorted.bam \
-SO queryname --TMP_DIR /gpfs/scratch/tly

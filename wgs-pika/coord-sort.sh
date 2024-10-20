#!/bin/bash
#SBATCH --job-name SortSam
#SBATCH --output coord-sort-%j.out
#SBATCH --error coord-sort-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --array 1-20

#SBATCH --mem 100GB

# Load modules required for script commands
module purge

# Change directories to where the mark-dup bam files are located
cd /home/tly/wgs-pika/results/mark-dup/

# Create the sample sheet
# ls *.bam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/results/mark-dup/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/results/coord-sort/"

# Get the file names
# trimmed_27552_S1_marked.bam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_27552_S1
name=$(echo $f | sed 's/_marked.bam//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "java -jar /opt/picard/picard.jar SortSam -I $f -O ${output}_marked_CS.bam -SO coordinate --CREATE_INDEX --TMP_DIR /gpfs/scratch/tly"

java -jar /opt/picard/picard.jar SortSam \
-I $f -O ${output}_marked_CS.bam \
-SO coordinate --CREATE_INDEX --TMP_DIR /gpfs/scratch/tly

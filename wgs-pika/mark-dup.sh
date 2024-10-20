#!/bin/bash
#SBATCH --job-name mark-dup
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/mark-dup/mark-dup-%j.out
#SBATCH --error /home/tly/wgs-pika/modern/scripts/slurm-outputs/mark-dup/mark-dup-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --array 1-5
#SBATCH --mem 64GB

# Load modules required for script commands
module purge

# Change directories to where the read-group bam files are located
cd /home/tly/wgs-pika/modern/results/read-groups/

# Create the sample sheet before running the script
# ls *.bam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/modern/results/read-groups/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/modern/results/mark-dup/"

# Get the file names
# trimmed_CUMV_20322_RG.bam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_CUMV_20322
name=$(echo $f | sed 's/_RG.bam//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "java -jar /opt/picard/picard.jar MarkDuplicates -I $f -O ${output}_marked.bam -M ${output}_metrics.txt --TMP_DIR /gpfs/scratch/tly"

java -jar /opt/picard/picard.jar MarkDuplicates \
-I $f -O ${output}_marked.bam -M ${output}_metrics.txt \
--TMP_DIR /gpfs/scratch/tly

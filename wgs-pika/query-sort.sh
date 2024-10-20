#!/bin/bash
#SBATCH --job-name query-sort
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/query-sort/query-sort-%j.out
#SBATCH --error /home/tly/wgs-pika/modern/scripts/slurm-outputs/query-sort/query-sort-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --array 1-5
#SBATCH --mem 64GB

# Load modules required for script commands
module purge

# Change directories to where the bam files are located
cd /home/tly/wgs-pika/modern/results/bam-trans/

# Create the sample sheet
# ls *.bam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/modern/results/bam-trans/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/modern/results/query-sort/"

# Get the file names
# trimmed_CUMV_20322.bam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_CUMV_20322
name=$(echo $f | sed 's/.bam//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "java -jar /opt/picard/picard.jar SortSam -I $f -O ${output}_QS.bam -SO queryname --TMP_DIR /gpfs/scratch/tly"

java -jar /opt/picard/picard.jar SortSam \
-I $f -O ${output}_QS.bam \
-SO queryname --TMP_DIR /gpfs/scratch/tly

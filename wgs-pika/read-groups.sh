#!/bin/bash
#SBATCH --job-name AddOrReplaceReadGroups
#SBATCH --output read_groups-%j.out
#SBATCH --error read_groups-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --array 1-20

#SBATCH --mem 100GB

# Load modules required for script commands
module purge

# Change directories to where the sorted bam files are located
cd /home/tly/wgs-pika/results/sorted-bam/

# Create the sample sheet
# ls *.bam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/results/sorted-bam/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/results/read-groups/"

# Get the file names
# trimmed_27552_S1_sort.bam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_27552_S1
name=$(echo $f | sed 's/_sort.bam//')
echo $name
# S1
SM=$(echo $name | awk -F_ '{print $NF}')
echo $SM

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "java -jar /opt/picard/picard.jar AddOrReplaceReadGroups -I $f -O ${output}_RG.bam -LB lib1 -PL ILLUMINA -PU BC005 -SM $SM"

java -jar /opt/picard/picard.jar AddOrReplaceReadGroups \
-I $f -O ${output}_RG.bam \
-LB lib1 -PL ILLUMINA -PU BC005 -SM $SM

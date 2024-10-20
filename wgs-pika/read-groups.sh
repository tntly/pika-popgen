#!/bin/bash
#SBATCH --job-name read-groups
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/read-groups/read-groups-%j.out
#SBATCH --error /home/tly/wgs-pika/modern/scripts/slurm-outputs/read-groups/read-groups-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --array 1-5
#SBATCH --mem 64GB

# Load modules required for script commands
module purge

# Change directories to where the sorted bam files are located
cd /home/tly/wgs-pika/modern/results/query-sort/

# Create the sample sheet
# ls *.bam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/modern/results/query-sort/samples.txt"

# Define the output directory
output_dir="/home/tly/wgs-pika/modern/results/read-groups/"

# Get the file names
# trimmed_CUMV_20322_QS.bam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# ttrimmed_CUMV_20322
name=$(echo $f | sed 's/_QS.bam//')
echo $name
# 20322
SM=$(echo $name | awk -F_ '{print $NF}')
echo $SM

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "java -jar /opt/picard/picard.jar AddOrReplaceReadGroups -I $f -O ${output}_RG.bam -LB lib1 -PL ILLUMINA -PU BC005 -SM $SM"

java -jar /opt/picard/picard.jar AddOrReplaceReadGroups \
-I $f -O ${output}_RG.bam \
-LB lib1 -PL ILLUMINA -PU BC005 -SM $SM

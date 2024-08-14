#!/bin/bash
#SBATCH --job-name HaplotypeCaller
#SBATCH --output haplotype-%j.out
#SBATCH --error haplotype-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --array 1-20

#SBATCH --mem 100GB

# Load modules required for script commands
module purge
module load gatk

# Change directories to where the coord-sort bam files are located
cd /home/tly/wgs-pika/results/coord-sort/

# Create the sample sheet
# ls *.bam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/results/coord-sort/samples.txt"

# Define the reference genome
ref_genome="/home/tly/wgs-pika/reference/GCF_014633375.1_OchPri4.0_genomic.fna"

# Define the output directory
output_dir="/home/tly/wgs-pika/results/haplotype/"

# Get the file names
# trimmed_27552_S1_marked_CS.bam 
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_27552_S1
name=$(echo $f | sed 's/_marked_CS.bam//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "gatk --java-options "-Xmx40g" HaplotypeCaller -R $ref_genome -I $f -O ${output}.g.vcf.gz -ERC GVCF --tmp-dir /gpfs/scratch/tly"

gatk --java-options "-Xmx40g" HaplotypeCaller \
-R $ref_genome -I $f -O ${output}.g.vcf.gz \
-ERC GVCF --tmp-dir /gpfs/scratch/tly

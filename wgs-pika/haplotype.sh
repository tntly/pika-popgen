#!/bin/bash
#SBATCH --job-name haplotype
#SBATCH --output /home/tly/wgs-pika/modern/scripts/slurm-outputs/haplotype/haplotype-%j.out
#SBATCH --error /home/tly/wgs-pika/modern/scripts/slurm-outputs/haplotype/haplotype-%j.err

#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --array 1-5
#SBATCH --mem 64GB

# Load modules required for script commands
module purge
module load gatk

# Change directories to where the coord-sort bam files are located
cd /home/tly/wgs-pika/modern/results/coord-sort/

# Create the sample sheet
# ls *.bam > samples.txt
# Define the sample sheet
samples="/home/tly/wgs-pika/modern/results/coord-sort/samples.txt"

# Define the reference genome
ref_genome="/home/tly/wgs-pika/reference/GCA_014633375.1_OchPri4.0_genomic.fna"

# Define the output directory
output_dir="/home/tly/wgs-pika/modern/results/haplotype/"

# Get the file names
# trimmed_CUMV_20322_marked_CS.bam
f=$(sed -n "$SLURM_ARRAY_TASK_ID"p $samples)
echo $f

# Extract the sample names
# trimmed_CUMV_20322
name=$(echo $f | sed 's/_marked_CS.bam//')
echo $name

# Define the file path for the output file
output="${output_dir}${name}"
echo $output

echo "gatk --java-options "-Xmx40g" HaplotypeCaller -R $ref_genome -I $f -O ${output}_haplotype.g.vcf.gz -ERC GVCF --tmp-dir /gpfs/scratch/tly"

gatk --java-options "-Xmx40g" HaplotypeCaller \
-R $ref_genome -I $f -O ${output}_haplotype.g.vcf.gz \
-ERC GVCF --tmp-dir /gpfs/scratch/tly

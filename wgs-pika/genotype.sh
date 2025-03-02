#!/bin/bash
#SBATCH --job-name genotype
#SBATCH --output slurmout/genotype-%j.out
#SBATCH --error slurmout/genotype-%j.err

#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 64GB

# Set paths
gatk=~/programs/gatk-4.4.0.0/gatk
ref_genome=~/wgs-pika/reference/GCA_014633375.1_OchPri4.0_genomic.fna
tmp_dir=/scratch/tly

# Create database with samples
gvcf_list=samples.txt   # list of gVCF files (one per line)

$gatk --java-options "-Xmx8g -Xms8g" GenomicsDBImport \
    $(awk '{print "-V "$1}' $gvcf_list) \
    --genomicsdb-workspace-path wgs_pika_db \
    --tmp-dir $tmp_dir \
    -L CM025721.1 -L CM025722.1 -L CM025723.1 -L CM025724.1 -L CM025725.1 \
    -L CM025726.1 -L CM025727.1 -L CM025728.1 -L CM025729.1 -L CM025730.1 \
    -L CM025731.1 -L CM025732.1 -L CM025733.1 -L CM025734.1 -L CM025735.1 \
    -L CM025736.1 -L CM025737.1 -L CM025738.1 -L CM025739.1 -L CM025740.1 \
    -L CM025741.1 -L CM025742.1 -L CM025746.1 -L CM025747.1 -L CM025748.1 \
    -L CM025749.1 -L CM025750.1 -L CM025751.1 -L CM025752.1 -L CM025753.1 \
    -L CM025743.1 -L CM025744.1 -L CM025745.1 \
    --batch-size 50

Genotype samples
$gatk GenotypeGVCFs -R $ref_genome \
    -V gendb://wgs_pika_db \
    -O pika_10pop.vcf.gz \
    --tmp-dir $tmp_dir

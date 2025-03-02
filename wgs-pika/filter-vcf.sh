#!/bin/bash
#SBATCH --job-name=filter-vcf
#SBATCH --output=slurmout/filter-vcf-%j.out
#SBATCH --error=slurmout/filter-vcf-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# VCF Filtering Pipeline
# --------------------------- #
# This script filters a VCF file to retain only high-quality SNPs
# by applying various filtering criteria, including variant quality filtering,
# biallelic filtering, missing genotype removal, allele frequency filtering,
# and SNP ID annotation.
#
# Requirements: BCFtools, GATK
# --------------------------- #

# --------------------------- #
# Environment Setup
# --------------------------- #
source ~/.bashrc
conda activate pika

# --------------------------- #
# Step 0: Filter variants based on metrics
# --------------------------- #
~/programs/gatk-4.4.0.0/gatk SelectVariants -R ~/wgs-pika/reference/GCA_014633375.1_OchPri4.0_genomic.fna \
    -V ~/wgs-pika/genotype/pika_10pop.vcf.gz \
    -select "QD > 2.0 && FS < 30.0 && SOR < 4.0 && MQ > 50.0 && MQRankSum > -5.0 && ReadPosRankSum > -4.0" \
    --select-type-to-include SNP \
    -O 0_variantcullSNP.vcf.gz

# --------------------------- #
# Step 1: Keep only biallelic SNPs
# --------------------------- #
bcftools view -m 2 -M 2 -v snps -O z -o 1_biallelic_snps.vcf.gz 0_variantcullSNP.vcf.gz
bcftools index -t 1_biallelic_snps.vcf.gz

# --------------------------- #
# Step 2: Remove variants with missing genotype calls
# --------------------------- #
bcftools filter -e 'F_MISSING > 0' -O z -o 2_no_missing.vcf.gz 1_biallelic_snps.vcf.gz
bcftools index -t 2_no_missing.vcf.gz

# --------------------------- #
# Step 3: Apply SNP filtration
# --------------------------- #
# Remove C-to-T and G-to-A SNPs and filter out low allele frequency variants
~/programs/gatk-4.4.0.0/gatk VariantFiltration -R ~/wgs-pika/reference/GCA_014633375.1_OchPri4.0_genomic.fna \
    -V 2_no_missing.vcf.gz \
    --filter-name "G_to_A_SNP" --filter-expression 'vc.getReference().getBaseString() == "G" && vc.getAlternateAllele(0).getBaseString() == "A"' \
    --filter-name "C_to_T_SNP" --filter-expression 'vc.getReference().getBaseString() == "C" && vc.getAlternateAllele(0).getBaseString() == "T"' \
    --filter-name "low_AF" --filter-expression 'AF <= 0.05' \
    -O 3_filtered_snps.vcf.gz

# --------------------------- #
# Step 4: Assign unique SNP IDs based on chromosome and position
# --------------------------- #
bcftools annotate --set-id '%CHROM\_%POS' -O z -o 4_snps_with_IDs.vcf.gz 3_filtered_snps.vcf.gz
bcftools index -t 4_snps_with_IDs.vcf.gz

# --------------------------- #
# Step 5: Keep only SNPs that pass the filtering criteria
# --------------------------- #
bcftools view -f 'PASS,.' -e 'FILTER = "low_AF" | FILTER = "C_to_T_SNP" | FILTER = "G_to_A_SNP"' -O z -o 5_passed_snps.vcf.gz 4_snps_with_IDs.vcf.gz
bcftools index -t 5_passed_snps.vcf.gz

# --------------------------- #
# Step 6: Reheader VCF file with correct sample names
# --------------------------- #
bcftools reheader -s samples_reheader.txt -o 6_reheadered_snps.vcf.gz 5_passed_snps.vcf.gz
bcftools index -t 6_reheadered_snps.vcf.gz

# --------------------------- #
# Step 7: Remove specific samples
# --------------------------- #
bcftools view -s ^58503_MTJE_Historic,208251_YOSE_Modern -O z -o pika_10pop_noLDprune.vcf.gz 6_reheadered_snps.vcf.gz
bcftools index -t pika_10pop_noLDprune.vcf.gz

#!/bin/bash
#SBATCH --job-name=snps-to-genes
#SBATCH --output=slurmout/snps-to-genes-%j.out
#SBATCH --error=slurmout/snps-to-genes-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# SNP-to-Gene Mapping Pipeline
# --------------------------- #
# This script identifies genes within 20kb of outlier SNPs and all SNPs
# using BEDTools and gene annotations from the Ochotona princeps genome.
#
# Requirements: bcftools, bedtools
#
# Data:
# - UCSC alias file: GCF_014633375.1.chromAlias.txt
# - VCF: pika_73ind_4.8Msnp_10pop.vcf
# - Outlier SNP list: double_outliers.txt
# - GFF: GCF_014633375.1_OchPri4.0_genomic.gff
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
source ~/.bashrc
conda activate pika

# --------------------------- #
# Directory setup
# --------------------------- #
DIR=~/go-analysis
cd $DIR/snps-to-genes

# --------------------------- #
# Download and process UCSC chromosome alias file
# --------------------------- #
# For Ochotona princeps genome (OchPri4.0)
wget "https://hgdownload.soe.ucsc.edu/hubs/GCF/014/633/375/GCF_014633375.1/GCF_014633375.1.chromAlias.txt"

# Extract first column (RefSeq ID) and third column (GenBank ID)
tail -n +3 GCF_014633375.1.chromAlias.txt | awk '{print $3 "\t" $1}' > OchPri4.0_genbank_to_refseq_chromAlias.txt
# Convert alias file into sed substitution format
sed 's@\(.*\)\t\(.*\)@s/\1/\2/g@' OchPri4.0_genbank_to_refseq_chromAlias.txt > OchPri4.0_genbank_to_refseq_chromAlias.sed.txt

# --------------------------- #
# Extract and process SNPs
# --------------------------- #
# Extract outlier SNPs
bcftools view --include 'ID=@~/selection-analysis/summary/summary-results/double_outliers.txt' \
    ~/selection-analysis/data/pika_73ind_4.8Msnp_10pop.vcf > pika_outlier_snps_genbank.vcf

# Convert GenBank IDs to RefSeq in SNP VCF
sed -f OchPri4.0_genbank_to_refseq_chromAlias.sed.txt pika_outlier_snps_genbank.vcf > pika_outlier_snps_refseq.vcf

# Convert entire VCF from GenBank to RefSeq
sed -f OchPri4.0_genbank_to_refseq_chromAlias.sed.txt ~/selection-analysis/data/pika_73ind_4.8Msnp_10pop.vcf > \
    pika_73ind_4.8Msnp_10pop_refseq.vcf

# --------------------------- #
# Process GFF for gene annotations
# --------------------------- #
awk -F '\t' '$0 !~ /^#/ && $3 == "gene" && $9 ~ /gene_biotype=protein_coding/' \
    $DIR/data/GCF_014633375.1_OchPri4.0_genomic.gff > GCF_014633375.1_OchPri4.0_genomic_gene_only.gff

# --------------------------- #
# SNP-to-Gene association
# --------------------------- #
# Genes near outlier SNPs
bedtools window -a pika_outlier_snps_refseq.vcf -b GCF_014633375.1_OchPri4.0_genomic_gene_only.gff -w 20000 | \
    awk '{print $(NF)}' | cut -d ';' -f 3 | cut -d '=' -f 2 | sort -u > pika_outlier_genes_20kb.txt

# Genes near all SNPs
bedtools window -a pika_73ind_4.8Msnp_10pop_refseq.vcf -b GCF_014633375.1_OchPri4.0_genomic_gene_only.gff -w 20000 | \
    awk '{print $(NF)}' | cut -d ';' -f 3 | cut -d '=' -f 2 | sort -u > pika_10pop_genes_20kb.txt

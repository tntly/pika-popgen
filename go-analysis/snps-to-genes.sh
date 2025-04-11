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
# - VCF: pika_73ind_4.8Msnp_10pop.vcf
# - Outlier SNP lists:
#   - pcadapt_bayescan_overlapping_outliers.txt
#   - baypass_rda_overlapping_outliers.txt
# - GFF: GCF_014633375.1_OchPri4.0_genomic.gff
# - UCSC alias: GCF_014633375.1.chromAlias.txt
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
# Download and process chromosome alias file
# --------------------------- #
echo "Downloading UCSC chromosome alias file..."
wget "https://hgdownload.soe.ucsc.edu/hubs/GCF/014/633/375/GCF_014633375.1/GCF_014633375.1.chromAlias.txt"

# Create GenBank-to-RefSeq alias mapping
tail -n +3 GCF_014633375.1.chromAlias.txt | awk '{print $3 "\t" $1}' > OchPri4.0_genbank_to_refseq_chromAlias.txt
sed 's@\(.*\)\t\(.*\)@s/\1/\2/g@' OchPri4.0_genbank_to_refseq_chromAlias.txt > OchPri4.0_genbank_to_refseq_chromAlias.sed.txt

# --------------------------- #
# Extract outlier SNPs from VCF
# --------------------------- #
echo "Extracting outlier SNPs..."
bcftools view --include 'ID=@~/selection-analysis/summary/summary-results/pcadapt_bayescan_overlapping_outliers.txt' \
    ~/selection-analysis/data/pika_73ind_4.8Msnp_10pop.vcf > pika_outlier_snps_genbank_pcadapt_bayescan.vcf

bcftools view --include 'ID=@~/selection-analysis/summary/summary-results/baypass_rda_overlapping_outliers.txt' \
    ~/selection-analysis/data/pika_73ind_4.8Msnp_10pop.vcf > pika_outlier_snps_genbank_baypass_rda.vcf

# --------------------------- #
# Convert chromosome IDs to RefSeq
# --------------------------- #
echo "Converting GenBank IDs to RefSeq IDs..."
sed -f OchPri4.0_genbank_to_refseq_chromAlias.sed.txt pika_outlier_snps_genbank_pcadapt_bayescan.vcf > pika_outlier_snps_refseq_pcadapt_bayescan.vcf
sed -f OchPri4.0_genbank_to_refseq_chromAlias.sed.txt pika_outlier_snps_genbank_baypass_rda.vcf > pika_outlier_snps_refseq_baypass_rda.vcf
sed -f OchPri4.0_genbank_to_refseq_chromAlias.sed.txt ~/selection-analysis/data/pika_73ind_4.8Msnp_10pop.vcf > pika_73ind_4.8Msnp_10pop_refseq.vcf

# --------------------------- #
# Extract protein-coding genes from GFF
# --------------------------- #
echo "Filtering GFF for protein-coding genes..."
awk -F '\t' '$0 !~ /^#/ && $3 == "gene" && $9 ~ /gene_biotype=protein_coding/' \
    $DIR/data/GCF_014633375.1_OchPri4.0_genomic.gff > GCF_014633375.1_OchPri4.0_genomic_gene_only.gff

# --------------------------- #
# SNP-to-Gene association
# --------------------------- #
echo "Identifying genes near outlier and all SNPs..."

# Genes near pcadapt & BayeScan outlier SNPs
bedtools window -a pika_outlier_snps_refseq.vcf -b GCF_014633375.1_OchPri4.0_genomic_gene_only.gff -w 20000 | \
    awk '{print $(NF)}' | cut -d ';' -f 3 | cut -d '=' -f 2 | sort -u > pika_outlier_genes_20kb_pcadapt_bayescan.txt

# Genes near BayPass & RDA outlier SNPs
bedtools window -a pika_outlier_snps_refseq_baypass_rda.vcf -b GCF_014633375.1_OchPri4.0_genomic_gene_only.gff -w 20000 | \
    awk '{print $(NF)}' | cut -d ';' -f 3 | cut -d '=' -f 2 | sort -u > pika_outlier_genes_20kb_baypass_rda.txt

# Genes near all SNPs
bedtools window -a pika_73ind_4.8Msnp_10pop_refseq.vcf -b GCF_014633375.1_OchPri4.0_genomic_gene_only.gff -w 20000 | \
    awk '{print $(NF)}' | cut -d ';' -f 3 | cut -d '=' -f 2 | sort -u > pika_10pop_genes_20kb.txt

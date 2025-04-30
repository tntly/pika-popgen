#!/bin/bash
#SBATCH --job-name=eggnot-annot
#SBATCH --output=slurmout/eggnot-annot-%j.out
#SBATCH --error=slurmout/eggnot-annot-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB

# --------------------------- #
# GO Annotation with eggNOG-mapper
# --------------------------- #
# This script annotates protein sequences using eggNOG-mapper.
#
# Requirements: seqkit, eggNOG-mapper
#
# Data:
# - Gene list: pika_10pop_genes_20kb.txt
# - CDS file: GCF_014633375.1_OchPri4.0_cds_from_genomic.fna
# - eggNOG-mapper data: eggnog-mapper-data
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
source ~/.bashrc
conda activate pika

# Set working directory
DIR=~/go-analysis
cd $DIR/go-annotation

# --------------------------- #
# Extract and translate gene sequences to proteins
# --------------------------- #
# Extract background gene sequences
seqkit grep -f $DIR/snps-to-genes/pika_10pop_genes_20kb.txt \
  $DIR/data/GCF_014633375.1_OchPri4.0_cds_from_genomic.fna \
  --id-regexp "\[gene=([^\]]+)\]" -o background_cds.fasta

# Get list of found gene IDs
# seqkit seq background_cds.fasta -n -i --id-regexp "\[gene=([^\]]+)\]" | sort -u

# Translate CDS to proteins
seqkit translate background_cds.fasta -o background_proteins.fasta

# --------------------------- #
# Run eggNOG-mapper
# --------------------------- #
# Download eggNOG data (if not already downloaded)
# download_eggnog_data.py --data_dir eggnog-mapper-data -y

# Run eggNOG-mapper
emapper.py -m diamond \
  --sensmode ultra-sensitive \
  --dmnd_iterate yes \
  --itype proteins \
  --data_dir eggnog-mapper-data \
  -i background_proteins.fasta \
  --output pika_background_proteins \
  --dbmem --cpu 0 \
  --evalue 1e-5

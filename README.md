# Studying Local Adaptations in American Pikas: Variant Calling and Population Genomics Analyses

> Author: Tien Ly  
> Updated: March 2025

## 🚧 Under Construction 🚧

This repository includes scripts and analyses for investigating local adaptations in American pikas as part of my MS Bioinformatics thesis project at San Jose State University. The project is structured into two main components: variant calling and population genomics analyses.

## Project Overview

### Part 1: Variant Calling

In this section, I develop a variant calling pipeline. Key steps include:

1. **Quality Control**:
    - `fastqc.sh`: Assess the quality of raw sequencing data
    - `multiqc.sh`: Summarize quality reports from multiple `fastqc.sh` outputs
   
2. **Data Trimming**:
    - `fastp.sh`: Trim low-quality bases and adapters from the reads
    - `trimmed-fastqc.sh`: Re-assess quality after trimming
    - `trimmed-multiqc.sh`: Summarize the quality of trimmed reads

3. **Read Mapping**:
    - `bwa-map.sh`: Align reads to the reference genome

4. **Post-Processing**:
    - `bam-trans.sh`: Convert SAM files to BAM format
    - `query-sort.sh`: Sort the BAM files by query name
    - `read-groups.sh`: Add read group information
    - `mark-dup.sh`: Mark duplicate reads
    - `coord-sort.sh`: Sort the BAM files by coordinates
   
5. **Haplotype Calling**:
    - `haplotype.sh`: Call haplotypes from the sorted BAM files to identify variant sites

6. **Genotyping and Variant Filtering**:
    - `genotype.sh`: Aggregate per-sample variant data and genotype the samples
    - `filter-vcf.sh`: Apply quality-based filtering to retain high-confidence variants

#### Additional Files
- Create `.dict` and `.fai` files for the reference genome as required for downstream analysis

### Part 2: Population Genomics Analyses

Once the variant calling is complete, I perform downstream statistical analyses on the VCF files, including:

- **Outlier Detection**: Identify genetic loci under selection using pcadapt and BayeScan
- **Genotype-Environment Associations**: Explore environmental drivers of selection and adaptation using RDA and BayPass

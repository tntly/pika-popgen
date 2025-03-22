#!/usr/bin/env nextflow

process fastp {
    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
        tuple val(sample_id), path(read_1), path(read_2)

    output:
        tuple val(sample_id), path("${read_1.simpleName}.trimmed.fastq.gz"), path("${read_2.simpleName}.trimmed.fastq.gz"), emit: trimmed_reads
        path "reports/${sample_id}.fastp.json", emit: json
        path "reports/${sample_id}.fastp.html", emit: html
    
    script:
    """
    mkdir -p reports
    fastp -i ${read_1} -I ${read_2} \
        -o ${read_1.simpleName}.trimmed.fastq.gz -O ${read_2.simpleName}.trimmed.fastq.gz \
        -j reports/${sample_id}.fastp.json -h reports/${sample_id}.fastp.html \
        -w ${params.threads}
    """
}

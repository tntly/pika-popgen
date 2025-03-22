#!/usr/bin/env nextflow

process fastqc {
    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
        tuple val(sample_id), path(read_1), path(read_2)

    output:
        path("*_fastqc.{zip,html}")
    
    script:
    """
    fastqc ${read_1} ${read_2} -t 2
    """
}

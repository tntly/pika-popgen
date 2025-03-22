#!/usr/bin/env nextflow

process bwa {
    publishDir "${params.outdir}/bwa", mode: 'copy'

    input:
        path ref
        path ref_amb
        path ref_ann
        path ref_bwt
        path ref_pac
        path ref_sa
        tuple val(sample_id), path(read_1), path(read_2)

    output:
       path "${sample_id}.sam"

    script:
    """
    bwa mem -t ${params.threads} ${ref} ${read_1} ${read_2} > ${sample_id}.sam
    """
}

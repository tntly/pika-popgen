#!/usr/bin/env nextflow

process multiqc {
    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
     path "*"

    output:
        path "multiqc_report.html"					

    script:
    """
    multiqc .
    """
}

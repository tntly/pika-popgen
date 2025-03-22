#!/usr/bin/env nextflow

// Module INCLUDE statements
include { fastqc as fastqc_raw; fastqc as fastqc_trimmed } from './modules/fastqc.nf'
include { fastp } from './modules/fastp.nf'
include { multiqc } from './modules/multiqc.nf'
include { bwa } from './modules/bwa.nf'

workflow {
    log.info """
        LIST OF PARAMETERS
    ================================
                GENERAL
    Input CSV        : ${params.input_csv}
    Output folder    : ${params.outdir}
    Threads          : ${params.threads}
                REFERENCE
    Reference        : ${params.ref}
    Reference amb    : ${params.ref_amb}
    Reference ann    : ${params.ref_ann}
    Reference bwt    : ${params.ref_bwt}
    Reference pac    : ${params.ref_pac}
    Reference sa     : ${params.ref_sa}
    ================================
    """

    // Create input channel from reads
    reads_ch = Channel.fromPath(params.input_csv, checkIfExists: true)
                    .splitCsv(header: true)
                    .map { row -> 
                        // Extract sample ID from the filename
                        def fastq_1 = file(row.fastq_1)
                        def sample_id = fastq_1.name.split("_R")[0]
                        
                        // Return a tuple with [sample_id, R1_file, R2_file]
                        return tuple(sample_id, file(row.fastq_1), file(row.fastq_2))
                    }

    // Initial quality control
    fastqc_raw(reads_ch)

    // Adapter trimming
    fastp(reads_ch)

    // Quality control after trimming
    fastqc_trimmed(fastp.out.trimmed_reads)

    // Aggregate quality control reports
    multiqc(fastqc_raw.out.mix(fastqc_trimmed.out).collect())

    // Mapping with BWA
    bwa(params.ref, params.ref_amb, params.ref_ann, params.ref_bwt, params.ref_pac, params.ref_sa, fastp.out.trimmed_reads)
}

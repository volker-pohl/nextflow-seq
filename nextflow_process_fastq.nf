#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// def replace_suffix(string, replacement) {
//   return string.replaceAll(/.fastq.gz/, replacement)
// }

// dsl2 allows a process to be invoked only once in the same workflow context
// therefore the qc process is included twice with different names via module aliasing to be invoked twice in the workflow
// include { qc as qc_initial } from './qc.nf'
// include { qc as qc_trimmed } from './qc.nf'

process adapterTrimming {
  container 'genomicpariscentre/cutadapt'
  input:
    path input_files
  output:
    path "SRR*"

  """
  prefix=\$(echo ${input_files} | awk '{print substr(\$0, 1, length(\$0) - 9)}')
  new_suffix="_adapter.fastq.gz"
  cutadapt -a GATCGGAAGAGCACACGTCTGAACTCCAGTCACAGCGCTATCTCGTATGC -o \$prefix\$new_suffix ${input_files}
  """
} 

process qualityTrimming {
  publishDir "s3://081939948643-nextflow-test/output", pattern: '*.gz'
  container 'genomicpariscentre/cutadapt'
  input:
    path input_files
  output:
    path "SRR*"

  """
  aws s3 ls s3://081939948643-nextflow-test/data/ --recursive
  prefix=\$(echo ${input_files} | awk '{print substr(\$0, 1, length(\$0) - 9)}')
  new_suffix="_trimmed.fastq.gz"
  cutadapt -q 20,20 -o \$prefix\$new_suffix ${input_files}
  """
}

process upload {
  input:
    file x
  output:
    stdout

  """
  rev $x
  """
}

workflow {
    input_files = Channel.fromPath("s3://081939948643-nextflow-test/data/*fastq.gz")
    //qc_initial(input_files)
    output_adapter_trimming = adapterTrimming(input_files)
    output_quality_trimming = qualityTrimming(output_adapter_trimming)
    // output_qc_quality_trimmed = qc_trimmed(output_quality_trimming)   
}

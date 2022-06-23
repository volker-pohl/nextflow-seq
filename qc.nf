process qc { 
  // container 'genomicpariscentre/fastqc'
  container 'zavolab/fastqc'
  // publishDir "output", pattern: '*.html'
  publishDir "s3://081939948643-nextflow-test/output", pattern: '*.html'
  input:
    path input_files
  output:
    path "SRR*"

  """
  fastqc ${input_files}
  """
}

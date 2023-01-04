#! /usr/bin/env nextflow

def helpMessage() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --query QUERY.fasta --dbDir "blastDatabaseDirectory" --dbName "blastPrefixName"

        Mandatory arguments:
         --query                        Query fasta file of sequences you wish to BLAST
         --dbDir                        BLAST database directory (full path required)
         --dbName                       Prefix name of the BLAST database

       Optional arguments:
        --outdir                       Output directory to place final BLAST output
        --outfmt                       Output format ['6']
        --options                      Additional options for BLAST command [-evalue 1e-3]
        --outFileName                  Prefix name for BLAST output [input.blastout]
        --threads                      Number of CPUs to use during blast job [16]
        --chunkSize                    Number of fasta records to use when splitting the query fasta file
        --app                          BLAST program to use [blastn;blastp,tblastn,blastx]
        --help                         This usage statement.
        """
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

Channel 
	.fromPath(params.inputSample)
	.set{inputSample_ch}

Channel
	.fromPath(params.referenceData)
	.set{referenceData_ch} 

process runSockeye {

	input: 
	path(input_sample)
	path(reference_data)	

	output: 
	publishDir("out_dir")
	path("${params.outputFile}/chr17/bams/")

	script: 
	"""
	NXF_VER=22.10.4 nextflow run epi2me-labs/wf-single-cell \
   	-profile standard \
    	--fastq $input_sample \
    	--max_threads 8 \
    	—-merge_bam
    	--kit_name 3prime \
    	--kit_version v3 \
    	--expected_cells 100 \
    	--ref_genome_dir $reference_data \
    	--out_dir $params.outputFile \
    	-r v0.1.5
	"""

}

workflow {
	runSockeye(inputSample_ch, referenceData_ch)

}

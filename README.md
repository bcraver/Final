# EE282 Final  
`qrsh -q abio,free128,free88i,free72i,free32i,free64 -pe openmp 32`

Go to Final directory:  
/pub/bcraver/EE282_final

Currently Loaded Modulefiles:  
jje/kent/2014.02.19 perl/5.26.1 jje/jjeutils/0.1a R/2.15.2 rstudio/0.98.501 fastqc/0.11.5

###copy raw data from collaborators
`for f in /bio/aoliver2/MISC/kenza/raw_data/*; do cp "$f" /pub/bcraver/EE282_final/
; done`

Saved a copy of raw data in JJ's public ee282 file.   

`for f in /bio/aoliver2/MISC/kenza/raw_data/*; do cp "$f" /pub/jje/ee282/bcraver/Final/data/raw/; done`

### initialize git
	repodir=/pub/bcraver/EE282_final; 	projname=EE282_final
	cd /pub/bcraver/EE282_final
	git init

	# To simulate adding a lot of files to your empty repository.
	# Note the first argument is blank so the createProject
	# script doesn't create another nested directory. And the
	# path is the current directory, so the files are added in
	# ~/mypath.
	createProject "" .

	git add .
	git commit -m "First commit."
	

#Pre-processing and quality check  
Document checksums for raw zipped file.

`md5sum forward.fastq.gz`   
cbd37f4d46605042f6a361065d4ef9a8  forward.fastq.gz  
`md5sum forward.fastq.gz`  
cbd37f4d46605042f6a361065d4ef9a8  forward.fastq.gz  	

Unzip the fastq files then document checksums

`gunzip forward.fastq.gz reverse.fastq.gz`   
`md5sum forward.fastq reverse.fastq barcodes.fastq`  

4b33b739055f6bfa8de7403a2c2156a9  forward.fastq  
3313e9ab2ecedef6917fcbac1fac09b6  reverse.fastq  
8ce415da99303fb91ad4a4a57089dd9c  barcodes.fastq
	
####Running FastQC
Here is a script to run FastQC on the raw data:

	#!/bin/bash

	# Pool all forward and all reverse reads separately to assess quality in fastqc
	mkdir -p fastqc_check
	cat raw/forward.fastq >> fastqc_check/forward_reads.fastq
	cat raw/reverse.fastq >> fastqc_check/reverse_reads.fastq
	mkdir -p fastqc_check/forward_reads
	mkdir -p fastqc_check/reverse_reads

	# Run fastqc on these files
	fastqc fastqc_check/forward_reads.fastq -o fastqc_check/forward_reads
	fastqc fastqc_check/reverse_reads.fastq -o fastqc_check/reverse_reads
	
Next, I downloaded the html files onto my local computer to view FasqQC Report:

[FastQC Report forward](https://github.com/bcraver/Final/blob/master/data/processed/fastqc_check/forward_fastqc.html)  
[FastQC Report reverse](https://github.com/bcraver/Final/blob/master/data/processed/fastqc_check/reverse_fastqc.html)



The script merges the paired end reads together.

	join_paired_ends.py -f $PWD/forward_reads.fastq -r $PWD/reverse_reads.fastq -o $PWD/fastq-join_joined
	
	
###Sequencing and statistical analyses
16S rRNA amplicon PCR was performed targeting the full V4-V5 region using the EMP primers (515F (barcoded) and 926R) (Caporaso et al. (2012), Walters et al. (2016))
The library was sequenced at the UC Irvine Genomics High Throughput Facility using a miseq v3 chemistry with a PE300 sequencing length. Sequencing resulted in 16.6 M reads passing filter (of which 25.8% are PhiX) with an overall >Q30 79.9.9%.

The raw sequence data were imported into qiime2 (qiime2.org) and demultiplexed.
12.4 M paired end reads were binned into the designated barcodes (153 samples including two duplicate samples and two mock communities).
0 samples showed no reads. The lowest reads per sample were 3782. After initial sample quality check and trimming (DADA2 in qiime2) there were 7.9 million paired end reads. These reads were used for further analysis. From the sequences the first 5 bp were trimmed and the forward read was truncated at 285 bp the reverse read at 238 bp.The sequences were assigned a taxonomic classification using the May 2013 greeengenes database (greengenes.secondgenome.com), trained with the primer pairs that were used to amplify the 16S region.

PRIMER-E with the PERMANOVA add-on as well as R studio and Microbiome Analyst were used to calculate significance between groups and factors and look for correlations between cytokines and taxa within MPN and healthy groups.







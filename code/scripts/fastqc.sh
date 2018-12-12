#!/bin/bash


# Pool all forward and all reverse reads separately to assess quality in fastqc
mkdir fastqc_check
cat raw/forward.fastq >> fastqc_check/forward_reads.fastq
cat raw_data/reverse.fastq >> fastqc_check/reverse_reads.fastq
mkdir fastqc_check/forward_reads
mkdir fastqc_check/reverse_reads

# Run fastqc on these files
fastqc fastqc_check/forward_reads.fastq -o fastqc_check/forward_reads
fastqc fastqc_check/reverse_reads.fastq -o fastqc_check/reverse_reads

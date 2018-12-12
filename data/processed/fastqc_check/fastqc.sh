#!/bin/bash


# Pool all forward and all reverse reads separately to assess quality in fastqc
mkdir -p fastqc_check
cat forward.fastq >> fastqc_check/forward_reads.fastq
cat reverse.fastq >> fastqc_check/reverse_reads.fastq
mkdir -p fastqc_check/forward_reads
mkdir -p fastqc_check/reverse_reads

# Run fastqc on these files
fastqc fastqc_check/forward_reads.fastq -o fastqc_check/forward_reads
fastqc fastqc_check/reverse_reads.fastq -o fastqc_check/reverse_reads

#!/bin/bash
#$ -N qiime2_demux
#$ -m bea
#$ -q bio*,abio,pub8i*
#$ -pe openmp 2-8
#$ -cwd

module load anaconda/3.6-4.3.1
source activate qiime2-2018.11

qiime demux emp-paired \
  --m-barcodes-file metadata.tsv \
  --m-barcodes-column BarcodeSequence \
  --i-seqs imported_data.qza \
  --o-per-sample-sequences demux.qza

qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv


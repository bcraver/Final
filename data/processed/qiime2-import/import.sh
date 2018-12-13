#!/bin/bash
#$ -N qiime2_import
#$ -m bea
#$ -q bio*,abio,pub8i*
#$ -pe openmp 2-8
#$ -cwd

module load anaconda/3.6-4.3.1
source activate qiime2-2018.11

qiime tools import \
   --type EMPPairedEndSequences \
   --input-path /pub/bcraver/EE282_final/data/raw \
   --output-path imported_data.qza


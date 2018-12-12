#!/bin/bash
#$ -N qiime2_import
#$ -m bea
#$ -q bio*,abio,pub8i*
#$ -pe openmp 2-8
#$ -cwd

module load anaconda/2.7-4.3.1
source activate qiime2-2018.4

qiime tools import \
   --type EMPPairedEndSequences \
   --input-path raw_data \
   --output-path imported_data.qza


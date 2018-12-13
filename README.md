# EE282 Final  
`qrsh -q abio,free128,free88i,free72i,free32i,free64 -pe openmp 32`

Go to Final directory:  
/pub/bcraver/EE282_final

Currently Loaded Modulefiles:  
jje/kent/2014.02.19 perl/5.26.1 jje/jjeutils/0.1a R/2.15.2 rstudio/0.98.501 fastqc/0.11.5

###Copy raw data from collaborators

`for f in /bio/aoliver2/MISC/kenza/raw_data/*; do cp "$f" /pub/bcraver/EE282_final//data/raw/
; done`
Saved a copy of raw data in JJ's public ee282 file.   
`for f in /bio/aoliver2/MISC/kenza/raw_data/*; do cp "$f" /pub/jje/ee282/bcraver/Final/data/raw/; done`

### Initialize git
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

Unzip the fastq files then document checksums:

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

_Dealing with git issues_  

	$ git push origin master 
	Warning: untrusted X11 forwarding setup failed: xauth key data not generated
	Counting objects: 56, done.
	Delta compression using up to 8 threads.
	Compressing objects: 100% (54/54), done.
	Writing objects: 100% (56/56), 300.06 MiB | 20.58 MiB/s, done.
	Total 56 (delta 8), reused 0 (delta 0)
	remote: Resolving deltas: 100% (8/8), done.
	remote: error: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.
	remote: error: Trace: df42302386fc759f82454c7e247f92fa
	remote: error: See http://git.io/iEPt8g for more information.
	remote: error: File barcodes.fastq is 1659.32 MB; this exceeds GitHub's file size limit of 100.00 MB
	To git@github.com:bcraver/Final.git
	 ! [remote rejected] master -> master (pre-receive hook declined)
	error: failed to push some refs to 'git@github.com:bcraver/Final.git'

Issue solved. Reset initial commits that contained large fastq files. Added fastq files to .gitignore then re-commit. 

####Install QIIME2  

`module purge`  
`module load anaconda/3.6-4.3.1`
`source activate qiime2-2018.11`

Import raw data using import.sh

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


### Demultiplexing 
To remove barcodes and primers. 

The following script is saved as demux.sh under the analysis/scripts/ directory. Submitted as a job via qsub

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

### Denoise  

	#!/bin/bash
	#$ -N qiime2_denoise
	#$ -m beas
	#$ -q bio*,abio,pub*
	#$ -pe openmp 32
	#$ -R y

	# Qiime2 denoise, and all the other fun stuff. 

	module load anaconda/3.6-4.3.1
	source activate qiime2-2018.11

	qiime dada2 denoise-paired \
	  --i-demultiplexed-seqs demux.qza \
	  --p-trim-left-f 5 \
	  --p-trim-left-r 5 \
	  --p-trunc-len-f 285 \
	  --p-trunc-len-r 238 \
	  --o-table table.qza \
	  --p-n-threads 32 \
	  --o-representative-sequences rep-seqs.qza \
	  --o-denoising-stats denoising-stats.qza
	
	qiime feature-table summarize \
	  --i-table table.qza \
	  --o-visualization table.qzv \
	  --m-sample-metadata-file metadata.tsv
	  
	qiime feature-table tabulate-seqs \
	  --i-data rep-seqs.qza \
	  --o-visualization rep-seqs.qzv
	  
	qiime metadata tabulate \
	  --m-input-file denoising-stats.qza \
	  --o-visualization denoising-stats.qzv
	  
	qiime alignment mafft \
	  --i-sequences rep-seqs.qza \
	  --o-alignment aligned-rep-seqs.qza
	  
	qiime alignment mask \
	  --i-alignment aligned-rep-seqs.qza \
	  --o-masked-alignment masked-aligned-rep-seqs.qza
	  
	qiime phylogeny fasttree \
	  --i-alignment masked-aligned-rep-seqs.qza \
	  --o-tree unrooted-tree.qza
		
	qiime phylogeny midpoint-root \
	  --i-tree unrooted-tree.qza \
	  --o-rooted-tree rooted-tree.qza
	  
	qiime feature-classifier classify-sklearn \
	  --i-classifier /bio/cweihe/Microbiome-Initiative/classifier/515_926classifier.qza\
	  --i-reads rep-seqs.qza \
	  --o-classification taxonomy.qza
	  
	qiime taxa barplot \
	  --i-table table.qza \
	  --i-taxonomy taxonomy.qza \
	  --m-metadata-file metadata.tsv \
	  --o-visualization taxa-bar-plots.qzv
	  
	qiime alignment mafft \
	  --i-sequences rep-seqs.qza \
	  --o-alignment aligned-rep-seqs.qza
	  
	qiime alignment mask \
	  --i-alignment aligned-rep-seqs.qza \
	  --o-masked-alignment masked-aligned-rep-seqs.qza
	  
	qiime phylogeny fasttree \
	  --i-alignment masked-aligned-rep-seqs.qza \
	  --o-tree unrooted-tree.qza
	  
	qiime phylogeny midpoint-root \
	  --i-tree unrooted-tree.qza \
	  --o-rooted-tree rooted-tree.qza
	  
	qiime diversity core-metrics-phylogenetic \
	  --i-phylogeny rooted-tree.qza \
	  --i-table table.qza \
	  --p-sampling-depth 3700 \
	  --m-metadata-file metadata.tsv \
	  --output-dir core-metrics-results
	  
	qiime diversity alpha-group-significance \
	  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
	  --m-metadata-file metadata.tsv \
	  --o-visualization core-metrics-results/faith-pd-group-significance.qzv
	  
	qiime diversity alpha-group-significance \
	  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
	  --m-metadata-file metadata.tsv \
	  --o-visualization core-metrics-results/evenness-group-significance.qzv

	qiime diversity beta-group-significance \
	  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
	  --m-metadata-file metadata.tsv \
	  --m-metadata-column HealthStatus \
	  --o-visualization core-metrics-results/unweighted-unifrac-body-site-significance.qzv \
	  --p-pairwise
  
	#qiime diversity beta-group-significance \
	#  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
	#  --m-metadata-file metadata.tsv \
	#  --m-metadata-column Subject \
	#  --o-visualization core-metrics-results/unweighted-unifrac-subject-group-significance.qzv \
	#  --p-pairwise
	  
	qiime diversity alpha-rarefaction \
	  --i-table table.qza \
	  --i-phylogeny rooted-tree.qza \
	  --p-max-depth 3700 \
	  --m-metadata-file metadata.tsv \
	  --o-visualization alpha-rarefaction.qzv

# R scripts  
First, visualize number of reads per sample. Then rarefy. Then use multiplot to identify correlations between Prevotella and inflammatory cytokine. 
	
	# load up required packages
	
	library(vegan)
	library(ggplot2)
	# Download 
	# library(devtools)
	# devtools::install_github("GuillemSalazar/EcolUtils")
	library(EcolUtils)
	library(ggpubr)
	library(devtools)
	library(readxl)
	
	****************** MULTIPLOT FUNCTION ******************
	
	multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
	  library(grid)
	  
	  # Make a list from the ... arguments and plotlist
	  plots <- c(list(...), plotlist)
	  
	  numPlots = length(plots)
	  
	  # If layout is NULL, then use 'cols' to determine layout
	  if (is.null(layout)) {
	    # Make the panel
	    # ncol: Number of columns of plots
	    # nrow: Number of rows needed, calculated from # of cols
	    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
	                     ncol = cols, nrow = ceiling(numPlots/cols))
	  }
	  
	  if (numPlots==1) {
	    print(plots[[1]])
	    
	  } else {
	    # Set up the page
	    grid.newpage()
	    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
	    
	    # Make each plot, in the correct location
	    for (i in 1:numPlots) {
	      # Get the i,j matrix positions of the regions that contain this subplot
	      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
	      
	      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
	                                      layout.pos.col = matchidx$col))
	    }
	  }
	}
	************************************************************
	
	# import data
	setwd("~/Downloads/bri/")
	level_7 <- (read.csv("level-7.csv", sep = ",", row.names = 1))
	clean_data <- subset(level_7[ ,1:211])
	no_mock <- subset(level_7[1:151 ,1:211])
	inmeta <- read.csv("New_7_map.csv",sep = "\t",header = TRUE)
	
	# look at reads
	barplot(sort(rowSums(clean_data)), ylim = c(0, max(rowSums(clean_data))), 
	        xlim = c(0,NCOL(clean_data)), col = "Orange") 
	
	# Rarefy to normalize the data
	# Bray Distances
	median.avg.dist <- avgdist(no_mock, sample = 2200, iterations = 100, 
	                           meanfun = median, dmethod = "bray")
	
	bray_distance_matrix <- as.data.frame(as.matrix(median.avg.dist))
	
	# Alpha distances
	rare_perm_otu <- rrarefy.perm(clean_data, sample = 2200, n = 10, round.out = T)
	barplot(sort(rowSums(rare_perm_otu)), ylim = c(0, max(rowSums(rare_perm_otu))), 
	        xlim = c(0,NCOL(rare_perm_otu)), col = "Orange")
	
	
	
	# Write to file
	write.csv(bray_distance_matrix, file = "bray_distances.csv")
	write.csv(rare_perm_otu, file = "rarified_otu-table.csv")
	
	# Do nMDS
	quick_nmds <- metaMDS(bray_distance_matrix, k=2)
	plot(quick_nmds)
	quick_nmds
	
	
	******************* PREVOTELLA CORRELATIONS **********************
	******************************************************************	
	
	prevotella_cytokines <- read_excel("prevotella.xlsx")
	
	#prevotella vs tnfa
	A <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "TNFa", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella copri", ylab = "TNFa", shape = "HealthStatus", size = 2) 
	
	
	#prevotella vs IP10
	B <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IP10", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IP10", shape = "HealthStatus", size = 2)
	
	C <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "GRO", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "GRO", shape = "HealthStatus", size = 2)
	
	#prevotella vs IFNg
	D <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IFNg", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IFNg", shape = "HealthStatus", size = 2)
	
	#prevotella vs IL10
	E <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL10", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IL10", shape = "HealthStatus", size = 2)
	
	#prevotella vs IL17a
	F <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL17a", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IL17a", shape = "HealthStatus", size = 2)
	
	#prevotella vs IL1RA
	G <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL1RA", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IL1RA", shape = "HealthStatus", size = 2)
	
	#prevotella vs IL1a
	H <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL1a", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IL1a", shape = "HealthStatus", size = 2)
	
	#prevotella vs IL1b
	I <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL1b", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IL1b", shape = "HealthStatus", size = 2)
	
	#prevotella vs IL6
	J <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL6", 
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IL6", shape = "HealthStatus", size = 2)
	
	#prevotella vs IL8
	K <- ggscatter(prevotella_cytokines, x = "Prevotella_copri", y = "IL8",
	               add = "reg.line", conf.int = TRUE, 
	               cor.coef = TRUE, cor.method = "pearson",
	               xlab = "Prevotella_copri", ylab = "IL8", shape = "HealthStatus", size = 2)
	
	multiplot(A, B, C, D, E, F, G, H, I, J, K, cols=3)

# Plots
![](https://github.com/bcraver/Final/blob/master/output/figures/Rplot_reads_per_sample.png) **Figure 1.** Number of reads per sample. Lowest number of reads for an individual (displayed on x-axis) was 2270.
![](https://github.com/bcraver/Final/blob/master/output/figures/Rplot_rarefy.png) **Figure 2.** Rarefy to normalize reads to 2200 per sample. 
![](https://github.com/bcraver/Final/blob/master/output/figures/Rplot_nmds.png)**Figure 3.** Nonmetric multidimensional scaling (NMDS) using Bray-Curtis dissimilarity.  
![](https://github.com/bcraver/Final/blob/master/output/figures/Rplot_cytokines.png)**Figure 4.** Correlations between _Prevotella copri_ and individual cytokines in MPN patients and healthy individuals. _Prevotella copri_ was represented in MPN patients more often than in healthy individuals (data not shown).

###Methods: Sequencing and statistical analyses
The purpose of this experiment is to determine whether the microbiome in patients with Myeloproliferative Neoplasm (MPN) is different than healthy aged-matched individuals. 16S rRNA amplicon PCR was performed targeting the full V4-V5 region using the EMP primers (515F (barcoded) and 926R) (Caporaso et al. (2012), Walters et al. (2016)). The library was sequenced at the UC Irvine Genomics High Throughput Facility using a miseq v3 chemistry with a PE300 sequencing length. Sequencing resulted in 16.6 M reads passing filter (of which 25.8% are PhiX) with an overall >Q30 79.9.9%. Raw sequence data were imported into qiime2 (qiime2.org) and demultiplexed on the HPC.

12.4 M paired end reads were binned into the designated barcodes (153 samples including two duplicate samples and two mock communities).
0 samples showed no reads. The lowest reads per sample were 2273. After initial sample quality check and trimming (DADA2 in qiime2) there were 7.9 million paired end reads. These reads were used for further analysis. From the sequences the first 5 bp were trimmed and the forward read was truncated at 285 bp the reverse read at 238 bp. The sequences were assigned a taxonomic classification using the May 2013 greeengenes database (greengenes.secondgenome.com), trained with the primer pairs that were used to amplify the 16S region. 

R studio was used to calculate significance between groups and factors and look for correlations between cytokines and taxa within MPN and healthy groups.








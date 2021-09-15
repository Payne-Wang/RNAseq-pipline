#!/bin/bash
source  ./step0.environment.sh
process=featurecount
logfile=$wk_dir/temp/$process'.log'
mkdir $logfile
cd $fastq_dir
featureCounts -T 5 -a $gtf -o featurecount_read.count -p -B -C -t exon -g gene_name  `find -name "*.bam"` 2>$logfile/featurecounts.errlog



#!/bin/bash
source  ./step0.environment.sh
process=fastqc
logfile=$wk_dir/temp/$process'.log'
mkdir $logfile
dir_prefix=`cat $wk_dir/code/sample.list`
cd $fastq_dir
mkdir fastqc_res
mkdir multiqc_res
for id in `ls -d $dir_prefix`
do
{
  fastqc -o fastqc_res -t 3 $id/$id$fastq1_suffix $id/$id$fastq2_suffix
} 2>$logfile/$id'.fastqc.errlog' &
  done
wait
multiqc -n multiqc_rawdata_res -o multiqc_res fastqc_res

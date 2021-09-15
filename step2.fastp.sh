#!/bin/bash
source  ./step0.environment.sh
process=fastp
logfile=$wk_dir/temp/$process'.log'
mkdir $logfile
dir_prefix=`cat $wk_dir/code/sample.list`
cd $fastq_dir
mkdir multiqc_res_clean
for id in `ls -d $dir_prefix`
do
{
  read1=$id/$id$fastq1_suffix;read2=$id/$id$fastq2_suffix;clean_read1=$id/$id'.R1.clean.fastq.gz';clean_read2=$id/$id'.R2.clean.fastq.gz';fastp -i $read1 -I $read2 -o $clean_read1 -O $clean_read2
} 2>$logfile/$id'.fastp.errlog' &
  done
wait
#重新fastqc
mkdir refastqc_res
for id in `ls -d $dir_prefix`
do
{
  clean_read1=$id/$id'.R1.clean.fastq.gz';clean_read2=$id/$id'.R2.clean.fastq.gz';fastqc -o refastqc_res -t 3 $clean_read1 $clean_read2
}
done
wait
multiqc -n multiqc_cleandata_res -o multiqc_res_clean refastqc_res
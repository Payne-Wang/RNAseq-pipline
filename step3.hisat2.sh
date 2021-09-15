#!/bin/bash
source  ./step0.environment.sh
process=hisat2
logfile=$wk_dir/temp/$process'.log'
mkdir $logfile
dir_prefix=`cat $wk_dir/code/sample.list`
cd $fastq_dir
for id in `ls -d $dir_prefix`
do
	{
	 	read1=$id/$id'.R1.clean.fastq.gz';read2=$id/$id'.R2.clean.fastq.gz';hisat2 -p 5 --dta -x $index -1 $read1 -2 $read2|samtools sort -@ 5  --output-fmt BAM -o $id/$id'.sorted.bam' - 
	} 2>$logfile/$id'.hisat2.errlog' &
done
wait

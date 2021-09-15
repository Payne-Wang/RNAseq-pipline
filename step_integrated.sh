#!/bin/bash


######################################################## 
#-------------------------------------------------------
# Topic:RNAseq上游分析
# Author:Wang Haiquan
# Date:Wed Sep 15 11:34:58 2021
# Mail:mg1835020@smail.nju.edu.cn
#-------------------------------------------------------
########################################################


# #-------------------------------------------------------
# # Chapter:构建环境
# #-------------------------------------------------------
# 
# #构建文件系统
# mkdir fastq  #存储原始数据及各个阶段的数据
# mkdir code #用于存储代码
# mkdir index  #存储索引数据
# mkdir genome  #存储基因组fasta数据
# mkdir res  #存储最终结果数据
# mkdir temp  #存储中间的temp数据
# mkdir otherfile  #存储其它过程中间数据
# #将构建好的index和基因组分别放到index和genome中
# #基因组索引，由hisat2构建
# ln -s /media/whq/282A932A2A92F3D2/282A932A2A92F3D2/WHQ/reference_genome/mouse/ensembl/index/* ./index
# #gtf文件
# ln -s /media/whq/282A932A2A92F3D2/282A932A2A92F3D2/WHQ/reference_genome/mouse/ensembl/Mus_musculus_Ensemble_94.gtf ./genome
# #基因组fasta
# ln -s /media/whq/282A932A2A92F3D2/282A932A2A92F3D2/WHQ/reference_genome/mouse/ensembl/Mus_musculus_Ensemble_94.fa ./genome
# 


#-------------------------------------------------------
# Chapter:定义变量
#-------------------------------------------------------


#定义变量
wk_dir=/home/whq/Desktop/yangcf_RNAseq/210527_A00399_0283_AH3WKKDSX2/RNA-seq_analysis
code_dir=$wk_dir/code
fastq_dir=$wk_dir/fastq
index=$wk_dir/index/mmu.fa
genome=$wk_dir/genome/Mus_musculus_Ensemble_94.fa
gtf=$wk_dir/genome/Mus_musculus_Ensemble_94.gtf
fastq1_suffix=.R1.fastq.gz
fastq2_suffix=.R2.fastq.gz


#-------------------------------------------------------
# Chapter:质控
#-------------------------------------------------------


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


#-------------------------------------------------------
# Chapter:fastp
#-------------------------------------------------------


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


#-------------------------------------------------------
# Chapter:比对
#-------------------------------------------------------

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



#-------------------------------------------------------
# Chapter:计数
#-------------------------------------------------------


process=featurecount
logfile=$wk_dir/temp/$process'.log'
mkdir $logfile
cd $fastq_dir
featureCounts -T 5 -a $gtf -o featurecount_read.count -p -B -C -t exon -g gene_name  `find -name "*.bam"` 2>$logfile/featurecounts.errlog


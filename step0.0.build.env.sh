#!/bin/bash
#构建文件系统
mkdir fastq  #存储原始数据及各个阶段的数据
mkdir code #用于存储代码
mkdir index  #存储索引数据
mkdir genome  #存储基因组fasta数据
mkdir res  #存储最终结果数据
mkdir temp  #存储中间的temp数据
mkdir otherfile  #存储其它过程中间数据
#将构建好的index和基因组分别放到index和genome中
#基因组索引，由hisat2构建
ln -s /media/whq/282A932A2A92F3D2/282A932A2A92F3D2/WHQ/reference_genome/mouse/ensembl/index/* ./index
#gtf文件
ln -s /media/whq/282A932A2A92F3D2/282A932A2A92F3D2/WHQ/reference_genome/mouse/ensembl/Mus_musculus_Ensemble_94.gtf ./genome
#基因组fasta
ln -s /media/whq/282A932A2A92F3D2/282A932A2A92F3D2/WHQ/reference_genome/mouse/ensembl/Mus_musculus_Ensemble_94.fa ./genome

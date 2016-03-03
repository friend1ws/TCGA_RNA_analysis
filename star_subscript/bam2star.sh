#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe def_slot 6 -l s_vmem=5.3G,mem_req=5.3G
#$ -e log/ -o log/

STAR_PATH=/home/w3varann/tools/STAR-STAR_2.4.0k/bin/Linux_x86_64/STAR
REFERENCE=/home/w3varann/database/GRCh37.STAR-STAR_2.4.0k
ADDITIONAL_PARAM="--runThreadN 6 --outSAMstrandField intronMotif --outSAMunmapped Within --alignMatesGapMax 500000 --alignIntronMax 500000 --chimSegmentMin 12 --chimJunctionOverhangMin 12 --outSJfilterOverhangMin 12 12 12 12 --outSJfilterCountUniqueMin 1 1 1 1 --outSJfilterCountTotalMin 1 1 1 1"
SAMTOOLS_PATH=/home/w3varann/tools/samtools-1.2/samtools

INPUT_DIR=$1
OUTPUT_PREFIX=$2

if [ ! -d `dirname ${OUTPUT_PREFIX}` ]
then
    mkdir -p `dirname ${OUTPUT_PREFIX}`
fi

##########
# decompress
CUR_DIR=`pwd`

cd ${INPUT_DIR}
if [ -f *.tar ]
then
    for file in `ls *.tar`
    do
        echo "tar xvf ${file}"
        tar xvf ${file}
    done
fi

if [ -f *.tar.gz ]
then
    for file in `ls *.tar.gz`   
    do
        echo "tar zxvf ${file}"
        tar zxvf ${file}   
    done
fi  

cd ${CUR_DIR}
##########
    

##########
# merge sequences
echo -n > ${INPUT_DIR}/sequence1.txt
if [ -f ${INPUT_DIR}/*1.fastq ]
then
    for file in `ls ${INPUT_DIR}/*1.fastq | sort`
    do
        cat ${file} >> ${INPUT_DIR}/sequence1.txt
    done
fi

if [ -f ${INPUT_DIR}/*1.fastq.gz ]
then
    for file in `ls ${INPUT_DIR}/*1.fastq.gz | sort`
    do  
        zcat ${file} >> ${INPUT_DIR}/sequence1.txt
    done
fi


echo -n > ${INPUT_DIR}/sequence2.txt
if [ -f ${INPUT_DIR}/*2.fastq ]
then
    for file in `ls ${INPUT_DIR}/*2.fastq | sort`
    do
        cat ${file} >> ${INPUT_DIR}/sequence2.txt
    done
fi

if [ -f ${INPUT_DIR}/*2.fastq.gz ]
then
    for file in `ls ${INPUT_DIR}/*2.fastq.gz | sort`
    do  
        zcat ${file} >> ${INPUT_DIR}/sequence2.txt
    done
fi

rm -rf ${INPUT_DIR}/*1.fastq
rm -rf ${INPUT_DIR}/*1.fastq.gz
rm -rf ${INPUT_DIR}/*2.fastq
rm -rf ${INPUT_DIR}/*2.fastq.gz
##########


##########
# alignment

if [ -s ${INPUT_DIR}/sequence2.txt ]
then
    echo "${STAR_PATH} --genomeDir ${REFERENCE} --readFilesIn ${INPUT_DIR}/sequence1.txt ${INPUT_DIR}/sequence2.txt --outFileNamePrefix ${OUTPUT_PREFIX}. ${ADDITIONAL_PARAM} --outSAMtype BAM Unsorted"
    ${STAR_PATH} --genomeDir ${REFERENCE} --readFilesIn ${INPUT_DIR}/sequence1.txt ${INPUT_DIR}/sequence2.txt --outFileNamePrefix ${OUTPUT_PREFIX}. ${ADDITIONAL_PARAM} --outSAMtype BAM Unsorted
else
    echo "${STAR_PATH} --genomeDir ${REFERENCE} --readFilesIn ${INPUT_DIR}/sequence1.txt --outFileNamePrefix ${OUTPUT_PREFIX}. ${ADDITIONAL_PARAM} --outSAMtype BAM Unsorted"
    ${STAR_PATH} --genomeDir ${REFERENCE} --readFilesIn ${INPUT_DIR}/sequence1.txt --outFileNamePrefix ${OUTPUT_PREFIX}. ${ADDITIONAL_PARAM} --outSAMtype BAM Unsorted
fi
##########


##########
# sort and index
echo "${SAMTOOLS_PATH} sort -T ${OUTPUT_PREFIX}.Aligned.sortedByCoord.out -@ 6 -m 3G ${OUTPUT_PREFIX}.Aligned.out.bam -O bam > ${OUTPUT_PREFIX}.Aligned.sortedByCoord.out.bam"
${SAMTOOLS_PATH} sort -T ${OUTPUT_PREFIX}.Aligned.sortedByCoord.out -@ 6 -m 3G ${OUTPUT_PREFIX}.Aligned.out.bam -O bam > ${OUTPUT_PREFIX}.Aligned.sortedByCoord.out.bam

echo "${SAMTOOLS_PATH} index ${OUTPUT_PREFIX}.Aligned.sortedByCoord.out.bam"
${SAMTOOLS_PATH} index ${OUTPUT_PREFIX}.Aligned.sortedByCoord.out.bam
##########


rm -rf ${INPUT_DIR}/sequence1.txt
rm -rf ${INPUT_DIR}/sequence2.txt
rm -rf ${OUTPUT_PREFIX}.Aligned.out.bam

 

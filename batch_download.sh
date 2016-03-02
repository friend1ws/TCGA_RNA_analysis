#! /bin/bash

SUMMARY_TSV=$1
CANCER_TYPE=$2
OUTPUT_DIR=$3
CGHUB_KEY=$4

if [ ! -d log ]
then
    mkdir log
fi


if [ ! -d ${OUTPUT_DIR}/analysis_id ]
then
    mkdir -p ${OUTPUT_DIR}/analysis_id
fi

echo "rm -rf ${OUTPUT_DIR}/analysis_id/*"
rm -rf ${OUTPUT_DIR}/analysis_id/* 

echo "python download_subscript/get_analysis_id.py ${SUMMARY_TSV} ${CANCER_TYPE} ${OUTPUT_DIR}/analysis_id"
python download_subscript/get_analysis_id.py ${SUMMARY_TSV} ${CANCER_TYPE} ${OUTPUT_DIR}/analysis_id 

job_count=`ls ${OUTPUT_DIR}/analysis_id/*.txt | wc -l`


for i in `seq 1 ${job_count}`
do
    echo "qsub download_subscript/downloadList.sh ${OUTPUT_DIR}/analysis_id/${i}.txt ${OUTPUT_DIR} ${CGHUB_KEY}"
    qsub download_subscript/downloadList.sh ${OUTPUT_DIR}/analysis_id/${i}.txt ${OUTPUT_DIR} ${CGHUB_KEY}
done


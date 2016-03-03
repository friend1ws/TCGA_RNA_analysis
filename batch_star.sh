#! /bin/bash

SUMMARY_TSV=$1
CANCER_TYPE=$2
DOWNLOAD_DIR=$3
STAR_DIR=$4

echo "python star_subscript/make_analysisID2barcode.py ${SUMMARY_TSV} ${DOWNLOAD_DIR}/analysisID2barcode.txt ${CANCER_TYPE}"
python star_subscript/make_analysisID2barcode.py ${SUMMARY_TSV} ${DOWNLOAD_DIR}/analysisID2barcode.txt ${CANCER_TYPE}

while read line
do
    analysisID=`echo ${line} | cut -d ' ' -f 1`
    barcode=`echo ${line} | cut -d ' ' -f 2`

    echo "qsub star_subscript/bam2star.sh ${DOWNLOAD_DIR}/${analysisID} ${STAR_DIR}/${barcode}/${barcode}"
    qsub star_subscript/bam2star.sh ${DOWNLOAD_DIR}/${analysisID} ${STAR_DIR}/${barcode}/${barcode}

done < ${DOWNLOAD_DIR}/analysisID2barcode.txt


#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -e log/ -o log/

INPUT=$1
OUTPUT=$2
CGHUB_KEY=$3

echo "perl download_subscript/downloadList.pl ${INPUT} ${CGHUB_KEY} ${OUTPUT}"
perl download_subscript/downloadList.pl ${INPUT} ${CGHUB_KEY} ${OUTPUT}

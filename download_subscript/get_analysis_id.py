#! /usr/bin/env python

import sys

cghub_summary_tsv = sys.argv[1]
cancer_type = sys.argv[2]
output_dir = sys.argv[3]
file_num = 50

analysis_id_list = []
with open(cghub_summary_tsv, 'r') as hin:
    for line in hin:
        F = line.rstrip('\n').split('\t')
        if F[12] != "unaligned": continue
        if F[2] != cancer_type: continue
        analysis_id_list.append(F[16])


if len(analysis_id_list) == 0:
    print "No analysis id!"
    sys.exit(1)

num = 0
token = 1
hout = open(output_dir + "/" + str(token) + ".txt", 'w')
for analysis_id in sorted(analysis_id_list):
    print >> hout, analysis_id
    num = num + 1
    if num >= file_num:
        token = token + 1
        num = 0
        hout.close()
        hout = open(output_dir + "/" + str(token) + ".txt", 'w')

hout.close()





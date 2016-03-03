#! /usr/bin/env python

import sys

cghub_summary_tsv = sys.argv[1]
output_file = sys.argv[2]
cancer_type = sys.argv[3]

hout = open(output_file, 'w')
with open(cghub_summary_tsv, 'r') as hin:
    for line in hin:
        F = line.rstrip('\n').split('\t')
        if F[12] != "unaligned": continue
        if F[2] != cancer_type: continue

        print >> hout, F[16] + '\t' + F[1]

hout.close()





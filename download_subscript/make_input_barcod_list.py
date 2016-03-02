#! /usr/bin/env python

import sys

sv_file = sys.argv[1]
cghub_tsv_file = sys.argv[2]
output_file = sys.argv[3]

# target_gene = ["PIK3R1", "CTNNB1", "PIK3CA", "NFE2L2", "MYC", "EGFR"]
target_gene = ["CBL"]

barcode2target = {}
with open(sv_file, 'r') as hin:
    for line in hin:
        F = line.rstrip('\n').split('\t')
        genes1 = F[10].split(';')
        genes2 = F[12].split(';')

        target_flag = 0
        for g in list(set(genes1 + genes2)):
            if g in target_gene:
                target_flag = 1

        if target_flag == 1:
            barcode2target[F[0]] = 1
            # print F[0]

hout = open(output_file, 'w')
with open(cghub_tsv_file, 'r') as hin:
    for line in hin:
        F = line.rstrip('\n').split('\t')
        if F[12] != "unaligned": continue

        if F[1][0:15] in barcode2target:
            print >> hout, F[16]

hout.close()


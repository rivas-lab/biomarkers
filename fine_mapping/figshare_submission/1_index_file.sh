#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})
PROGNAME=$(basename $SRCNAME)
VERSION="0.0.1"
NUM_POS_ARGS="1"

region_index=$(readlink -f '../FINEMAP_output.tsv')
out_index="FINEMAP.index.tsv"

cat ${region_index} | awk -v FS='\t' -v OFS='\t' '($1 != "Fasting_glucose" && $3 != "chrX"){print $1, $3, $4}' > ${out_index}

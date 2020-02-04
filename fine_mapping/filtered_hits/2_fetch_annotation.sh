#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

{

tabix -H /scratch/groups/mrivas/ukbb24983/imp/annotation/annot.tsv.gz
cat ${SRCDIR}/filtered.hits.99.tsv \
| awk -v FS='\t' '(NR>1){print $4 ":" $5 "-" $5}' \
| sort -u | sed -e "s/^0//g" \
| parallel -k -j+0 'tabix /scratch/groups/mrivas/ukbb24983/imp/annotation/annot.tsv.gz {}' 

} > filtered.hits.99.anno.tsv

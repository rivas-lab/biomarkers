#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

echo "1_concatenate_filtered_hits.sh"
bash ${SRCDIR}/1_concatenate_filtered_hits.sh > filtered.hits.99.tsv

echo "2_fetch_annotation.sh"
bash ${SRCDIR}/2_fetch_annotation.sh

echo "3_join_annotation.R"
Rscript ${SRCDIR}/3_join_annotation.R

rm filtered.hits.99.tsv
rm filtered.hits.99.anno.tsv

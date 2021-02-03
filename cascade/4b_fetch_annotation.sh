#!/bin/bash
set -beEuo pipefail

# input
imp_annot_f="@@@@@@/ukbb24983/imp/annotation/annot.tsv.gz"
cascade_imp_hits="out_v3/cascade.imp.hits.tsv.zst"

# output
out_f="out_v3/cascade.imp.hits.var.annot.tsv.gz"

# tabix @@@@@@/ukbb24983/imp/annotation/annot.tsv.gz 1:50839740-50839740

{ 
tabix -H ${imp_annot_f}

zstdcat ${cascade_imp_hits} \
| cut -f1 \
| awk -v FS='_' '(NR>1){print $1}' \
| awk -v FS=':' '{print $1 ":" $2 "-" $2}' \
| parallel -k -j4 "tabix ${imp_annot_f} {}" \
| sort --parallel 6 -k1,1V -k2,2n

} | bgzip -l9 -@6 > ${out_f}

tabix -c '#' -s 1 -b2 -e2 ${out_f}
echo ${out_f}

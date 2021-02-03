#!/bin/bash
set -beEuo pipefail

res_dir='@@@@@@/projects/biomarkers/phewas/v2_imp_nc'
phewas_hits_ld="${res_dir}/ukb24983_imp_v3.nc.phewas.hits.ldmap.tsv"
phewas_hits_ld_annot="${res_dir}/ukb24983_imp_v3.nc.phewas.hits.ldmap.annot.tsv"

annot='@@@@@@/ukbb24983/imp/annotation/annot.tsv.gz'

{
    tabix -H ${annot}

    cat ${phewas_hits_ld} \
    | awk '(NR>1){print $4, $5}' \
    | uniq \
    | while read chr pos ; do
        tabix ${annot} ${chr}:${pos}-${pos}
    done
    
} > ${phewas_hits_ld_annot}

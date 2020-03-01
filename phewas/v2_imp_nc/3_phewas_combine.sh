#!/bin/bash
set -beEuo pipefail

phenotypes=$(cat ../../common/phenotypes.txt | awk '(NR>1){print $1}' | sort -u)
res_dir="/oak/stanford/groups/mrivas/projects/biomarkers/phewas/v2_imp_nc"
variants="${res_dir}/finemapped.hits.loci.txt"

# log
for c in $(cat ${variants} | awk -v FS=':' '{print $1}' | sort -nu) ; do
    cat ${res_dir}/per_chr/ukb24983_imp_chr${c}_v3.log
done > ${res_dir}/ukb24983_imp_v3.log

# results
{
    echo "$( cat ${res_dir}/per_chr/ukb24983_imp_chr1_v3.BIN1020483.glm.logistic.hybrid | egrep '^#' ) GBE_ID" \
    | tr " " "\t"
    
    for c in $(cat ${variants} | awk -v FS=':' '{print $1}' | sort -nu) ; do
    for p in ${phenotypes[@]} ; do
    
    cat ${res_dir}/per_chr/ukb24983_imp_chr${c}_v3.${p}.glm.logistic.hybrid \
    | egrep -v '^#' \
    | awk -v phenotype=${p} -v OFS='\t' '{print $0, phenotype}'
    
    done
    done | sort --parallel 6 -k1,1n -k2,2n
} | bgzip -l 9 -@ 6 > ${res_dir}/ukb24983_imp_v3.glm.logistic.hybrid.gz

tabix -c '#' -s 1 -b 2 -e 2 ${res_dir}/ukb24983_imp_v3.glm.logistic.hybrid.gz

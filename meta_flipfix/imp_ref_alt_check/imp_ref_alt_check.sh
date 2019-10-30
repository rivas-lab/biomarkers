#!/bin/bash
set -beEuo pipefail

ml load  bedtools

pvar_dir="/oak/stanford/projects/ukbb/genotypes/pgen_app13721_v3"

{
    cat ${pvar_dir}/ukb_imp_chrXY_v3.mac1.pvar | grep '#' 
    for c in $(seq 1 22) X XY ; do
        cat ${pvar_dir}/ukb_imp_chr${c}_v3.mac1.pvar | grep -v '#' 
    done
} \
    | sed -e "s/^PAR1/X/g" \
    | bash ~/repos/rivas-lab/ukbb-tools/04_gwas/flipfix/flipcheck.sh /dev/stdin \
    | bgzip -l 9 > ukb_imp_v3.mac1.flipcheck.tsv.gz


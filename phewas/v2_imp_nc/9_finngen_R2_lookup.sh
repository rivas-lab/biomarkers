#!/bin/bash
set -beEuo pipefail

res_dir='/oak/stanford/groups/mrivas/projects/biomarkers/phewas/v2_imp_nc'
finngen_var_ids="${res_dir}/ukb24983_imp_v3.nc.phewas.hits.ld.finngen_vars.lst"
finngen_R2_extracted="${res_dir}/ukb24983_imp_v3.nc.phewas.hits.ld.finngen.R2.tsv"

finngen_R2_master='/scratch/groups/mrivas/users/ytanigaw/20200114_FinnGen_R2/phewas/finngen_r2.phewas.p1e4.tsv.gz'

{
    tabix -H ${finngen_R2_master}

    cat ${finngen_var_ids} \
    | awk -v FS='-' '(NR>1){print $1 ":" $2 "-" $2}' \
    | parallel -j+0 -k "tabix ${finngen_R2_master} {}" 
} > ${finngen_R2_extracted}

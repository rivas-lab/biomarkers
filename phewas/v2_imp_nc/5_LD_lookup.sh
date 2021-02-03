#!/bin/bash
set -beEuo pipefail

res_dir='@@@@@@/projects/biomarkers/phewas/v2_imp_nc'
phewas_hits="${res_dir}/ukb24983_imp_v3.nc.phewas.hits.tsv"
phewas_hits_ld="${res_dir}/ukb24983_imp_v3.nc.phewas.hits.ldmap.tsv"

LD_lookup_sh="${OAK}/users/ytanigaw/repos/rivas-lab/ukbb-tools/14_LD_map/LD_lookup.sh"
LD_r2="0.9"

ldmap_file () {
    local chr=$1
    
    echo "@@@@@@/ukbb24983/imp/ldmap_common/ukb24983_imp_common_chr${chr}_v3.white_british.ld_map.tsv.gz"
}

echo "#CHROM POS ID LD_CHROM LD_POS LD_ID LD_R2" | tr ' ' '\t' > ${phewas_hits_ld}

cat ${phewas_hits} \
| awk '(NR>1){print $1, $2, $3}' | uniq | while read chr pos id; do
    {
        echo "${chr} ${pos} ${id} 1.0"
        bash ${LD_lookup_sh} --ld $(ldmap_file ${chr}) --r2 ${LD_r2} ${chr} ${pos} \
        | awk '(NR>1){print $4, $5, $6, $7}'
    } | tr ' ' '\t' \
    | awk -v chr=${chr} -v pos=${pos} -v id=${id} -v FS='\t' -v OFS='\t' '{print chr, pos, id, $0}'
done >> ${phewas_hits_ld}

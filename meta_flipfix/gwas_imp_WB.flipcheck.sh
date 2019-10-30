#!/bin/bash
set -beEuo pipefail

flipcheck_src="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/ukbb-tools/04_gwas/flipfix/flipcheck.sh"

cat gwas_imp_WB.lst | while read phe sumstats ; do 
    echo ${phe} ${sumstats}
    bash ${flipcheck_src} ${sumstats} | awk 'NR==1 || toupper($6) != toupper($NF)' 2>&1
done | tee gwas_imp_WB.flipcheck.out


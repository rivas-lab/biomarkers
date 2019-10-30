#!/bin/bash
set -beEuo pipefail

find /oak/stanford/groups/mrivas/users/mrivas/repos/ukbb-phenotyping/meta/biomarkers -name "*master*" \
    | grep -v male | grep -v eur | sort \
    | while read f ; do 
phe_name="$(basename $f .masterfile)"
sumstats="$(cat $f | grep PROCESS | grep white_british | awk '{print $2}')"
sumstats_uncompressed="$(dirname ${sumstats})/$(basename ${sumstats} .gz)"
if [ -f ${sumstats} ] ; then
    echo $phe_name $sumstats
elif [ -f ${sumstats_uncompressed} ] ; then
    echo $phe_name ${sumstats_uncompressed}
fi
done | tr " " "\t"  | tee gwas_imp_WB.lst


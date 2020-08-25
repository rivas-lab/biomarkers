#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})
PROGNAME=$(basename $SRCNAME)
VERSION="0.0.1"
NUM_POS_ARGS="1"

out_d='/oak/stanford/groups/mrivas/projects/biomarkers/phewas/phe_curation/LDSC_rg'
munged_stats_template="/oak/stanford/groups/mrivas/ukbb24983/array-combined/ldsc/white_british/ukb24983_v2_hg19.<<GBE_ID>>.array-combined.sumstats.gz"
GBE_ID_list=$(dirname ${SRCDIR})/phenotypes.txt

# ml load ukbb-tools

job_idx=$1

##########################

get_GBE_ID_by_idx () {
    local idx=$1
    cat ${GBE_ID_list} | awk '(NR>1){print $1}' | egrep -v '^RH' | awk -v idx=${idx} 'NR == idx'
}

n_phe=$( cat ${GBE_ID_list} | awk 'NR>1' | wc -l )
idx1=$(perl -e "print(int((${job_idx}-1)/${n_phe})+1)")
idx2=$(perl -e "print(${job_idx}-((${idx1}-1) * ${n_phe}))")
GBE_ID1=$( get_GBE_ID_by_idx ${idx1} )
GBE_ID2=$( get_GBE_ID_by_idx ${idx2} )
munged1=$(echo ${munged_stats_template} | sed -e "s/<<GBE_ID>>/$GBE_ID1/g")
munged2=$(echo ${munged_stats_template} | sed -e "s/<<GBE_ID>>/$GBE_ID2/g")
out_f=${out_d}/LDSC_rg.${GBE_ID1}.${GBE_ID2}.log

if [ ! -s ${out_f} ] ; then
    ldsc_rg.sh --scratch ${munged1} ${munged2} ${out_f%.log}
fi

exit 0

# job submission memo
# 173 * 173 = 29929
ml load resbatch ukbb-tools
sbatch -p mrivas,normal,owners --time=6:0:00 --mem=6000 --nodes=1 --cores=1 --job-name=rg --output=logs/rg.%A_%a.out --error=logs/rg.%A_%a.err --array=1-998 ${parallel_sbatch_sh} jobs.sh ${parallel_idx} 30
# 170 * 170 = 28900
sbatch -p mrivas,normal,owners --time=6:0:00 --mem=6000 --nodes=1 --cores=1 --job-name=rg --output=logs/rg.%A_%a.out --error=logs/rg.%A_%a.err --array=1-964 ${parallel_sbatch_sh} jobs.sh ${parallel_idx} 30


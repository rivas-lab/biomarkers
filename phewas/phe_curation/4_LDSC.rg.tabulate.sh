#!/bin/bash
set -beEuo pipefail

out_d='@@@@@@/projects/biomarkers/phewas/phe_curation/LDSC_rg'
rg_tsv=$(dirname ${out_d})/ldscrg.tsv

############################################################
# tmp dir
############################################################
tmp_dir_root="$LOCAL_SCRATCH"
if [ ! -d ${tmp_dir_root} ] ; then mkdir -p $tmp_dir_root ; fi
tmp_dir="$(mktemp -p ${tmp_dir_root} -d tmp-$(basename $0)-$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX)"
# echo "tmp_dir = $tmp_dir" >&2
handler_exit () { rm -rf $tmp_dir ; }
trap handler_exit EXIT
############################################################

ml load ukbb-tools

list_f=${tmp_dir}/ldscrg.lst

find ${out_d} -type f -size +0c | sort -V > ${list_f}

ldsc_rg_view.sh -l ${list_f} | tee ${rg_tsv}

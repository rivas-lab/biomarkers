#!/bin/bash
set -beEuo pipefail

meta=$1
gwas=$2

##############
tmp_dir_root=${LOCAL_SCRATCH}
if [ ! -d ${tmp_dir_root} ] ; then mkdir -p $tmp_dir_root ; fi
tmp_dir="$(mktemp -p ${tmp_dir_root} -d tmp-$(basename $0)-$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX)"
echo "tmp_dir = $tmp_dir" >&2
handler_exit () { rm -rf $tmp_dir ; }
trap handler_exit EXIT
##############

echo "copy"

img="$(dirname $meta)/$(basename $meta .sumstats.tsv.gz).flipcheck.png"
tmp_gwas="${tmp_dir}/$(basename ${gwas%.gz}).gz"
tmp_img="${tmp_dir}/$(basename ${img})"

if [ "${gwas%.gz}.gz" == "${gwas}" ] ; then
    cp ${gwas} ${tmp_gwas}
else
    cat ${gwas} | bgzip > ${tmp_gwas}
fi

echo "run"

Rscript "$(dirname $(readlink -f $0))/meta_imp_flip_check.R" ${meta} ${tmp_gwas} ${tmp_img}

cp ${tmp_img} ${img}

gdrive upload -p 14REgIR19CoQimqzjYTLJYDaS5dqnOt0C ${img}

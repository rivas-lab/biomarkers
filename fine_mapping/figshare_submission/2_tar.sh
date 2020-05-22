#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})
PROGNAME=$(basename $SRCNAME)
VERSION="0.0.1"

finemap_out_dir='/oak/stanford/groups/mrivas/users/christian'
region_index=$(readlink -f 'FINEMAP.index.tsv')
tar_out_d="/oak/stanford/groups/mrivas/projects/biomarkers/fine_mapping/figshare_submission"

path_zfile () {
    local chr_str=$1
    local range_str=$2
    local trait=$3
    local dir=$4
    echo "${dir}/${chr_str}/${trait}/GLOBAL_${trait}_${chr_str}_${range_str}.z.zst"
# example filename
# /oak/stanford/groups/mrivas/users/christian/chr1/Alanine_aminotransferase/GLOBAL_Alanine_aminotransferase_chr1_range41021713-59840021.z.zst    
}

path_range () {
    local chr_str=$1
    local range_str=$2
    local trait=$3
    local dir=$4
    echo "${dir}/${chr_str}/${trait}/${range_str}"
# example filename
# /oak/stanford/groups/mrivas/users/christian/chr1/Alanine_aminotransferase/range41021713-59840021
}

tar_file_list () {
# enumerate the list of files that needs to be included in the tar file
    local trait=$1
    local region_index=$2
    local dir=$3
    
    cat ${region_index} | awk -v FS='\t' -v trait=${trait} '(NR>1 && $1 == trait){print $2, $3}' | while read chr_str range_str ; do
        path_zfile ${chr_str} ${range_str} ${trait} ${dir}
        path_range ${chr_str} ${range_str} ${trait} ${dir}
    done | sort -V
}

############################################################

cd ${finemap_out_dir}

cat ${region_index} | awk '(NR>1){print $1}' | sort -u | while read trait ; do

tar_file_list ${trait} ${region_index} ${finemap_out_dir} \
| sed -e "s%${finemap_out_dir}/%%g" \
| tar -cf ${tar_out_d}/${trait}.tar -T /dev/stdin

echo ${tar_out_d}/${trait}.tar

done

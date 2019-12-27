#!/bin/bash
set -beEuo pipefail

post_process () {
    local phe=$1
    local dataset=$2
    local covars=$3

    local lab_repo_dir="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab"
    local out_dir_root="${lab_repo_dir}/public-resources/uk_biobank/biomarkers/snpnet/${dataset}/out"
    local pfile="/oak/stanford/groups/mrivas/ukbb24983/array_combined/pgen/ukb24983_cal_hla_cnv"

    bash "${lab_repo_dir}/PRS/helper/export_betas.sh" \
        "${out_dir_root}" "${phe}" "${covars}"

    bash "${lab_repo_dir}/PRS/helper/plink_score.sh" \
        "${out_dir_root}" "${phe}" "${pfile}"
}

phe=$1
dataset="disease_outcome"
covars="age,sex,Array,PC1,PC2,PC3,PC4"

ml load snpnet anaconda/Anaconda3-5.3.0-Linux-x86_64_20181113 zstd

post_process ${phe} ${dataset} ${covars}


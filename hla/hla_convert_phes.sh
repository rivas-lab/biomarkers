#!/bin/bash

ml load plink2/20190826
phe_dir="/oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/hla_phe_data"

for file in $(ls $phe_dir); do
    pheno=$(echo $file | cut -d'/' -f12 | cut -d'.' -f1);
    plink2 --bpfile /oak/stanford/groups/mrivas/private_data/ukbb/24983/cal/pgen/ukb24983_cal_cALL_v2_hg19 --pheno $phe_dir/$file --pheno-quantile-normalize --remove /oak/stanford/groups/mrivas/ukbb24983/sqc/ukb24983_v2.not_used_in_pca.phe --keep /oak/stanford/groups/mrivas/ukbb24983/sqc/population_stratification/ukb24983_white_british.phe --write-covar cols=fid,pheno1 --out /oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/hla_wb_norm_phe_data/$pheno;
    mv /oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/hla_wb_norm_phe_data/$pheno.cov /oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/hla_wb_norm_phe_data/$pheno.phe;
    tail -n +2 /oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/hla_wb_norm_phe_data/$pheno.phe > /oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/hla_wb_norm_phe_data/$pheno.phe.tmp && mv /oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/hla_wb_norm_phe_data/$pheno.phe.tmp /oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/hla_wb_norm_phe_data/$pheno.phe
done

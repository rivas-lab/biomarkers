#!/bin/bash
set -beEuo pipefail

index_file="../../cascade/cascade.input.files.tsv"
out_dir="/oak/stanford/groups/mrivas/projects/biomarkers/meta/figshare_submission"

array_f="/oak/stanford/groups/mrivas/projects/biomarkers_rivas/meta_flipfixed/METAANALYSIS_{{trait}}_1.tbl.gz"
imp_f="/oak/stanford/groups/mrivas/projects/biomarkers/meta/plink_imputed/filtered/GLOBAL_{{trait}}.sumstats.tsv.gz"

cat ${index_file} | awk -v FS='\t' '(NR>1){print $2}' | while read trait ; do
    echo ${trait}

    zcat $(echo ${array_f} | sed -e "s/{{trait}}/${trait}/g" | sed -e "s/adjstatins/adjust_statins/g") \
        | bgzip -l9 -@6 > ${out_dir}/${trait}.array.gz

    singularity run -H /home/jobyan /scratch/groups/mrivas/users/ytanigaw/simg/jupyter_yt_20200428.sif \
        Rscript imp_sumstats_format.R \
    $(echo ${imp_f} | sed -e "s/{{trait}}/${trait}/g") \
    ${out_dir}/${trait}.imp
    
    bgzip -f -l9 -@6 ${out_dir}/${trait}.imp
    
    tabix -f -c '#' -s 1 -b 2 -e 2 ${out_dir}/${trait}.array.gz
    tabix -f -c '#' -s 1 -b 2 -e 2 ${out_dir}/${trait}.imp.gz
done


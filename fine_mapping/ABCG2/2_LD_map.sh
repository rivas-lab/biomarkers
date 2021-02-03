#!/bin/bash
set -beEuo pipefail

cpus=6
mem=50000

out_d="@@@@@@/projects/biomarkers/fine_mapping/ABCG2"
keep_file="@@@@@@/ukbb24983/sqc/population_stratification_w24983_20190809/ukb24983_white_british.phe"

ml load plink2/20200531
ml load plink/1.90b6.17

out_prefix="${out_d}/ukb24983_ABCG2"

plink --threads ${cpus} --memory ${mem} \
--keep-allele-order \
--bfile ${out_prefix} \
--keep ${keep_file} \
--ld-window-kb 1000 --ld-window-r2 0.1 --r2 gz \
--ld-window 100000000 \
--out ${out_prefix}.ld_map    

zcat ${out_prefix}.ld_map.ld.gz \
| awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6, $7}' \
| sed -e "s/^CHR_A/#CHR_A/g" \
| bgzip -l9 -@${cpus} > ${out_prefix}.ld_map.tsv.gz
tabix -c '#' -s 1 -b 2 -e 5 ${out_prefix}.ld_map.tsv.gz 

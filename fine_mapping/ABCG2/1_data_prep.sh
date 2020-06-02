#!/bin/bash
set -beEuo pipefail

cpus=6
mem=50000

ukb_d="/oak/stanford/groups/mrivas/ukbb24983"
out_d="/oak/stanford/groups/mrivas/projects/biomarkers/fine_mapping/ABCG2"

ml load plink2/20200531
ml load plink/1.90b6.17

# imputation data set

tabix /oak/stanford/groups/mrivas/ukbb24983/imp/annotation/annot.tsv.gz 4:89006461-89157437 \
| grep ABCG2 \
| awk -v OFS=':' '{print $1, $2, $3, $4}' \
| plink2 --threads ${cpus} --memory ${mem} \
--pfile ${ukb_d}/imp/pgen/ukb24983_imp_chr4_v3 vzs \
--extract /dev/stdin \
--out ${out_d}/ukb24983_ABCG2_imp \
--make-bed

mv ${out_d}/ukb24983_ABCG2_imp.log ${out_d}/ukb24983_ABCG2_imp.bed.log

# array data set

zcat /oak/stanford/groups/mrivas/private_data/ukbb/variant_filtering/variant_filter_table.tsv.gz \
| grep ABCG2 \
| cut -f5 \
| plink2 --threads ${cpus} --memory ${mem} \
--pfile ${ukb_d}/cal/pgen/ukb24983_cal_cALL_v2 \
--extract /dev/stdin \
--out ${out_d}/ukb24983_ABCG2_cal \
--make-bed

mv ${out_d}/ukb24983_ABCG2_cal.log ${out_d}/ukb24983_ABCG2_cal.bed.log

# merge them

plink --threads ${cpus} --memory ${mem} \
--keep-allele-order \
--bfile  ${out_d}/ukb24983_ABCG2_cal \
--bmerge ${out_d}/ukb24983_ABCG2_imp \
--out ${out_d}/ukb24983_ABCG2 \
--make-bed
mv ${out_d}/ukb24983_ABCG2.log ${out_d}/ukb24983_ABCG2.bed.log

plink2 --threads ${cpus} --memory ${mem} \
--keep-allele-order \
--bfile ${out_d}/ukb24983_ABCG2 \
--out   ${out_d}/ukb24983_ABCG2 \
--make-pgen vzs
mv ${out_d}/ukb24983_ABCG2.log ${out_d}/ukb24983_ABCG2.pgen.log

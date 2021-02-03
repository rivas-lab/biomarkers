#!/bin/bash
set -beEuo pipefail

phenotypes=$(cat ../../common/phenotypes.txt | awk '(NR>1){print $1}' | sort -u)
variants=@@@@@@/projects/biomarkers/phewas/v2_imp/finemapped.hits.loci.txt

memory=30000
nCores=6

for c in $(cat ${variants} | awk -v FS=':' '{print $1}' | sort -nu) ; do
# for c in 14 16 17 19 21 22 ; do

plink2 \
  --pheno-name ${phenotypes} \
  --extract ${variants} \
  --pfile @@@@@@/ukbb24983/imp/pgen/ukb24983_imp_chr${c}_v3 vzs \
  --chr ${c} \
  --covar @@@@@@/ukbb24983/sqc/ukb24983_GWAS_covar.phe \
  --covar-name age sex Array PC1-PC4 \
  --glm firth-fallback hide-covar omit-ref \
  --keep @@@@@@/ukbb24983/sqc/population_stratification/ukb24983_white_british.phe \
  --memory ${memory} \
  --pheno @@@@@@/ukbb24983/phenotypedata/master_phe/master.20191219.phe \
  --pheno-quantile-normalize \
  --threads ${nCores} \
  --out @@@@@@/projects/biomarkers/phewas/v2_imp/per_chr/ukb24983_imp_chr${c}_v3

done

# PheWAS for fine-mapped common coding variants on imputed dataset

We apply PheWAS analysis for the fine-mapped common coding variants outside of MHC region.

We tested associations across 43 variants (MAF > 1% and are located outside of MHC region) and 172 phenotypes and set Bonferroni corrected p-value threshold to be P < 5e-6.

## results

- Google Spreadsheet
  - [https://docs.google.com/spreadsheets/d/1j8q1Y7wnMg9nWUm0iT4wJvFfg_hgIXbrtvxelqWHeH4/edit#gid=517273342](https://docs.google.com/spreadsheets/d/1j8q1Y7wnMg9nWUm0iT4wJvFfg_hgIXbrtvxelqWHeH4/edit#gid=517273342)
  - We checked whether the variants are reported in GWAS catalog. If not, we called it as novel.
  - We also checked the FinnGen R2 for replication of our discovery
- Those two associations seem to be novel.
  - HC243 (Inguinal hernia), rs9379084
  - HC25 (Cataract), rs62621812

## Scripts and Notebook

- `1_phewas_loci_def.ipynb`: identify the list of variants for PheWAS.
  - `@@@@@@/projects/biomarkers/phewas/v2_imp/finemapped.hits.loci.txt`
- `2_phewas.sh`: run the PheWAS analysis for the selected variants & phenotypes
  - `2_phewas.log`: the log file from the plink run
  - The results files are split by chromosome and by phenotype.
- `3_phewas_combine.sh`: combine the results from plink run.
- `4_filter_phewas.ipynb`: we apply p-value filter and MHC filter

## Dataset

### Genotype

We use the imputed v3 dataset in the Rivas Lab.

- `@@@@@@/ukbb24983/imp/pgen/ukb24983_imp_chr{1-22}_v3.{pgen,pvar.zst,psam}`

We have canonicalized variant IDs (`chrom:pos:ref:alt`) for this genotype dataset.

### Phenotype

We use the latest `master.phe` file in the Rivas Lab and focus on the selected phenotypes for PheWAS.

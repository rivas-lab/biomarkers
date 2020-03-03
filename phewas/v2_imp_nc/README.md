# PheWAS for fine-mapped non-coding variants on imputed dataset

We apply PheWAS analysis for the fine-mapped non-coding variants outside of MHC region.

We tested associations across 2442 variants (MAF > 1% and are located outside of MHC region) and 172 phenotypes and set Bonferroni corrected p-value threshold to be P < 1e-7.

## ToDo

- I'm running `2_phewas.sh` in an interactive session as of 2/27 1:45 pm.

## results

- Google Spreadsheet
  - [https://docs.google.com/spreadsheets/d/1j8q1Y7wnMg9nWUm0iT4wJvFfg_hgIXbrtvxelqWHeH4/edit#gid=517273342](https://docs.google.com/spreadsheets/d/1j8q1Y7wnMg9nWUm0iT4wJvFfg_hgIXbrtvxelqWHeH4/edit#gid=517273342)
  - We checked whether the variants are reported in GWAS catalog. If not, we called it as novel.
  - We also checked the FinnGen R2 for replication of our discovery
- Those two associations seem to be novel.
  - HC243 (Inguinal hernia), rs9379084
  - HC25 (Cataract), rs62621812

## Scripts and Notebooks

- `1_phewas_loci_def.ipynb`: identify the list of variants for PheWAS.
  - `/oak/stanford/groups/mrivas/projects/biomarkers/phewas/v2_imp/finemapped.hits.loci.txt`
- `2_phewas.sh`: run the PheWAS analysis for the selected variants & phenotypes
  - `2_phewas.log`: the log file from the plink run
  - The results files are split by chromosome and by phenotype.
- `3_phewas_combine.sh`: combine the results from plink run.
- `4_filter_phewas.ipynb`: we apply p-value filter and MHC filter
- `5_LD_lookup.sh`: performs LD look up (r2 > 0.9).
  - 176 variants --> 392 variants
- `6_var_annot_lookup.sh`: using `tabix`, query the variant annotations for the PheWAS hits (+ LD)
- `7_merge_with_LD_look_up.ipynb`: merge tables
- `8_GWAS_catalog_lookup.ipynb`: merge with EBI-EMBL GWAS catalog
- `9_phewas_summary.ipynb`: summarize the results of manual inspection of novelity (using GWAS catalog)
- `10_finngen_R2_lookup_prep.ipynb`: for the novel variants from the GWAS catalog, look up, we scan FinnGen R2 dataset to seek for support of replication. This notebook extracts the list of variants for this analysis.
- `11_finngen_R2_lookup.sh`: We query the FinnGen R2 dataset using `tabix`.

## Dataset

### Genotype

We use the imputed v3 dataset in the Rivas Lab.

- `/oak/stanford/groups/mrivas/ukbb24983/imp/pgen/ukb24983_imp_chr{1-22}_v3.{pgen,pvar.zst,psam}`

We have canonicalized variant IDs (`chrom:pos:ref:alt`) for this genotype dataset.

### Phenotype

We use the latest `master.phe` file in the Rivas Lab and focus on the selected phenotypes for PheWAS.

### GWAS catalog

We use the GWAS catalog v.1.0.2 downloaded in `/scratch/groups/mrivas/public_data/gwas_catalog_20200216`.

### FinnGen R2

We use the FinnGen R2 downloaded and pre-processed in `/scratch/groups/mrivas/users/ytanigaw/20200114_FinnGen_R2`.


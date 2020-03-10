# PheWAS for fine-mapped non-coding variants on imputed dataset

We apply PheWAS analysis for the fine-mapped non-coding variants outside of MHC region.

We tested associations across 2442 variants (MAF > 1% and are located outside of MHC region) and 172 phenotypes and set Bonferroni corrected p-value threshold to be P < 1e-7.

## results

- Google Spreadsheet
  - [https://docs.google.com/spreadsheets/d/1j8q1Y7wnMg9nWUm0iT4wJvFfg_hgIXbrtvxelqWHeH4/edit#gid=517273342](https://docs.google.com/spreadsheets/d/1j8q1Y7wnMg9nWUm0iT4wJvFfg_hgIXbrtvxelqWHeH4/edit#gid=517273342)
  - We checked whether the variants are reported in GWAS catalog. If not, we called it as novel.
  - We also checked the FinnGen R2 for replication of our discovery

## Scripts and Notebooks

- [`1_phewas_loci_def.ipynb`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/1_phewas_loci_def.ipynb): identify the list of variants for PheWAS.
  - `/oak/stanford/groups/mrivas/projects/biomarkers/phewas/v2_imp/finemapped.hits.loci.txt`
- [`2_phewas.sh`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/2_phewas.sh): run the PheWAS analysis for the selected variants & phenotypes
  - [`2_phewas.log`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/2_phewas.log): the log file from the plink run
  - The results files are split by chromosome and by phenotype.
- [`3_phewas_combine.sh`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/3_phewas_combine.sh): combine the results from plink run.
- [`4_filter_phewas.ipynb`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/4_filter_phewas.ipynb): we apply p-value filter and MHC filter
- [`5_LD_lookup.sh`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/5_LD_lookup.sh): performs LD look up (`r2 > 0.9`).
  - 176 variants --> 392 variants
- [`6_var_annot_lookup.sh`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/6_var_annot_lookup.sh): using `tabix`, query the variant annotations for the PheWAS hits (+ LD)
- [`7_merge_with_LD_look_up.ipynb`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/7_merge_with_LD_look_up.ipynb): merge tables
- [`8_GWAS_catalog_lookup.ipynb`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/8_GWAS_catalog_lookup.ipynb): merge with EBI-EMBL GWAS catalog results. 
  - This step involves manual curation of phenotype match between UK Biobank and the GWAS catalog. 
  - To facilitate this procedure, we write `GBE_EBI_hits` table and used Google Spreadsheet for manual annotation. 
  - With the annotations, we generated one summary table and the joined table.
  - `phewas_hits_ld_gwas_catalog_summary`: summary table
  - `phewas_hits_ld_gwas_catalog`: the product of full-join (for debugging).
  - For more details, please check [the notebook](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/8_GWAS_catalog_lookup.ipynb).
- [`9_finngen_R2_lookup.sh`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/9_finngen_R2_lookup.sh): We query the FinnGen R2 dataset using `tabix`.
- [`10_finngen_R2_summary.ipynb`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/10_finngen_R2_summary.ipynb): We scan FinnGen R2 dataset to seek for support of replication. We apply the similar procedure as in [`8_GWAS_catalog_lookup.ipynb`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/8_GWAS_catalog_lookup.ipynb).

## Exported copy of annotated data

- [`phewas.xlsx`](https://github.com/rivas-lab/biomarkers/blob/master/phewas/v2_imp_nc/phewas.xlsx): an exported copy of Google Spreadsheet (named version `20200310`).

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


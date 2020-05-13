# The Biomarkers project in the Rivas Lab.

## Directory structure

- `covariate_correction`: (for adjusting for statins and covariates)
- `snakemake`: (for running the GWAS)
  - `filtration`: (for filtering GWAS results)
    - `meta`: (meta-analysis of the GWAS from multiple populations)
      - `meta_flipfix`: (flipping alleles on the meta-analysis)
      - `cascade`: (plotting of the variant effects)
      - `phewas`: (testing against other traits)
- `snpnet`: (generation of polygenic risk scores)

## Key info

- [trait names](https://github.com/rivas-lab/biomarkers/blob/master/common/canonical_trait_names.txt)
- [plotting color (on Supplementary table ST2)](https://docs.google.com/spreadsheets/d/1j8q1Y7wnMg9nWUm0iT4wJvFfg_hgIXbrtvxelqWHeH4/edit#gid=1708343077)

## File locations

- Phenotype file location
  - 
  - Residual: `/oak/stanford/groups/mrivas/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/combined.20190810.phe`
- GWAS summary statistics
  - `/oak/stanford/groups/mrivas/projects/biomarkers_rivas/main/<population>/ukb24983_v2_hg19.<trait>.genotyped.glm.linear.gz`
- M-A
  - `/oak/stanford/groups/mrivas/projects/biomarkers_rivas/meta_flipfixed/METAANALYSIS_<trait>_1.tbl.gz`

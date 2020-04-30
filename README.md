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

## File location

- GWAS summary statistics
  - `/oak/stanford/groups/mrivas/projects/biomarkers_rivas/main/<population>/ukb24983_v2_hg19.<trait>.genotyped.glm.linear.gz`
- M-A
  - `/oak/stanford/groups/mrivas/projects/biomarkers_rivas/meta_flipfixed/METAANALYSIS_<trait>_1.tbl.gz`

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
- [plotting color (on Supplementary table ST4)](https://docs.google.com/spreadsheets/d/1j8q1Y7wnMg9nWUm0iT4wJvFfg_hgIXbrtvxelqWHeH4/edit#gid=1708343077)

## figshare data release documents

We uploaded the supplementary data on figshare. Currently, they are not "published" yet, but we have private links and reserved the DOI for each (the DOI links will be activated when we make the datasets public).

- [GWAS summary statistics](meta_flipfix/figshare_submission)
  - Title: The meta-analyzed GWAS summary statistics for 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'
  - Private link: https://figshare.com/s/cf09ba22307487b0a399
  - DOI: https://doi.org/10.35092/yhjc.12355382
- [FINEMAP](fine_mapping/figshare_submission)
  - Title: The fine-mapped associations of 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'
  - Private link: https://figshare.com/s/19c49dce0a574e1af101
  - DOI: https://doi.org/10.35092/yhjc.12344351
- [snpnet](snpnet/figshare_submission)
  - Title: The snpnet polygenic risk score coefficients for 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'
  - Private link: https://figshare.com/s/43dfccf0c59d89f36ea0
  - DOI: https://doi.org/10.35092/yhjc.12298838
- [multi-PRS](multiprs/figshare_submission)
  - Title: The multi-PRS weights computed with the 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'
  - Private link: https://figshare.com/s/5ba64acb9a62caea5632
  - DOI: https://doi.org/10.35092/yhjc.12355424

## File locations

- [Phenotype file location](covariate_correction/path_to_phenotypes.md)
  - Residual: `/oak/stanford/groups/mrivas/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/combined.20190810.phe`
- GWAS summary statistics
  - `/oak/stanford/groups/mrivas/projects/biomarkers_rivas/main/<population>/ukb24983_v2_hg19.<trait>.genotyped.glm.linear.gz`
- M-A
  - `/oak/stanford/groups/mrivas/projects/biomarkers_rivas/meta_flipfixed/METAANALYSIS_<trait>_1.tbl.gz`

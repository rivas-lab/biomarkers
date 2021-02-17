# Genetics of 35 biomarkers project in the Rivas Lab

![Fig 1](/figures/Figure1.png)

![Fig 2](/figures/Figure2ArmstrongTanigawa-low-res.png)

We characterized the genetics of 35 biomarkers in UK Biobank. We performed the association and fine-mapping analysis to prioritize the causal variants, constructed the polygenic risk score (PRS) models, and evaluated their medical relevance with causal inference and PRS-PheWAS. We demonstrate a new approach, called multi-PRS, to improve PRS by combining PRSs across traits.

## Directory structure in this GitHub repository

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

We uploaded the supplementary data on figshare.

- [GWAS summary statistics](meta_flipfix/figshare_submission)
  - Title: The meta-analyzed GWAS summary statistics for 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'
  - DOI: https://doi.org/10.35092/yhjc.12355382
- [snpnet](snpnet/figshare_submission)
  - Title: The snpnet polygenic risk score coefficients for 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'
  - DOI: https://doi.org/10.35092/yhjc.12298838
- [multi-PRS](multiprs/figshare_submission)
  - Title: The multi-PRS weights computed with the 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'
  - DOI: https://doi.org/10.35092/yhjc.12355424

## File locations

- [Phenotype file location](covariate_correction/path_to_phenotypes.md)
  - Residual: `@@@@@@/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/combined.20190810.phe`
- GWAS summary statistics
  - `@@@@@@/projects/biomarkers_rivas/main/<population>/ukb24983_v2_hg19.<trait>.genotyped.glm.linear.gz`
- M-A
  - `@@@@@@/projects/biomarkers_rivas/meta_flipfixed/METAANALYSIS_<trait>_1.tbl.gz`

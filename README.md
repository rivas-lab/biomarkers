Hierarchy of scripts that are run:

covariate_correction (for adjusting for statins and covariates)
- snakemake (for running the GWAS)
  - filtration (for filtering GWAS results)
    - meta (meta-analysis of the GWAS from multiple populations)
      - meta_flipfix (flipping alleles on the meta-analysis)
      - cascade (plotting of the variant effects)
      - phewas (testing against other traits)
- snpnet (generation of polygenic risk scores)

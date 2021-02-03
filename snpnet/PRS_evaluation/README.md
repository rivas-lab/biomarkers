# PRS predictive performance evaluation

For the final set of 35 phenotypes, we evaluated the predictive performance of the polygenic risk scores, which is reported in the last 3 columns in ST17.

We have three "risk scores":

- the snpnet PRSs computed for the covariate-adjusted phenotypes
  - this risk scores are computed with the genetic features alone
- the risk score computed from the covariates.
  - Specifically, this is computed by taking the difference between the original log-transformed phenotype and the covariate adjusted phenotype.
- the "total" risk score computed as the sum of the two.

We compute the r2 metric for log-transformed phenotypes across the following sets of individuals.

- White British (in the test set who are not used in the snpnet PRS computation)
- Non-British white individuals
- African individuals
- South Asian individuals
- East Asian individuals.

## notebooks

- [`1_eval.ipynb`](1_eval.ipynb): this notebook reads the relevant files and compute the r2 metric.
  - input phenotype file: `@@@@@@/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/residual_and_logtransformed_and_raw_biomarker_phenotypes_20200524.tsv`
  - the results are saved in [`snpnet_prs_eval.tsv`](snpnet_prs_eval.tsv).
- [`2_combine_res.ipynb`](2_combine_res.ipynb): this notebook fetchs the ST17 and combine with r2 metric.
  - the results are saved in [`combined_table.tsv`](combined_table.tsv)

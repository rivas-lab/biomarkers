# PRS predictive performance evaluation

For the final set of 35 phenotypes, we evaluated the predictive performance of the polygenic risk scores.
To quantify the predictive performance of (1) PRS (with genetic features alone), (2) the risk score comptued with covariates alone, and the (3) combined risk score computed from both genetics and covariates, we computed the following three scores:

1. PRS (the snpnet PRS score)
2. covar_score := `raw_phe - residual_phe`
3. total_score := `covar_score + PRS`

We used the following files as the "raw" phenotype file

```{R}
phe_raw_f <- '/oak/stanford/groups/mrivas/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/full.table.phe'
# for AST_ALT_ratio
phe_raw_add1_f <- '/oak/stanford/groups/mrivas/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/derived/AST_ALT_ratio.phe'
# for Glucose
phe_raw_add2_f <- '/oak/stanford/groups/mrivas/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/full.table.glucose.phe'
```

And this one for the residuals.

```{R}
phe_residual_f <- '/oak/stanford/groups/mrivas/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/combined.20190810.phe'
```

The evaluation script is here: [`1_eval.ipynb`](1_eval.ipynb).

# Flipfix & flipcheck on the meta-analysis results

## Flipfixed/flipchecked results:

- `@@@@@@/projects/biomarkers_rivas/meta_flipfixed/`
- `@@@@@@/projects/biomarkers/meta/plink_imputed/filtered`

## Methods

### Array
Flipfix of the meta-analysis results

- `meta_flip_fix.R` and `meta_flip_fix.sh` are the flipfix script
- `run-jobs.sh` apply the script for the input files specified in `jobs.lst`
- `run-jobs.log` is a log file

```
[ytanigaw@sh-109-53 ~/repos/rivas-lab/public-resources/uk_biobank/biomarkers/meta_flipfix]$ bash run-jobs.sh 2>&1 | tee run-jobs.log
```

### Imputation

https://github.com/rivas-lab/biomarkers/blob/master/meta_flipfix/meta_imp_flip_check.R
https://github.com/rivas-lab/biomarkers/blob/master/meta_flipfix/meta_imp_flip_check.sh


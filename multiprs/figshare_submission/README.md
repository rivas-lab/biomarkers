# figshare submission

## figshare

- Private link: https://figshare.com/s/5ba64acb9a62caea5632
- DOI: https://doi.org/10.35092/yhjc.12355424

## draft of the data descriptor on figshare

### title

The multi-PRS weights computed with the 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'

### description

The dataset contains the multi-PRS weights computed with the 35 biomarker traits described in the following pre-print:

N. Sinnott-Armstrong*, Y. Tanigawa*, et al, Genetics of 38 blood and urine biomarkers in the UK Biobank. bioRxiv, 660506 (2019). doi:10.1101/660506

Note that we are preparing a revised version of the manuscript and this dataset contains 35 (instead of 38) biomarker phenotypes.

The list of disease endpoints included in this dataset is: angina, alcoholic cirrhosis, gallstones, hypertension, cholecystitis, kidney failure, heart failure, myocardial infarction, gout, and type 2 diabetes (T2D).

We provide weights of the 23 polygenic risk scores characterized by multi-PRS. The list of models are summarized in [`list_of_multi-PRS-models.tsv`](list_of_multi-PRS-models.tsv). This index file the following columns:

- Filename: the filename of polygenic risk score weights in this dataset.
- Trait: the disease outcome.
- Covariate_adjustment: a binary variable indicating whether the multi-PRS model is traied with covariate (age, sex, and PC1-10) adjustment.
- Family_history_adjustment: a binary variable indicating whether the multi-PRS model is traied with family history.
- Note: Additional information when relevant.

For the PRS models listed with "Covariate_adjustment == TRUE", we fit multi-PRS regression model adjusted by age, sex, and 10 principal components where as the ones with "Covariate_adjustment == FALSE" we did not use those covariates.

For T2D, we have two sets of models: (1) models traied for Eastwood et al. T2D cases in UK Biobank and (2) models traied for Eastwood et al. T2D cases in UK Biobank vs. filtered controls with HbA1c < 39.

For myocardial infarction, we provide a model with family history adjustment, [`weights_familyhistory.HC326.tsv.gz`](weights_familyhistory.HC326.tsv.gz). This model is traied with covariates (age, sex, and 10 principal components) and family history of heart disease as covariates.

Please read our manuscript for more details.

For each PRS model listed in [`list_of_multi-PRS-models.tsv`](list_of_multi-PRS-models.tsv), we provide a compressed tab-delimited files, which contain the multi-PRS weights. The files have the following columns:

- CHROM: the chromosome
- POS: the position
- ID: the variant identifier
- REF: the reference allele
- ALT: the alternate allele
- A1: the risk allele
- weights.<trait>: the coefficients (weights) of the PRS

Note that we used GRCh37/hg19 genome reference in the analysis and the BETA is always reported for the alternate allele.

The multi-PRS weights files are compressed with `gzip`. One should be able to read those files with the standard `gzip`/`zcat`.

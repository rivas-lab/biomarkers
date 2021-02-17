# figshare submission

We used [`export_snpnet_BETA.R`](export_snpnet_BETA.R) to export the PRS coefficients and released it on figshare.

## figshare

- DOI: https://doi.org/10.35092/yhjc.12298838

## draft of the data descriptor on figshare

### title

The snpnet polygenic risk score coefficients for 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'

### description

The dataset contains the coefficients of the polygenic risk scores for 35 biomarker traits described in the following pre-print:

N. Sinnott-Armstrong*, Y. Tanigawa*, et al, Genetics of 38 blood and urine biomarkers in the UK Biobank. bioRxiv, 660506 (2019). doi:10.1101/660506

Note that we are preparing a revised version of the manuscript and this dataset contains 35 (instead of 38) biomarker phenotypes.

We provide the list of 35 biomarkers in "list_of_35_biomarkers.tsv". We used the "Phenotype_name" column in this table for the file names.

For each phenotype, we provide a compressed tab-delimited table, named "snpnet.BETAs.[Phenotype_name].tsv.gz", which contains the coefficients (weights) of the polygenic risk score and have the following columns:

- CHROM: the chromosome
- POS: the position
- ID: the variant identifier
- REF: the reference allele
- ALT: the alternate allele
- BETA: the coefficients (weights) of the PRS

Note that we used GRCh37/hg19 genome reference in the analysis and the BETA is always reported for the alternate allele.

We used the BASIL algorithm implemented in R snpnet package, which is described in another preprint:

J. Qian, et al, A Fast and Flexible Algorithm for Solving the Lasso in Large-scale and Ultrahigh-dimensional Problems. bioRxiv, 630079 (2019). doi:10.1101/630079

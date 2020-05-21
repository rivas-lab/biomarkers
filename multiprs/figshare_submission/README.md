# figshare submission

## draft of the data descriptor on figshare

### title

The multi-PRS weights computed with the 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'

### description

The dataset contains the multi-PRS weights computed with the 35 biomarker traits described in the following pre-print:

N. Sinnott-Armstrong*, Y. Tanigawa*, et al, Genetics of 38 blood and urine biomarkers in the UK Biobank. bioRxiv, 660506 (2019). doi:10.1101/660506

Note that we are preparing a revised version of the manuscript and this dataset contains 35 (instead of 38) biomarker phenotypes.

We provide the list of 35 biomarkers and the disease endpoints in "list_of_35_biomarkers.tsv" and @@@@@, respectively. 

For each disease endpoint, we provide a compressed tab-delimited files, named "@@@@@@", which contain the multi-PRS weights. The files have the following columns:

- ID: the variant identifier
- A1: the risk allele
- <biomarker_trait>.SCORE1_SUM: the snpnet-PRS weights for each of the 35 biomarker traits
- sex: @@@@@@@@
- age: @@@@@@@@
- PC1, PC2, ..., PC10: @@@@@@@@
- combined.SCORE1_SUM: @@@@@@@@

Note that we used GRCh37/hg19 genome reference in the analysis and the BETA is always reported for the alternate allele.

The multi-PRS weights files are compressed with `gzip`. One should be able to read those files with the standard `gzip`/`zcat`.

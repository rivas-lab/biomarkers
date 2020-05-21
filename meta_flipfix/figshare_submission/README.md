# figshare submission

We used [`1_substats_prep.sh`](1_substats_prep.sh) to prepare the flip-fixed meta-analyzed summary statistics. The imputation summary statistics did not have CHROM and POS columns so we added them back with [`imp_sumstats_format.R`](imp_sumstats_format.R).

## draft of the data descriptor on figshare

### title

The meta-analyzed GWAS summary statistics for 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'

### description

The dataset contains meta-analyzed GWAS summary statistics for 35 biomarker traits described in the following pre-print:

N. Sinnott-Armstrong*, Y. Tanigawa*, et al, Genetics of 38 blood and urine biomarkers in the UK Biobank. bioRxiv, 660506 (2019). doi:10.1101/660506

Note that we are preparing a revised version of the manuscript and this dataset contains 35 (instead of 38) biomarker phenotypes.

We provide the list of 35 biomarkers in "list_of_35_biomarkers.tsv". We used the "Phenotype_name" column in this table for the file names.

For each phenotype, we provide two compressed tab-delimited files, named "<Phenotype_name>.array.gz" and "<Phenotype_name>.imp.gz", which contain the summary statistics for genetic variants on the genotyping array and the imputed dataset, respectively. We used METAL for the meta-analysis for 4 populations (White Brisith, non-Brisith White, African, and South Asian) within UK Biobank. The files have the following columns:

- CHROM: the chromosome
- POS: the position
- MarkerName: the variant identifier
- REF: the reference allele
- ALT: the alternate allele
- Effect: the effect size (BETA) estimate
- StdErr: the standard error of effect size estimate
- P-value: the p-value of the association
- Direction: the direction of effect size
- HetISq, HetChiSq, HetDf, HetPVal: heterogeneity statistics from METAL

Note that we used GRCh37/hg19 genome reference in the analysis and the BETA is always reported for the alternate allele.

Please also check the METAL documentation (https://genome.sph.umich.edu/wiki/METAL_Documentation).

The summary statistic files are compressed with `bgzip` and indexed with `tabix` (the `.tbi` files). One should be able to read those files with the standard `gzip`/`zcat`.

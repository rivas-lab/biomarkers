# figshare submission

We used [`1_index_file.sh`](1_index_file.sh) to generate the list of regions and [`2_tar.sh`](2_tar.sh) to generate tar files of the fine-mapped associations. Using the figshare API ([`figshare_API_misc.py`](figshare_API_misc.py) is the functions and we have a usage docs [here](https://gist.github.com/yk-tanigawa/8bc3330bd44cce12e2d6b82c74318bdf)), we uploaded the tar files using [`3_upload_FINEMAP.py`](3_upload_FINEMAP.py) and [`3_upload_FINEMAP.sh`](3_upload_FINEMAP.sh). We used [`4_upload_FINEMAP_check.py`](4_upload_FINEMAP_check.py) to check the completion of the upload.

## figshare

- Private link: https://figshare.com/s/19c49dce0a574e1af101
- DOI: https://doi.org/10.35092/yhjc.12344351

## draft of the data descriptor on figshare

### title

The fine-mapped associations of 35 lab biomarkers described in 'Genetics of 35 blood and urine biomarkers in the UK Biobank'

### description

The dataset contains the output from FINEMAP, a software to identify causcal variants from genome-wide association summary statistics, for 35 biomarker traits described in the following pre-print:

N. Sinnott-Armstrong*, Y. Tanigawa*, et al, Genetics of 38 blood and urine biomarkers in the UK Biobank. bioRxiv, 660506 (2019). doi:10.1101/660506

Note that we are preparing a revised version of the manuscript and this dataset contains 35 (instead of 38) biomarker phenotypes.

For each trait, we provide a tar archive file which contains the full output from FINEMAP for the regions with at least one genome-wide significant associations (p < 5e-9) from the multi-ethnic GWAS meta-analysis within UK Biobank. The content of the tar archive is organized by directories, named as `chr1<CHROM>/<TRAIT>/range<RANGE>`, and contains the following files:

- `GLOBAL_<TRAIT>_chr<CHROM>_range<RANGE>.bdose.zst`
- `GLOBAL_<TRAIT>_chr<CHROM>_range<RANGE>.config.zst`
- `GLOBAL_<TRAIT>_chr<CHROM>_range<RANGE>.cred<idx>.zst`
- `GLOBAL_<TRAIT>_chr<CHROM>_range<RANGE>.ld.zst`
- `GLOBAL_<TRAIT>_chr<CHROM>_range<RANGE>.master.zst`
- `GLOBAL_<TRAIT>_chr<CHROM>_range<RANGE>.snp.zst`
- `GLOBAL_<TRAIT>_chr<CHROM>_range<RANGE>.z.zst`

where, 

- `<TRAIT>`: trait name
- `<CHROM>`: chromosome
- `<RANGE>`: the range of the region in the format of `<start position>-<end position>`.

We provide the list of traits and regions included in this data release in `FINEMAP.index.tsv`. This is a flat table with 3 columns:

- trait: the biomarker trait
- chr: chromosome
- range: the range

Note that we used GRCh37/hg19 genome reference in the analysis and the BETA is always reported for the alternate allele.

Please check the FINEMAP paper and software documentation for the detailed explanation of the file formats.

- Benner, C. et al. FINEMAP: efficient variable selection using summary data from genome-wide association studies. Bioinformatics 32, 1493–1501 (2016).
- Christian Benner. FINEMAP. http://christianbenner.com/.

Also, all the files in the tar archive is compressed with Zstandard (as indicated by the `.zst` extension). You can check the contents with `zstdcat` command and uncompress the files with `zstd -d <file.zst>`. The Zstandard software can be built from source, or simply available from conda (https://anaconda.org/conda-forge/zstd), pip (https://pypi.org/project/zstd/) or brew (https://formulae.brew.sh/formula/zstd). Please check Zstandard website (http://facebook.github.io/zstd/) for more information.

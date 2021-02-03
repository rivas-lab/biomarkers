# filtered hits from fine-mapped results

The scripts in this directory extracts the filtered hits (p < 5e-9 AND posterior prob. > .99), fetch variant annotations, and write it into a file. `generate_filtered_hits.sh` is the script used to generate the results file (`filtered.hits.99.anno.joined.tsv`).

The results are pushed to: https://docs.google.com/spreadsheets/d/12SO-O9-GzSiSRjFJb0WvNi166oiR_Dls-CI9KGc9kGo
(It is part of the Google Drive shared folder: https://drive.google.com/drive/folders/1i6w0qQRfrv-vEi7NIMh2yoSsCgTYtdE-)

The `region` column in the output file represents the region ID of the variant. The corresponding `.z` files are stored in here: `@@@@@@/users/christian/chr{CHROM}/{TRAIT}/GLOBAL_{TRAIT}_chr{CHROM}_range{BEGIN}-{END}.z`

update  (2020/2/12): we add region ID in the output file.

## Reference
- [http://christianbenner.com](http://christianbenner.com): Christian's website has the column descriptions of the `.z` file.

#!/bin/bash
set -beEuo pipefail

generate_region_file () {
    local trait=$1
    
    cut -f 1 /oak/stanford/groups/mrivas/projects/biomarkers/meta/plink_imputed/filtered_hits_5e9/GLOBAL_${trait}.1cm.hits \
    | grep -Ff /dev/stdin ${trait}_valid.tsv \
    | awk '(NR>1) {print $13;}' \
    | xargs -n1 -I % find % -name '*.snp' \
    | while read f ; do basename $f .snp ; done \
    | sed -e "s/GLOBAL_${trait}_chr//g" \
    | sed -e "s/range//g" \
    | tr "_" "\t" \
    | tr "-" "\t" \
    | awk -v FS='\t' -v OFS='\t' -v trait="${trait}" \
    '{print $0, trait, "chr" $1 "_range" $2 "-" $3}'
}

{
echo "#CHROM BEGIN END TRAIT REGION_ID" | tr " " "\t"

cat ../../common/canonical_trait_names.txt | awk -v FS='\t' '(NR>1){print $2}' \
| while read trait ; do
    generate_region_file $trait
done | sort --parallel 6 -k1,1V -k2,2n -k3,3n
} | bgzip -@6 -f -l9 > filtered_regions.txt.gz

tabix -c '#' -s 1 -b 2 -e 3 filtered_regions.txt.gz

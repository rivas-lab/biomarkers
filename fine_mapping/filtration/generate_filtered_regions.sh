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
    | awk -v FS='\t' -v trait=${trait} '{print trait, $0}'
}

trait=AST_ALT_ratio
generate_region_file $trait > filtered_regions/${trait}.txt

exit 0
cat ../../common/canonical_trait_names.txt | awk -v FS='\t' '(NR>1){print $2}' \
| while read trait ; do
    generate_region_file $trait > filtered_regions/${trait}.txt
done

#!/bin/bash
set -beEuo pipefail

thr="0.99" # threshold on probability

echo "trait $(cat ../filtration/header.finemapping.txt)" | tr " " "\t"

cat ../../common/canonical_trait_names.txt \
| awk -v FS='\t' '(NR>1){print $2}' \
| while read trait ; do
    cat ../filtration/${trait}_subset.tsv \
    | awk -v trait=${trait} -v thr=${thr} '($11 >= thr){print trait, $0;}' \
    | tr " " "\t"
done

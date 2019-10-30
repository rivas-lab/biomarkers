#!/bin/bash
set -beEuo pipefail

cat jobs.lst | while read in_f ; do
out_f="$(echo $in_f | sed -e "s%meta%meta_flipfixed%g")"
phe=$(basename $in_f .tbl | sed -e "s/METAANALYSIS_//g")
echo $phe
bash meta_flip_fix.sh $in_f $out_f
done


ls /oak/stanford/groups/mrivas/users/christian/chr*/* -d | xargs -n1 basename | sort | uniq | while read trait; do echo $trait; Rscript genz.R ${trait}_valid.tsv /oak/stanford/groups/mrivas/projects/biomarkers/meta/plink_imputed/tagged/GLOBAL_${trait}.var `find /oak/stanford/groups/mrivas/users/christian/*/$trait/range* -name '*.z'`; done

ls *_valid.tsv | while read trait; do echo $trait; grep -Ff <(cut -f 1 /oak/stanford/groups/mrivas/projects/biomarkers/meta/plink_imputed/filtered_hits_5e9/GLOBAL_`basename $trait _valid.tsv`.1cm.hits) $trait | awk '(NR>1) {print $13;}' | xargs -n1 -I % find % -name '*.snp' | xargs grep -v -h chromosome > `basename $trait _valid.tsv`_subset.tsv; done

(echo trait post count; ls *_subset.tsv | while read chr; do for threshold in 0.999 0.99 0.95 0.9 0.75 0.5; do echo `basename $chr _subset.tsv` $threshold `awk -v threshold=$threshold '$11 > threshold' $chr | wc -l`; done; done) > trait_count_dist.cleaned.tsv

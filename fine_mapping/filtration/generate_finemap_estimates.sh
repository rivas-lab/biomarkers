# Description of what happens
# list the contents of the fine mapping directories
ls @@@@@@/users/christian/chr*/* -d |
# Get the directory trait name
xargs -n1 basename |
# make unique
sort | uniq |
# print interactive status while looping over traits
while read trait; do echo $trait;
    # generate the valid file by filtering ranges to those containing a SNP that is in our final hit list
    Rscript genz.R ${trait}_valid.tsv @@@@@@/projects/biomarkers/meta/plink_imputed/tagged/GLOBAL_${trait}.var \ 
    # Find all the .z files within any range for this trait, passed to that script
    `find @@@@@@/users/christian/*/$trait/range* -name '*.z'`;
# Finish loop over traits
done


# The tagged files are based on a 5e-8 cutoff, so further filter to 5e-9

# For each valid list of ranges
ls *_valid.tsv | while read trait; do
    echo $trait
    # Find variants that are in the valid list *and* p < 5e-9
    grep -Ff <(cut -f 1 @@@@@@/projects/biomarkers/meta/plink_imputed/filtered_hits_5e9/GLOBAL_`basename $trait _valid.tsv`.1cm.hits) $trait |
        # Pull out the corresponding regions
        awk '(NR>1) {print $13;}' |
        # For each region, find all the SNP files in that region
        xargs -n1 -I % find % -name '*.snp' |
        # And for each SNP file, remove the header and write all the lines to the subset.tsv
        xargs grep -v -h chromosome > `basename $trait _valid.tsv`_subset.tsv
done

# Make header
(echo trait post count;
    # For each subset file
    ls *_subset.tsv | while read chr; do
        # At each variant p-value cutoff
        for threshold in 0.999 0.99 0.95 0.9 0.75 0.5; do
            # count the number of variants with PPA greater than that threshold
            echo `basename $chr _subset.tsv` $threshold `awk -v threshold=$threshold '$11 > threshold' $chr | wc -l`; done; done) >
# write counts to the output file used for plotting
    trait_count_dist.cleaned.tsv

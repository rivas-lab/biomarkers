`*_valid.tsv` contains all variants which are in a block with a variant that has p < 5e-8 in the meta-analysis.

`*_subset.tsv` contains all variants which are in a block with a lead variant that has p < 5e-8 in the meta-analysis.

`trait_count_dist.cleaned.tsv` contains the counts of the number of causal variants summed across regions that have a posterior greater than the given threshold.

`trait_count_dist.tsv` contains the unfiltered results as a comparison (all variants p < 1e-3).

`generate_finemap_estimates.sh` has the code for filtering to produce these results.

`genz.R` has the code for generating the valid.tsv entries.

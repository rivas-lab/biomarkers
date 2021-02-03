#!/bin/bash

output_dir="@@@@@@/users/guhan/sandbox/hla_biomarkers/scripts/bma_output_191104"

echo -e "ALL_ID\tposterior_mean\tposterior_sd\tposterior_prob\tPHENO" > "complete_sig_bma_results.tsv"
for file in $(ls $output_dir | grep tsv); do
    awk -F'\t' '{if ((NR > 1) && ($1 != "age") && ($1 != "sex") && ($1 != "Array") && ($1 != "PC1") && ($1 != "PC2") && ($1 != "PC3") && ($1 != "PC4") && ($4 >= 80)) {print}}' $output_dir/$file >> "complete_sig_bma_results.tsv";
done

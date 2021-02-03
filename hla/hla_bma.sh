#/bin/bash

# get the phe files from this directory
phe_dir="@@@@@@/users/guhan/sandbox/hla_biomarkers/hla_wb_norm_phe_data"
# write to this directory
batch_dir="@@@@@@/users/guhan/sandbox/hla_biomarkers/hla_bma_adjusted_batch_logs"

# for every phenotype in phe_dir...
for pheno in $(ls $phe_dir | grep phe); do
    sbatch -J $pheno -o $batch_dir/$pheno.out  -t 12:00:00 -p normal,mrivas,owners -N 1 --mem=25000 --wrap="Rscript bma.R $phe_dir/$pheno 10"
done

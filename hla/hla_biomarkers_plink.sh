#/bin/bash
ml load plink2/20190826
# get the phe files from this directory
phe_dir="@@@@@@/users/guhan/sandbox/hla_biomarkers/hla_phe_data"
# get the covariates from this directory
covar_file="@@@@@@/ukbb24983/sqc/ukb24983_GWAS_covar.phe"
out_dir="@@@@@@/users/guhan/sandbox/hla_biomarkers/hla_plink_output"
batch_dir="@@@@@@/users/guhan/sandbox/hla_biomarkers/plink_batch_logs"
data_dir="@@@@@@/users/guhan/sandbox/hla_biomarkers/hla_genotype_data"
white_british="@@@@@@/ukbb24983/sqc/population_stratification/ukb24983_white_british.phe"

# for every phenotype in phe_dir...
for pheno in $(ls $phe_dir); do
    # submit a batch job that wraps a plink command. this one will run with 24Gb RAM, 4 threads on white british pop, for HLA allelotype dosages, Age/Sex/PC1-4 covars, linear/logistic, for phe of choice
    sbatch -J $pheno -o $batch_dir/$pheno.out  -t 1:00:00 -p normal,mrivas,owners -N 1 --mem=25000 --wrap="plink2 --memory 24000 --threads 4 --keep $white_british --bfile $data_dir/ukb_hla_v3 --pheno $phe_dir/$pheno --covar $covar_file --out $out_dir/$pheno.out --covar-name age sex PC1 PC2 PC3 PC4 --glm firth-fallback"
done

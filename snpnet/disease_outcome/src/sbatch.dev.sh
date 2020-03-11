#!/bin/bash
#SBATCH --job-name=snpnet
#SBATCH --output=logs/snpnet.%A.out
#SBATCH  --error=logs/snpnet.%A.err
#SBATCH --nodes=1
#SBATCH --cores=8
#SBATCH --mem=128000
#SBATCH --time=2-00:00:00
#SBATCH -p mrivas,normal
set -beEuo pipefail

############################################################
# Required arguments for ${snpnet_wrapper} script
############################################################
genotype_pfile="/scratch/users/ytanigaw/tmp/snpnet/geno/array_combined/ukb24983_cal_hla_cnv"
phe_file="$OAK/projects/biomarkers/snpnet/disease_outcome/phe.tsv"
phenotype_name=$1 # One may use phenotype_name=$1 etc
phenotype_cat=$(echo ${phenotype_name} | sed -e "s/[0-9]*$//g")
if [ ${phenotype_cat} == 'INI' ] ; then
    family="gaussian"
else
    family="binomial"
fi
results_dir="$OAK/projects/biomarkers/snpnet/disease_outcome/${phenotype_name}"

############################################################
# Additional optional arguments for ${snpnet_wrapper} script
############################################################
covariates="age,sex,Array,PC1,PC2,PC3,PC4"
split_col="split"
status_col="CoxStatus"

############################################################
# Configure other parameters
############################################################
cores=$( cat $0 | egrep '^#SBATCH --cores='  | awk -v FS='=' '{print $NF}' )
mem=$(   cat $0 | egrep '^#SBATCH --mem='    | awk -v FS='=' '{print $NF}' )
#ml load snpnet_yt/0.3.3
ml load snpnet_yt/dev
# Two variables (${snpnet_dir} and ${snpnet_wrapper}) should be already configured by Sherlock module
# https://github.com/rivas-lab/sherlock-modules/tree/master/snpnet
# Or, you may use the latest versions
#  snpnet_dir="$OAK/users/$USER/repos/rivas-lab/snpnet"
#  snpnet_wrapper="$OAK/users/$USER/repos/rivas-lab/PRS/helper/snpnet_wrapper.sh"

############################################################
# Run ${snpnet_wrapper} script
############################################################

echo "[$0 $(date +%Y%m%d-%H%M%S)] [start] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID:=0}; phenotype = ${phenotype_name}" >&2

bash ${snpnet_wrapper} \
--snpnet_dir ${snpnet_dir} \
--nCores ${cores} --memory ${mem} \
--covariates ${covariates} \
--split_col ${split_col} \
--status_col ${status_col} \
--verbose \
--save_computeProduct \
--glmnetPlus \
${genotype_pfile} \
${phe_file} \
${phenotype_name} \
${family} \
${results_dir}

# --no_save

echo "[$0 $(date +%Y%m%d-%H%M%S)] [end] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID:=0}; phenotype = ${phenotype_name}" >&2

############################################################
# Another example (w/ the sample data in snpnet package)
############################################################
#genotype_pfile="$OAK/users/$USER/repos/rivas-lab/snpnet/inst/extdata/sample"
#phe_file="$OAK/users/$USER/repos/rivas-lab/snpnet/inst/extdata/sample.phe"
#phenotype_name="QPHE"
#family="gaussian"
#results_dir="$OAK/users/$USER/repos/rivas-lab/PRS/notebook/20191021_snpnet/private_out/20/${phenotype_name}"
#results_dir="/scratch/users/ytanigaw/snpnet.demo/${phenotype_name}"


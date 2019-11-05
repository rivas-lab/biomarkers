#!/bin/bash
#SBATCH --job-name=snpnet2
#SBATCH --output=logs/snpnet.%A.out
#SBATCH  --error=logs/snpnet.%A.err
#SBATCH --nodes=1
#SBATCH --cores=4
#SBATCH --mem=64000
#SBATCH --time=7-00:00:00
#SBATCH -p mrivas
set -beEuo pipefail

ml load snpnet anaconda/Anaconda3-5.3.0-Linux-x86_64_20181113 zstd
wrapper="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/PRS/helper/snpnet_wrapper.v2.1.sh"

cores=$( cat $0 | egrep '^#SBATCH --cores='  | awk -v FS='=' '{print $NF}' )
mem=$(   cat $0 | egrep '^#SBATCH --mem='    | awk -v FS='=' '{print $NF}' )

# snpnet_dir="/oak/stanford/groups/mrivas/software/snpnet"
snpnet_dir="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/snpnet"

genotype_pfile="/scratch/users/ytanigaw/tmp/snpnet/geno/array_combined/ukb24983_cal_hla_cnv"
phe_file="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/biomarkers/snpnet/disease_outcome_223k_v2/phe/phe.tsv"

phenotype_name=$1
covariates="age,sex,Array,PC1,PC2,PC3,PC4"
#covariates="None"
split_col="split"

family="binomial"
out_dir_root="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/biomarkers/snpnet/disease_outcome_223k_v2/out"

echo "[$0 $(date +%Y%m%d-%H%M%S)] [start] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID:=0}; phenotype = ${phenotype_name}" >&2
bash ${wrapper} \
${snpnet_dir} ${genotype_pfile} ${phe_file} \
${phenotype_name} ${covariates} ${split_col} \
${family} ${out_dir_root} ${cores} ${mem}
echo "[$0 $(date +%Y%m%d-%H%M%S)] [end] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID:=0}; phenotype = ${phenotype_name}" >&2


#!/bin/bash
#SBATCH --job-name=snpnet_outcome
#SBATCH --output=logs/snpnet.%A.out
#SBATCH  --error=logs/snpnet.%A.err
#SBATCH --nodes=1
#SBATCH --cores=8
#SBATCH --mem=150000
#SBATCH --time=2-00:00:00
#SBATCH -p mrivas,normal
set -beEuo pipefail

cores=$( cat $0 | egrep '^#SBATCH --cores='  | awk -v FS='=' '{print $NF}' )
mem=$(   cat $0 | egrep '^#SBATCH --mem='    | awk -v FS='=' '{print $NF}' )

phenotype_name="INI22402"
snpnet_dir="/oak/stanford/groups/mrivas/software/snpnet"
wrapper="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/PRS/helper/snpnet_wrapper.sh"
family="gaussian"

geno_dir="/scratch/users/ytanigaw/tmp/snpnet/geno/array_combined"
out_dir_root="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/biomarkers/snpnet/disease_outcome/out"
phe_file="/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/biomarkers/snpnet/disease_outcome/phe/phe.tsv"
covariates="age,sex,Array,PC1,PC2,PC3,PC4"

echo "[$0 $(date +%Y%m%d-%H%M%S)] [start] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID:=0}; phenotype = ${phenotype_name}" >&2
bash ${wrapper} ${snpnet_dir} ${phenotype_name} ${family} ${geno_dir} ${out_dir_root} ${phe_file} ${covariates} ${cores} ${mem}
echo "[$0 $(date +%Y%m%d-%H%M%S)] [end] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID:=0}; phenotype = ${phenotype_name}" >&2


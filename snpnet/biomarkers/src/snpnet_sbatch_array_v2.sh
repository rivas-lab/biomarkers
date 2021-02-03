#!/bin/bash
#SBATCH --job-name=snpnet
#SBATCH --output=logs_v2/snpnet.%A.out
#SBATCH  --error=logs_v2/snpnet.%A.err
#SBATCH --nodes=1
#SBATCH --cores=8
#SBATCH --mem=150000
#SBATCH --time=2-00:00:00
#SBATCH -p mrivas
set -beEuo pipefail

cores=$( cat $0 | egrep '^#SBATCH --cores='  | awk -v FS='=' '{print $NF}' )
mem=$(   cat $0 | egrep '^#SBATCH --mem='    | awk -v FS='=' '{print $NF}' )

phenotype_name=$1
snpnet_dir="@@@@@@/software/snpnet"
family="gaussian"
geno_dir="/scratch/users/ytanigaw/tmp/snpnet/geno/array_combined"
data_dir_root="@@@@@@/users/ytanigaw/repos/rivas-lab/public-resources/uk_biobank/biomarkers/snpnet/data"
phe_file="${data_dir_root}/biomarkers_covar.phe"
covariates="None"

src="@@@@@@/users/ytanigaw/repos/rivas-lab/PRS/helper/snpnet_wrapper.sh"

echo "[$0 $(date +%Y%m%d-%H%M%S)] [start] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID:=0}; phenotype = ${phenotype_name}" >&2
bash ${src} ${snpnet_dir} ${phenotype_name} ${family} ${geno_dir} ${data_dir_root} ${phe_file} ${covariates} ${cores} ${mem}
echo "[$0 $(date +%Y%m%d-%H%M%S)] [end] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID:=0}; phenotype = ${phenotype_name}" >&2


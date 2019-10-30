#!/bin/bash
#SBATCH --job-name=imp_check
#SBATCH --output=logs/imp_check.%A_%a.out
#SBATCH  --error=logs/imp_check.%A_%a.err
#SBATCH --nodes=1
#SBATCH --cores=4
#SBATCH --mem=32000
#SBATCH --time=1:00:00
#SBATCH -p normal,owners

set -beEuo pipefail

ml load snpnet anaconda/Anaconda3-5.3.0-Linux-x86_64_20181113 zstd gdrive

_SLURM_JOBID=${SLURM_JOBID:=0} # use 0 for default value (for debugging purpose)
_SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID:=1}

fetch_from_file () {
    local file=$1
    local line=$2
    local col=$3
    local offset=1
    cat $file | awk -v line=$line -v col=$col -v offset=$offset -v FS='\t' '(NR==line + offset){print $col}'
}

job_file="imp-jobs.tsv"
phe=$( fetch_from_file ${job_file} ${_SLURM_ARRAY_TASK_ID} 1)
meta=$(fetch_from_file ${job_file} ${_SLURM_ARRAY_TASK_ID} 2)
gwas=$(fetch_from_file ${job_file} ${_SLURM_ARRAY_TASK_ID} 3)

echo "[$0 $(date +%Y%m%d-%H%M%S)] [array-start] hostname = $(hostname) SLURM_JOBID = ${_SLURM_JOBID}; SLURM_ARRAY_TASK_ID = ${_SLURM_ARRAY_TASK_ID}; phe = $phe" >&2
bash meta_imp_flip_check.sh $meta $gwas
echo "[$0 $(date +%Y%m%d-%H%M%S)] [array-end] hostname = $(hostname) SLURM_JOBID = ${_SLURM_JOBID}; SLURM_ARRAY_TASK_ID = ${_SLURM_ARRAY_TASK_ID}; phe = $phe" >&2


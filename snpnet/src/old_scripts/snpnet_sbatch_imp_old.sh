#!/bin/bash
#SBATCH --job-name=snpnet
#SBATCH --output=logs/snpnet.%A.out
#SBATCH  --error=logs/snpnet.%A.err
#SBATCH --nodes=1
#SBATCH --cores=10
#SBATCH --mem=200000
#SBATCH --time=2-00:00:00
#SBATCH -p mrivas
set -beEuo pipefail

cores=$( cat $0 | egrep '^#SBATCH --cores='  | awk -v FS='=' '{print $NF}' )
mem=$(   cat $0 | egrep '^#SBATCH --mem='    | awk -v FS='=' '{print $NF}' )

phenotype_name=$1
family=$2

geno_dir="/oak/stanford/groups/mrivas/ukbb24983/sqc/population_stratification/split"

bash snpnet_wrapper.sh ${phenotype_name} ${family} ${geno_dir} ${cores} ${mem}

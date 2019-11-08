#!/bin/bash
set -beEuo pipefail

copy_geno_to_tmp () {
    local geno_dir=$1
    local tmp_geno_dir=$2
    
    if [ ! -d ${tmp_geno_dir} ] ; then mkdir -p ${tmp_geno_dir} ; fi
    for s in train val ; do for ext in bim fam bed ; do 
        if [ ! -f ${tmp_geno_dir}/${s}.${ext} ] ; then
            cp ${geno_dir}/${s}.${ext} ${tmp_geno_dir}/ 
        fi
    done ; done
}

phenotype_name=$1
family=$2
geno_dir=$3
data_dir_root=$4
phe_file=$5
cores=$6
mem=$7

# copy the genotype data to SCRATCH
#tmp_geno_dir=${tmp_dir}/snpnet-geno
#copy_geno_to_tmp ${geno_dir} ${tmp_geno_dir}

tmp_geno_dir="${geno_dir}"

tmp_dir_root="$LOCAL_SCRATCH"
if [ ! -d ${tmp_dir_root} ] ; then mkdir -p $tmp_dir_root ; fi
tmp_dir="$(mktemp -p ${tmp_dir_root} -d tmp-$(basename $0)-$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX)"
echo "tmp_dir = $tmp_dir" >&2
handler_exit () { rm -rf $tmp_dir ; }
trap handler_exit EXIT

config_file=${tmp_dir}/config.tsv

# configure and run
{
echo "#key val"
echo "snpnet_dir /oak/stanford/groups/mrivas/software/snpnet"
echo "mem2bufferSizeDivisionFactor 4"
echo "cpu ${cores}"
echo "mem ${mem}"
echo "niter 100"
echo "genotype_dir ${tmp_geno_dir}"
echo "data_dir_root ${data_dir_root}"
echo "phenotype_file ${phe_file}"
echo "phenotype_name ${phenotype_name}"
echo "family ${family}"
#echo "covariates age,sex,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10"
echo "prevIter 0"
} | tr " " "\t" > ${config_file}

echo "===================config_file===================" >&2
cat ${config_file} >&2
echo "===================config_file===================" >&2

Rscript snpnet_wrapper.R ${config_file}


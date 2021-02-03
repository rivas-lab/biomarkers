#!/bin/bash
set -beEuo pipefail

pheno_name=$1

Rscript "$(dirname $(readlink -f $0))/meta_flip_fix_check.R" $pheno_name

gdrive upload -p 1F04CAFP49GyqRtynPO6IgMi9kOGjGYuJ \
@@@@@@/projects/biomarkers_rivas/meta_flipfixed/METAANALYSIS_${pheno_name}_1.check.png

#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})
PROGNAME=$(basename $SRCNAME)
VERSION="0.0.1"

region_index=$(readlink -f 'FINEMAP.index.tsv')
tar_out_d="/oak/stanford/groups/mrivas/projects/biomarkers/fine_mapping/figshare_submission"

cat ${region_index} | awk '(NR>1){print $1}' | sort -u \
| while read trait ; do

    tar_file=${tar_out_d}/${trait}.tar

    echo ${tar_file}

    python 3_upload_FINEMAP.py ${tar_file}
done


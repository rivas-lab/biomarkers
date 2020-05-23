#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})
PROGNAME=$(basename $SRCNAME)
VERSION="0.0.1"

basename_index=$(readlink -f 'traits.lst')
data_d="/oak/stanford/groups/mrivas/projects/biomarkers/revisions/tables/multiprs_summary"

cat ${basename_index} | while read basename ; do

    file=${data_d}/${basename}

    echo ${file}

    python upload_multi-prs.py ${file}
done

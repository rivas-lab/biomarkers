#!/bin/bash
set -beEuo pipefail

out_d=$1

comm -1 -3 \
    <(find ${out_d} -maxdepth  1 -mindepth 1 -type d | while read d ; do basename $d ; done | sort | grep -v ipynb_checkpoints) \
    <(cat ${out_d}/biomarkers.phe | head -n1  | tr "\t" "\n" | tail -n+3 | sort)


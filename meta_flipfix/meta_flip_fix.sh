#!/bin/bash
set -beEuo pipefail
#######################
meta_tbl_f=$1
meta_tbl_out_f=$2

pvar_f='/oak/stanford/groups/mrivas/ukbb24983/cal/pgen/ukb24983_cal_cALL_v2_hg19.pvar'

#######################
prog="$(readlink -f $0)"
r_src="$(dirname ${prog})/$(basename ${prog} .sh).R"

#######################
# create a temp directory
tmp_dir="$(mktemp -d -p $LOCAL_SCRATCH tmp-$(basename ${prog})-$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX)"
echo "tmp_dir = $tmp_dir" >&2
handler_exit () { rm -rf $tmp_dir ; }
trap handler_exit EXIT

#######################

flipfix () {
    local in_f=$1
    local tmp_dir=$2
    
    local tmp_f="${tmp_dir}/$(basename ${in_f})"
    
    Rscript $r_src $in_f $tmp_f $pvar_f >&2
    
    cat $tmp_f | awk '(NR==1){print "#" $0}'
    
    cat $tmp_f | awk 'NR>1' | sort -k1V,1 -k2n,2    
}

flipfix ${meta_tbl_f} ${tmp_dir} | bgzip -l 9 > ${meta_tbl_out_f%.gz}.gz
tabix -s1 -b2 -e2 ${meta_tbl_out_f%.gz}.gz

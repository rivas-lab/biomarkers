#!/bin/bash
set -beEuo pipefail

flist=$1
out_f=$2

# Create a temp directory
tmp_dir_root=/tmp/u/$USER
if [ ! -d ${tmp_dir_root} ] ; then mkdir -p $tmp_dir_root ; fi
tmp_dir="$(mktemp -p ${tmp_dir_root} -d tmp-$(basename $0)-$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX)"
echo "tmp_dir = $tmp_dir" >&2
handler_exit () { rm -rf $tmp_dir ; }
trap handler_exit EXIT

tmp_in=${tmp_dir}/in.txt
tmp_out=${tmp_dir}/out.txt

combine_two () {
    local f1=$1
    local f2=$2
    paste $f1 <(cut -f3 $f2)
}

f1=$(cat $flist | awk 'NR==1')
echo $1 >&2
cat $f1 > $tmp_out

cat $flist | awk 'NR>1' | while read f ; do
    echo $f >&2
    cp $tmp_out $tmp_in
    combine_two $tmp_in $f > $tmp_out
done

cat $tmp_out | sed -e "s/NA/-9/g" > ${out_f}

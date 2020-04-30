#!/bin/bash
set -beEuo pipefail
# change the font settings in the svg file

in_f=$1
out_f=$2

cat $in_f \
| sed -e 's/font-family="CMUBright-Roman"/font-family="Helvetica, Arial, sans-serif"/g' \
| sed -e 's/font-family="CMUSansSerif-DemiCondensed"/font-family="Helvetica, Arial, sans-serif" font-style="italic"/g' > $out_f

echo "Please run the following command with a computer with a proper font instllation"
echo "  inkscape --export-filename=${out_f%.svg}.pdf ${out_f}"

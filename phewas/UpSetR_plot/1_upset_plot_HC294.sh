#!/bin/bash
set -beEuo pipefail

GBE_ID='HC294'
cases="@@@@@/${GBE_ID}.phe"

data_d="@@@@@"
HC_idx_long_f="${data_d}/ukb37855_ukb40831_icd.annot.tsv.gz"
out_pdf="${GBE_ID}.pdf"

############################################################
# tmp dir
############################################################
tmp_dir_root="$LOCAL_SCRATCH"
if [ ! -d ${tmp_dir_root} ] ; then mkdir -p $tmp_dir_root ; fi
tmp_dir="$(mktemp -p ${tmp_dir_root} -d tmp-$(basename $0)-$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX)"
# echo "tmp_dir = $tmp_dir" >&2
handler_exit () { rm -rf $tmp_dir ; }
trap handler_exit EXIT
############################################################

if [ ! -d $(dirname ${out_pdf}) ] ; then mkdir -p $(dirname ${out_pdf}) ; fi

# extract the relevant info
in_tbl=${tmp_dir}/in_tbl.tsv
keep_f=${tmp_dir}/keep.phe
tabix -h ${HC_idx_long_f} ${GBE_ID} > ${in_tbl}
cat ${cases} | awk -v OFS='\t' '($3==2){print $1, $2}' > ${keep_f}

Rscript /dev/stdin ${in_tbl} ${keep_f} ${out_pdf} << EOF
suppressWarnings(suppressPackageStartupMessages({ library(tidyverse); library(data.table) }))
library(UpSetR)

args <- commandArgs(trailingOnly=TRUE)

in_tbl  <- args[1]
keep_f  <- args[2]
out_pdf <- args[3]

####################
# function
####################

upsetplot_wrapper <- function(upset_labels, HC_idx_long, text_scaling_factor=1){
    upset(
        fromList(as.list(setNames(
            upset_labels %>% lapply(function(l){
            # extract the list of individuals
                HC_idx_long %>%
                filter(upset_label == l) %>%
                pull(IID) %>% unique()
            }),
            upset_labels
        ))),
        order.by = "freq", show.numbers = "yes",
        nsets = 20, nintersects = 40,
        text.scale = text_scaling_factor * c(1.5, 1.2, 1.5, 1.2, 1, .6),
#         number.angles = 300,
#         point.size = 2, line.size = .5,
#         mb.ratio = c(0.6, 0.4),
        mainbar.y.label = "Number of case individuals",
        sets.x.label = "# cases per data source"
    )
}

####################
# main
####################

HC_idx_long <- fread(in_tbl) %>%
rename('GBE_ID'='#GBE_ID') %>%
select(-time, -array) %>%
mutate(
    upset_label = if_else(coding == 6, 'Self-reported', paste('ICD-10', val))
)

if(keep_f != 'none'){
# read a keep file and focus on the subset of specified individuals

    keep_f %>%
    fread(sep='\t', col.names=c('FID', 'IID'), colClasses = 'character') %>%
    pull(FID) -> keep_l

    HC_idx_long %>%
    filter(IID %in% keep_l) -> HC_idx_long

}

# enumerate the list of phenotype sources
HC_idx_long %>%
count(upset_label) %>%
arrange(-n) %>%
pull(upset_label) -> upset_labels

cairo_pdf(out_pdf, height = 6, width = 8, family = "Helvetica")
upsetplot_wrapper(upset_labels, HC_idx_long)
dev.off()
EOF

# convert pdf to png
inkscape --export-filename=${out_pdf%.pdf}.png ${out_pdf}

echo ${out_pdf}
echo ${out_pdf%.pdf}.png

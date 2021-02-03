#!/bin/bash
set -beEuo pipefail

phe_list_f='../phenotypes.txt'
master_phe_f='@@@@@@/ukbb24983/phenotypedata/master_phe/master.20190509.phe'
JI_f='JI.tsv'

ml load R/3.6 gcc

Rscript /dev/stdin ${phe_list_f} ${master_phe_f} ${JI_f} << EOF
suppressWarnings(suppressPackageStartupMessages({ library(tidyverse); library(data.table) }))

args <- commandArgs(trailingOnly=TRUE)

phe_list_f <- args[1]
master_phe_f <- args[2]
JI_f <- args[3]

compute_JI <- function(phe_df, p1, p2){
    phe_df %>%
    rename(!!'pheno1' := p1) %>%
    rename(!!'pheno2' := p2) %>%
    count(pheno1, pheno2) %>%
    bind_rows(
        data.frame(pheno1 = 2, pheno2 = 2, n = 0)
    ) -> cnt_df

    n_intersection <- cnt_df %>% filter(pheno1 == 2,  pheno2 == 2) %>% pull(n) %>% sum()
    n_union        <- cnt_df %>% filter(pheno1 == 2 | pheno2 == 2) %>% pull(n) %>% sum()

    n_intersection/n_union
}

phe_list_f %>% fread() %>% pull(GBE_ID) %>% unique() -> phe_list

master_phe_f %>% fread(select=c('FID', 'IID', phe_list)) -> phe_df


n_phes <- length(phe_list)

1:(n_phes-1) %>% lapply(function(i){
    (i+1):n_phes %>% lapply(function(j){
        data.frame(
            pheno1 = phe_list[i],
            pheno2 = phe_list[j],
            JI     = phe_df %>% compute_JI(phe_list[i], phe_list[j]),
            stringsAsFactors = F
        )
    }) %>% bind_rows()
}) %>% bind_rows() -> JI_df


JI_df %>%
rename('#pheno1' = 'pheno1') %>%
fwrite(JI_f, sep='\t', na = "NA", quote=F)

EOF


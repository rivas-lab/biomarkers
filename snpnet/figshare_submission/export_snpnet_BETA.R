suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

# input
phe_info_f <- file.path('..', '..', 'common', 'biomarker.phenotype.info.tsv')
rdata_out_root <- '/oak/stanford/groups/mrivas/projects/biomarkers/snpnet/biomarkers'
pvar <- '/oak/stanford/groups/mrivas/ukbb24983/array_combined/pgen/ukb24983_cal_hla_cnv.pvar.zst'
covariates <- NULL

# output
out_f <- 'snpnet.BETAs.%s'

# functions
source('/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/snpnet/helpers/snpnet_misc.R')
# you can see this script on GitHub
# https://github.com/rivas-lab/snpnet/blob/master/helpers/snpnet_misc.R

find_latest_rdata <- function(rdata_dir){
    iter_range <- Sys.glob(file.path(rdata_dir, "*.RData")) %>%
    lapply(function(f){as.numeric(str_replace_all(basename(f), '^output_iter_|.RData$', ''))}) %>%
    range()
    file.path(rdata_dir, sprintf('output_iter_%d.RData', iter_range[2]))
}

# main
phe_info_df <- fread(phe_info_f) %>% rename('Phenotype'='name')

for(trait in phe_info_df %>% pull(annotation)){
    message(trait)
    
    load(find_latest_rdata(file.path(rdata_out_root, trait, 'results', 'results')))
    
    snpnet_fit_to_df(beta, which.max(metric.val), covariates, F) %>%
    save_BETA(sprintf(out_f, trait), pvar)
    
    rm(beta)
    rm(metric.val)
}

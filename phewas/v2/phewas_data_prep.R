suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(data.table))
library(googlesheets)
gs_auth(token = "/home/users/ytanigaw/.googlesheets_token.rds")

# configure params

p_thr <- 1e-7
phewas_phes_file <- '../../common/phenotypes.txt'
hits_array_file <- '@@@@@@/projects/biomarkers/cascade/out_v3/cascade.array.hits.tsv.zst'
master_gwas_file <- '@@@@@@/ukbb24983/cal/gwas/freeze/20190516/white_british/ukb24983_v2_hg19.genotyped.glm.20190516.1e3.tsv.gz'
phewas_out <- '@@@@@@/projects/biomarkers/phewas/v2/array.hits.phewas.tsv'

# read the list of phenotypes
phewas_phes <- phewas_phes_file %>% fread()

# read Biomarker association "hits"
hits_array <- fread(
    cmd=paste0('zstdcat ', hits_array_file), sep='\t'
) %>%
filter(
    ld_indep, is_outside_of_MHC,
    Csq %in% c('protein-altering', 'protein-truncating')        
)

hits_array %>% select(ID) %>% unique() %>% nrow() %>% print()

# fetch GBE shortnames
file <- 'https://docs.google.com/spreadsheets/d/1gwzS0SVZBSKkkHgsoqB5vHo5JpUeYYz8PK2RWrHEq3A'
GBE_names_df <- file %>% gs_url() %>% gs_read(ws = 'GBE_names')

fread(cmd=paste0('zcat ', master_gwas_file), sep='\t') %>%
rename('CHROM' = '#CHROM') %>%
rename('OR' = 'BETA') %>%
filter(
    # we filter by association p-value, the GBE_ID of the disease outcome, 
    # and the list of variants for PheWAS
    as.numeric(P) < p_thr, 
    GBE_ID %in% (phewas_phes %>% select(GBE_ID) %>% pull()),
    Variant_ID %in% (hits_array %>% select(ID) %>% pull())
) %>%
left_join(
    GBE_names_df %>% select(GBE_ID, GBE_short_name), by='GBE_ID'
) %>%
left_join(
    hits_array %>% 
    select(ID, Csq, is_outside_of_MHC, ld_indep, is_rare, maf, Gene_symbol, Gene, HGVSp, Consequence) %>%
    rename(Variant_ID = ID) %>%
    unique(), 
    by='Variant_ID'
) %>%
fwrite(
    phewas_out, sep='\t'
)

system(paste('bgzip', '-l9', phewas_out, sep=' '), intern=F, wait=T)

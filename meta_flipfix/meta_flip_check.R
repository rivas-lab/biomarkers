fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressPackageStartupMessages(require(tidyverse))
suppressPackageStartupMessages(require(data.table))

##############

meta_tbl_f <- args[1]

pvar_f <- '/oak/stanford/groups/mrivas/ukbb24983/cal/pgen/ukb24983_cal_cALL_v2_hg19.pvar'

##############
pvar_df <- fread(pvar_f) %>% rename('CHROM' = '#CHROM')

meta_sumstats_df <- fread(meta_tbl_f)

joined_df <- pvar_df %>% rename('MarkerName' = 'ID') %>%
right_join(meta_sumstats_df, by='MarkerName') %>%
mutate(
    A1_is_ref = (toupper(Allele1) == toupper(REF)),    
    A1_is_alt = (toupper(Allele1) == toupper(ALT)),
    A2_is_ref = (toupper(Allele2) == toupper(REF)),    
    A2_is_alt = (toupper(Allele2) == toupper(ALT)),
    is_not_flipped = (A1_is_alt & A2_is_ref),
    is_flipped     = (A1_is_ref & A2_is_alt)
)

print('Count summary')

joined_df%>%
count(A1_is_alt, A2_is_ref, A1_is_ref, A2_is_alt) %>%
print()

# print('The first 5 examples of the flipped alleles with P < 5e-8')

# joined_df %>%
# filter(is_flipped | is_not_flipped) %>%
# select(-is_not_flipped, -A1_is_ref, -A1_is_alt, -A2_is_ref, -A2_is_alt) %>%
# rename('P' = 'P-value') %>%
# filter(is_flipped, P < 5e-8 ) %>%
# head(5) %>%
# print()

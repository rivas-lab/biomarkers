fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressPackageStartupMessages(require(tidyverse))
suppressPackageStartupMessages(require(data.table))

##############

meta_tbl_f <- args[1]
meta_tbl_out_f <- args[2]
pvar_f <- args[3]

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
) %>%
filter(is_flipped | is_not_flipped) %>%
select(-is_not_flipped, -A1_is_ref, -A1_is_alt, -A2_is_ref, -A2_is_alt) 

n_flips <- joined_df %>% select(is_flipped) %>% pull() %>% sum()
print(paste0('The number of allele flips: ', n_flips))


flip_fixed <- joined_df %>% 
mutate(
    Allele1_copy = Allele1,
    Allele1 = if_else(is_flipped, Allele2, Allele1),
    Allele2 = if_else(is_flipped, Allele1_copy, Allele2),
    Effect  = if_else(is_flipped, -1 * Effect, Effect),
    Direction = if_else(
        is_flipped, 
        str_replace_all(str_replace_all(str_replace_all(Direction, '-', 'm'), '\\+', '-'), 'm', '+'),
        Direction        
    )
) %>%
select(-Allele1_copy, -REF, -ALT, -is_flipped) %>%
rename('ALT' = 'Allele1', 'REF' = 'Allele2') 

flip_fixed %>% fwrite(meta_tbl_out_f, sep='\t')

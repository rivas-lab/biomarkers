fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressPackageStartupMessages(require(tidyverse))
suppressPackageStartupMessages(require(data.table))

############

meta_sumstats_f    <- args[1]
meta_flipfixed_f   <- args[2]
meta_flipfixed_img <- args[3]
gwas_f             <- args[4]
pvar_f             <- args[5]

##############

add_flip_annotation <- function(df, pvar_df){
    pvar_df %>% 
    rename('MarkerName' = 'ID') %>%
    right_join(df, by='MarkerName') %>%
    mutate(
        A1_is_ref = (toupper(REF) == toupper(pvar_REF)),    
        A1_is_alt = (toupper(REF) == toupper(pvar_ALT)),
        A2_is_ref = (toupper(ALT) == toupper(pvar_REF)),    
        A2_is_alt = (toupper(ALT) == toupper(pvar_ALT)),
        is_not_flipped = (A1_is_alt & A2_is_ref),
        is_flipped     = (A1_is_ref & A2_is_alt)
    )
}

flip_check_plot <- function(df, gwas_df, titlelab, xlab){
    df %>% 
    rename('P' = 'P-value') %>%
    filter(P < 5e-8) %>%
    select(MarkerName, Effect, is_flipped) %>% 
    inner_join(gwas_df %>% select(ID, BETA) %>% rename('MarkerName' = 'ID'), by='MarkerName') %>%
    drop_na() %>%
    ggplot(aes(x=Effect, y=BETA, color=is_flipped)) +
    geom_point(alpha=0.05) + 
    labs(
        title = titlelab,
        x = xlab,
        y = 'BETA from WB GWAS sumstats'
    )+
    guides(colour = guide_legend(override.aes = list(alpha = 1)))    
}


##############

pvar_df <- fread(cmd=paste0('zcat ', pvar_f)) %>% 
mutate(FASTA_ALT = if_else(toupper(REF) == toupper(FASTA_REF), ALT, REF)) %>%
select(-REF, -ALT) %>%
rename('pvar_REF' = 'FASTA_REF', 'pvar_ALT' = 'FASTA_ALT', 'CHROM' = '#CHROM')

#gwas_df <- fread(cmd=paste0('zcat ', gwas_f))

meta_sumstats_df  <- fread(cmd=paste0('zcat ', meta_sumstats_f))

meta_sumstats_joined_df <- meta_sumstats_df %>%
add_flip_annotation(pvar_df)

n_flips <- meta_sumstats_joined_df %>% select(is_flipped) %>% pull() %>% sum()
print(paste0('The number of allele flips: ', n_flips))


meta_flipfixed_df <- meta_sumstats_joined_df %>% 
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
select(-Allele1_copy, -pvar_REF, -pvar_ALT, -is_flipped)

meta_flipfixed_df %>% fwrite(meta_flipfixed_f, sep='\t')

# meta_sumstats_p <- meta_sumstats_joined_df %>%
# flip_check_plot(
#     gwas_df, 
#     titlelab = paste0('Comparison of Effect size before flipfix (', pheno_name, ')'), 
#     xlab = 'Effect col from meta-analysis'
# )

# meta_flipfixed_joined_p <- meta_flipfixed_df %>%
# add_flip_annotation(pvar_df) %>%
# flip_check_plot(
#     gwas_df, 
#     titlelab = paste0('Comparison of Effect size after flipfix (', pheno_name, ')'), 
#     xlab = 'Effect col from the flip-fixed meta-analysis results'
# )

# g <- arrangeGrob(meta_sumstats_p, meta_flipfixed_joined_p, nrow=1)
# ggsave(file=meta_flipfixed_img, width=12, height=6, g)

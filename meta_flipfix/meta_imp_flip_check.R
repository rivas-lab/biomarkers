fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressPackageStartupMessages(require(tidyverse))
suppressPackageStartupMessages(require(data.table))

##############
meta_sumstats_f <- args[1]
gwas_f          <- args[2]
meta_check_img  <- args[3]

# pvar_f          <- '@@@@@@/users/ytanigaw/repos/rivas-lab/public-resources/uk_biobank/biomarkers/meta_flipfix/imp_ref_alt_check/ukb_imp_v3.mac1.flipcheck.tsv.gz'
pvar_f          <- '/scratch/users/ytanigaw/ukb_imp_v3.mac1.flipcheck.tsv.gz'

# meta_sumstats_f    <- '@@@@@@/projects/biomarkers/meta/plink_imputed/filtered/GLOBAL_Alanine_aminotransferase.sumstats.tsv.gz '
# meta_flipfixed_f   <- '@@@@@@/projects/biomarkers/meta/plink_imputed/filtered_flipfixed/GLOBAL_Alanine_aminotransferase.sumstats.tsv'
# meta_flipfixed_img <- '@@@@@@/projects/biomarkers/meta/plink_imputed/filtered_flipfixed/GLOBAL_Alanine_aminotransferase.check.png'
# gwas_f             <- '@@@@@@/projects/biomarkers/sumstats_diverse/white_british/plink_imputed/filtered/INT_Alanine_aminotransferase_all.glm.linear.filtered.maf001.info03.tsv.gz'
# pvar_f             <- '@@@@@@/users/ytanigaw/repos/rivas-lab/public-resources/uk_biobank/biomarkers/meta_flipfix/imp_ref_alt_check/ukb_imp_v3.mac1.flipcheck.tsv.gz'

##############
add_flip_annotation <- function(df, pvar_df){
    pvar_df %>% 
    rename('MarkerName' = 'ID') %>%
    right_join(df, by='MarkerName') %>%
    mutate(
        REF_is_FASTA_REF = (toupper(REF) == FASTA_REF),    
        REF_is_FASTA_ALT = (toupper(REF) == FASTA_ALT),
        ALT_is_FASTA_REF = (toupper(ALT) == FASTA_REF),    
        ALT_is_FASTA_ALT = (toupper(ALT) == FASTA_ALT),
        is_not_flipped = (REF_is_FASTA_REF & ALT_is_FASTA_ALT),
        is_flipped     = (REF_is_FASTA_ALT & ALT_is_FASTA_REF)
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

read_ref_alt_def <- function(pvar_f){
    fread(cmd=paste0('zcat ', pvar_f)) %>% 
    mutate(FASTA_ALT = if_else(toupper(REF) == toupper(FASTA_REF), ALT, REF)) %>%
    select(-REF, -ALT) %>%
    mutate(FASTA_REF = toupper(FASTA_REF), FASTA_ALT = toupper(FASTA_ALT)) %>%
    rename('CHROM' = '#CHROM')
}

meta_imp_flipcheck <- function(meta_sumstats_f, meta_check_img, gwas_f, pvar_f){
    # read files
    pvar_df <- read_ref_alt_def(pvar_f)
    meta_sumstats_df  <- fread(cmd=paste0('zcat ', meta_sumstats_f))
    gwas_df <- fread(cmd=paste0('zcat ', gwas_f))
 
    # check flip
    joined_annotated_df <- meta_sumstats_df %>% add_flip_annotation(pvar_df)

    n_flips <- joined_annotated_df %>% select(is_flipped) %>% 
    drop_na() %>% pull() %>% sum()
    print(paste0('The number of allele flips: ', n_flips))
    
    # plot agains WB
    p <- joined_annotated_df %>% flip_check_plot(
        gwas_df, 
        titlelab = str_replace_all(
            basename(meta_sumstats_f), 
            '^GLOBAL_|.sumstats.tsv$', ''
        ), 
        xlab = 'Effect column from META file'
    )    
    ggsave(file=meta_check_img, width=6, height=6, p)
}

##############
meta_imp_flipcheck(meta_sumstats_f, meta_check_img, gwas_f, pvar_f)

require(tidyverse)
require(data.table)


read_annot_arr <- function(annot_arr_file = '@@@@@@/private_data/ukbb/variant_filtering/variant_filter_table.tsv.gz'){
    annot.arr <- fread(
        cmd=paste0('zcat ', annot_arr_file),
        sep='\t', data.table=FALSE
    ) %>% mutate(
        MAF=pmin(freq, 1-freq)
    ) %>%
    mutate(
        variant = paste(CHROM, POS, REF, ALT, sep=':')
    )
    
    annot.arr$Csq[
        !(annot.arr$Consequence %in% c("frameshift_variant","splice_donor_variant","stop_gained","stop_lost","start_lost","splice_acceptor_variant","splice_region_variant","missense_variant","inframe_insertion","inframe_deletion"))
    ] = "non-coding"
    annot.arr$Csq[
        annot.arr$Consequence %in% c("splice_region_variant","missense_variant","inframe_insertion","inframe_deletion")
    ] = "protein-altering"
    annot.arr$Csq[
        annot.arr$Consequence %in% c("frameshift_variant","splice_donor_variant","stop_gained","stop_lost","start_lost","splice_acceptor_variant")
    ] = "protein-truncating"
    
    annot.arr

}

get_filename <- function(trait_name, traits_df = traits, sumstats_dir = res_dir_array){
    filename <- traits_df %>% filter(trait == trait_name) %>% select(file) %>% pull()
    file.path(sumstats_dir, filename)
}


read_arr_sumstats <- function(trait, traits_df = traits, p_thr_list = p_thr, annot = annot.arr, sumstats_dir = res_dir_array){
    file_name <- get_filename(trait, traits_df, sumstats_dir)
    if(endsWith(file_name, 'glm.linear')){
        df <- fread(
            cmd=paste0('cat ', file_name, '| cut -f3,6,9,10,12'), 
            sep='\t', data.table=FALSE
        ) %>% mutate(phe_type='qt')
    }else if(endsWith(file_name, 'glm.logistic.hybrid')){
        df <- fread(
            cmd=paste0('cat ', file_name, '| cut -f3,6,10,11,13'), 
            sep='\t', data.table=FALSE
        ) %>% mutate(BETA = log(OR)) %>% mutate(phe_type='bin')
    }
    df %>%
    drop_na(BETA, SE, P) %>% 
    mutate(BETA = as.numeric(BETA), SE = as.numeric(SE), P = as.numeric(P)) %>% 
#     filter(P <= max(unlist(p_thr_list, use.names=FALSE))) %>% 
    filter(P <= 1e-4) %>%
    mutate(trait = trait) %>% left_join(annot, by='ID') %>% 
    select(
        trait, variant, CHROM, POS, ID, A1, BETA, SE, P, MAF, Csq, Consequence, HGVSp, Gene_symbol, Gene
    )
}


outlier_detection <- function(sumstats_df, sd_multiplier=3){
    pred.eff <- lm(abs(BETA) ~ log(MAF), sumstats_df)
    sumstats_df %>% mutate(
        residuals = residuals(pred.eff),
        abs_residuals = abs(residuals),
        outlier = if_else(
            (abs_residuals - mean(abs_residuals)) > sd_multiplier * sd(abs_residuals),
            TRUE, FALSE
        )
    ) %>% select(-abs_residuals, -residuals)
}

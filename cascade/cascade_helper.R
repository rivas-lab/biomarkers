suppressPackageStartupMessages(require(tidyverse))
suppressPackageStartupMessages(require(data.table))


######################
# Read variant annotation file
######################
read_annot_arr <- function(annot_arr_file = '/oak/stanford/groups/mrivas/private_data/ukbb/variant_filtering/variant_filter_table.tsv.gz'){
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


######################
# Read meta-analysis sumstats for the array
######################
read_array_sumstats <- function(file, pval_thr){
    df <- fread(
        cmd=paste0(
            'zcat ', file, ' | sed -e "s/^#//g"')
    ) %>%
    rename('P' = 'P-value') %>%
    mutate(P = as.numeric(P)) %>%
    filter(P <= pval_thr) %>%
    arrange(suppressWarnings(as.numeric(CHROM)), CHROM, POS)
}

read_imp_sumstats <- function(file, pval_thr){
    df <- fread(file) %>%
    select(-'P.value') %>%
#     rename('P' = 'P-value') %>%
    mutate(P = as.numeric(P)) %>%
    filter(P <= pval_thr) %>%
    arrange(suppressWarnings(as.numeric(CHROM)), CHROM, POS)
}

read_sumstats_all_generic <- function(traits, pval_thr, col, read_func){
    sumstats_files        <- traits %>% select(col)  %>% pull()
    names(sumstats_files) <- traits %>% select(name) %>% pull()

    df <- bind_rows(lapply(
        names(sumstats_files), 
        function(x){
            read_func(sumstats_files[[x]], pval_thr) %>% 
            mutate(name = x)
        }
    ))
}


read_array_sumstats_all <- function(traits, pval_thr){
    col = 'array'
    read_func = read_array_sumstats
    read_sumstats_all_generic(traits, pval_thr, col, read_func)
}

read_imp_sumstats_all <- function(traits, pval_thr){
    col = 'imp'
    read_func = read_imp_sumstats
    read_sumstats_all_generic(traits, pval_thr, col, read_func)
}

annotate_array_df <- function(array_df, annot.arr, p_thr_df){
    array_df %>%
    rename('ID' = 'MarkerName') %>%
    inner_join(
        annot.arr %>% 
        select(ID, maf, ld_indep, Gene_symbol, Gene, HGVSp, Csq, Consequence), 
        by='ID'
    ) %>%
    mutate(
        is_outside_of_MHC = (
            (suppressWarnings(as.numeric(CHROM)) != 6) | 
            (as.numeric(POS) < 25477797 | 36448354 < as.numeric(POS))
        ),
        is_rare = as.numeric(maf) < 0.01,
        is_autosome = (suppressWarnings(as.numeric(CHROM)) %in% 1:22)
    ) %>%
    left_join(
        p_thr_df, by='Csq'
    ) %>%
    filter(
        P <= p_thr
    )
}

annotate_imp_df <- function(array_df){
    array_df %>%
    rename('ID' = 'MarkerName', 'maf' = 'MAF') %>%
    mutate(
        is_outside_of_MHC = (
            (suppressWarnings(as.numeric(CHROM)) != 6) | 
            (as.numeric(POS) < 25477797 | 36448354 < as.numeric(POS))
        ),
        is_rare = as.numeric(maf) < 0.01,
        is_autosome = (suppressWarnings(as.numeric(CHROM)) %in% 1:22)
    )
}

######################
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

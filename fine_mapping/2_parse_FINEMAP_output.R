fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))
library(future.apply)

####################################################################
# input & output
####################################################################
# input
traits_f <- '../common/canonical_trait_names.txt'
finemap_out_dir <- '@@@@@@/users/christian'
filtered_regions <- '@@@@@@/users/ytanigaw/repos/rivas-lab/biomarkers/fine_mapping/filtration/filtered_regions.txt.gz'

# output
out_f <- 'FINEMAP_output.tsv'

####################################################################
# functions
####################################################################
get_config_file_name <- function(trait, chr, range, data_dir=finemap_out_dir){
    file.path(data_dir, sprintf('chr%s', chr), trait, range, sprintf('GLOBAL_%s_chr%s_%s.config.zst', trait, chr, range))
}

get_cred_file_name <- function(trait, chr, range, n_signals, data_dir=finemap_out_dir){
    file.path(data_dir, sprintf('chr%s', chr), trait, range, sprintf('GLOBAL_%s_chr%s_%s.cred%s.zst', trait, chr, range, n_signals))
}

####################################################################
# code
####################################################################

traits <- fread(traits_f) %>% pull(annotation)
traits_abb <- traits

regions_all <- fread(cmd=paste('zcat', filtered_regions)) %>%
rename('CHROM' = '#CHROM')

finemap_df <- traits %>%
lapply(function(trait){
    regions <- regions_all %>% 
    filter(TRAIT == trait) %>%
    select(TRAIT, CHROM, BEGIN, END)

    seq( nrow( regions ) ) %>%    
    future_lapply(function( ii )
    {
        chr   <- regions[[ 'CHROM' ]][ ii ]
        range <- sprintf('range%s-%s', regions[[ 'BEGIN' ]][ ii ], regions[[ 'END' ]][ ii ])
        print( sprintf( '%s-%d chr%s, %s', trait, ii, chr, range ) )

        ## FINEMAP
        filename <- get_config_file_name(trait, chr, range)

        if( !is.na( file.info( filename )$size ) && file.info( filename )$size > 13 )
            # empty zstd file have size of 13
        {
            ## Read config file
            tmp <- data.table::fread( cmd=paste( 'zstdcat', filename ) )

            ## Parse posterior probability of
            ## there being k causal SNPs in the
            ## region
            post_prob_k    <- sapply( unique( tmp$k ), function( k ) sum( tmp$prob[ tmp$k == k ] ) )
            post_prob_k    <- post_prob_k / sum( post_prob_k )
            n_signals      <- unique( tmp$k )[ which.max( post_prob_k ) ]
            n_signals_prob <- max( post_prob_k )

            ## Read credible set file
            cred <- data.table::fread(
                cmd=paste( 'zstdcat', get_cred_file_name(trait, chr, range, n_signals), ' | egrep -v "^#"'), 
                header = T
            )
            n_snps_per_signal <- 1:n_signals %>% lapply(
                function(iii) length( na.omit( cred[[ sprintf( 'cred%s', iii ) ]] ) )
            )

            data.frame(
                trait = trait,
                region_idx = ii,
                chr = sprintf( 'chr%s', chr ),
                range = range,
                n_signals = n_signals,
                n_signals_prob = max( post_prob_k ),
                n_snps_per_signal = paste( n_snps_per_signal, collapse = '|' ),
                stringsAsFactors = F
            )
        } else {
            data.frame(
                trait = trait,
                region_idx = ii,
                chr = sprintf( 'chr%s', chr ),
                range = range,
                n_signals = NA,
                n_signals_prob = NA,
                n_snps_per_signal = NA,
                stringsAsFactors = F
            )
        }
    }) %>% bind_rows()
}) %>% bind_rows()

finemap_df %>%
fwrite(out_f, sep='\t', na = "NA", quote=F)

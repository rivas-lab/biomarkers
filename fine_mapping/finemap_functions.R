suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

get_colors6 <- function(){
    ## Define six colors
    colors6 <- c(
        rgb( 107, 223, 72,  max = 255 ),
        rgb( 121, 213, 117, max = 255 ),
        rgb( 129, 214, 161, max = 255 ),
        rgb( 93,  217, 206, max = 255 ),
        rgb( 168, 226, 242, max = 255 ),
        rgb( 101, 193, 227, max = 255 )
    )    
}

get_n_regions <- function(res){ nrow( drop_na ( res ) ) }
get_n_signals <- function(res){ sum( as.numeric( drop_na( res )$n_signals ) ) }
get_n_signal_per_region <- function(res){
    cut(
        x      = as.numeric( drop_na( res )$n_signals ),
        breaks = c( 0, 1, 2, 3, 4, 5, Inf ),
        labels = c( '1', '2', '3', '4', '5', '6+' )
    )
}
get_n_snps_per_signal <- function(res){
    cut( 
        x      = unlist( sapply(
            drop_na( res )$n_snps_per_signal, 
            function( x ) as.numeric( strsplit( x, split = '\\|' )[[ 1 ]] ),
            USE.NAMES = F
        ) ),
        breaks = c( 0, 1, 5, 10, 20, 50, Inf ),
        labels = c( '1', '2-5', '6-10', '11-20', '21-50', '51+' )
    )
}
get_n_signal_per_region_max <- function(res){
    max(as.integer(unique(res$n_signals)), na.rm=T)
}

add_string <- function(str_list, prefix='', suffix='', idxs = NULL){
    if(is.null(idxs)){
        idxs <- c(length(str_list))
    }
    for(idx in idxs){
        str_list[idx] <- paste0(prefix, str_list[idx], suffix)            
    }

    str_list
}

get_summary_number_of_distinct_signals_per_region <- function(n_signal_per_region, n_signal_per_region_max, ntraits){
    sprintf(
        'Distinct association signals. A single signal at %d regions, and two to %d signals at %d regions across %d traits.',
        n_signal_per_region[1],
        max(unlist(n_signal_per_region_max)),
        sum(n_signal_per_region) - n_signal_per_region[1],
        ntraits
    ) %>% message()
    
    n_signal_per_region %>%
    as.data.frame(responseName = "n_regions") %>%
    rename('n_signals' = 'Var1') %>%
    as.matrix() %>%
    t()
    
}

get_summary_number_of_variants_in_credible_set <- function(n_snps_per_signal, ntraits){
    sprintf(
        'Number of variants in the credible set with >= 99%% posterior probability. In total of %d signals were mapped to a single variant in the credible set across %d traits.',
        n_snps_per_signal[1],
        ntraits
    ) %>% message()

    n_snps_per_signal %>%
    as.data.frame(responseName = "n_signals") %>%
    rename('n_variants' = 'Var1') %>%
    as.matrix() %>%
    t()
}

compute_finemap_sumstats <- function(trait, res_trait){
    finemap_sumstats <- c(
        trait, 
        get_n_regions( res_trait ),
        get_n_signals( res_trait ),
        table( get_n_signal_per_region( res_trait ) ),
        table( get_n_snps_per_signal( res_trait ) )
    )
    names(finemap_sumstats) <- c('trait', 'n_regions', 'n_signals', 'sr1', 'sr2', 'sr3', 'sr4', 'sr5', 'sr6+', 'ss1', 'ss2-5', 'ss6-10', 'ss11-20', 'ss21-50', 'ss51+' )

    finemap_sumstats
}

plot_FINEMAP_summary <- function(n_regions, n_signals, n_signal_per_region, n_snps_per_signal, colors, text=''){
    layout( matrix( 1 : 2 ), height = c( 0.5, 0.5 ) )

    ## Number of distinct signals per region
    # par( mar = c( 2, 0.25, 0.25, 0.25 ) )
    par( mar = c( 1, .5, 0.25, 0.5 ) )
    plot(
        x    = 0,
        y    = 0,
        type = 'n',
        xlim = c( 0, 1 ),
    # 	ylim = c( -0.1, 1.25 ),
        ylim = c( -0.1, 1.5 ),
        xaxs = 'i',
        yaxs = 'i',
        xaxt = 'n',
        yaxt = 'n',
        xlab = '',
        ylab = '',
        bty  = 'n'
    )
    start_end_rect <- cbind(
        c( 0, cumsum( n_signal_per_region / n_regions )[ -length( n_signal_per_region ) ] ),
        cumsum( n_signal_per_region / n_regions )
    )
    axis( 1, tick = F, line = -6.3, at = rowMeans( start_end_rect ), labels = add_string( names( n_signal_per_region ), '', '  signals each', c(3,4,5,6) ) ) 
    rect( start_end_rect[, 1 ], 0, start_end_rect[, 2 ], 1, col = colors, border = 'white' )
    text( rowMeans( start_end_rect ), rep( 0.5, nrow( start_end_rect ) ), labels = add_string( n_signal_per_region, 'in ', ' regions', c(3,4,5,6) ) )
    lines( c( 0, 1 ), rep( -0.05, 2 ) )
    lines( rep( 0, 2 ), c( -0.08, -0.02 ) )
    lines( rep( 1, 2 ), c( -0.08, -0.02 ) )
    legend_str <- sprintf( '%s distinct signals identified in %s regions', n_signals, n_regions )
    rect( 0.5 - 0.6 * strwidth( legend_str ), -0.1, 0.5 + 0.6 * strwidth( legend_str ), 0, col = 'white', border = 'white' )
    text( 0.5, -0.1, labels = legend_str, xpd = T )
    text( 0, 1.375, labels = sprintf( '%sNumber of distinct signals per region', text ), pos = 4, font = 2, offset = 0 )

    ## Number of variants in the credible set with >= 99%% posterior probability
    # par( mar = c( 2, 0.25, 0.25, 0.25 ) )
    par( mar = c( 1, .5, 0.25, 0.5 ) )
    plot(
        x    = 0,
        y    = 0,
        type = 'n',
        xlim = c( 0, 1 ),
        ylim = c( -0.1, 1.5 ),
        xaxs = 'i',
        yaxs = 'i',
        xaxt = 'n',
        yaxt = 'n',
        xlab = '',
        ylab = '',
        bty  = 'n'
    )
    start_end_rect <- cbind(
        c( 0, cumsum( n_snps_per_signal / n_signals )[ -length( n_snps_per_signal ) ] ),
        cumsum( n_snps_per_signal / n_signals )
    )
    axis( 1, tick = F, line = -6.3, at = rowMeans( start_end_rect ), labels = add_string( names( n_snps_per_signal ), '', ' variants each', c(5,6) ) )
    rect( start_end_rect[, 1 ], 0, start_end_rect[, 2 ], 1, col = colors, border = 'white' )
    text( rowMeans( start_end_rect ), rep( 0.5, nrow( start_end_rect ) ), labels = add_string( n_snps_per_signal, 'in ', ' signals', c(5,6) ) )
    lines( c( 0, start_end_rect[ nrow( start_end_rect ) - 1, 2 ] ), rep( -0.05, 2 ) )
    lines( rep( 0, 2 ), c( -0.08, -0.02 ) )
    lines( rep( start_end_rect[ nrow( start_end_rect ) - 1, 2 ], 2 ), c( -0.08, -0.02 ) )
    legend_str <- sprintf( '%s signals fine-mapped to < 51 variants', sum( n_snps_per_signal[ -length( n_snps_per_signal ) ] ) )
    mid_pos_legend <- mean( c( 0, start_end_rect[ nrow( start_end_rect ) - 1, 2 ] ) )
    rect( mid_pos_legend - 0.6 * strwidth( legend_str ), -0.1, mid_pos_legend + 0.6 * strwidth( legend_str ), 0, col = 'white', border = 'white' )
    text( mid_pos_legend, -0.1, labels = legend_str, xpd = T )
    text( 0, 1.375, labels = sprintf('%sNumber of variants in each signal', text ), pos = 4, font = 2, offset = 0 )
}

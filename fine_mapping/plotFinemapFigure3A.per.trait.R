fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(data.table))

####################################################################

trait <- args[1]

# res <- readRDS( '/oak/stanford/groups/mrivas/users/christian/finemap_results_figure3.rds' )
res <- readRDS( 'finemap_results_figure3.rds' )

####################################################################


## Define six colors
colors6 <- c(
	rgb( 107, 223, 72,  max = 255 ),
	rgb( 121, 213, 117, max = 255 ),
	rgb( 129, 214, 161, max = 255 ),
	rgb( 93,  217, 206, max = 255 ),
	rgb( 168, 226, 242, max = 255 ),
	rgb( 101, 193, 227, max = 255 )
)


cascade_files <- file.path('../cascade', 'cascade.input.files.tsv')
traits <- fread(cascade_files)

plot_names <- setNames(traits %>% select(name) %>% pull(), traits %>% select(annotation) %>% pull())


## Plot figure 3

n_regions           <- nrow( drop_na ( res[[trait]] ) )
n_signals           <- sum( as.numeric( drop_na( res[[trait]] )$n_signals ) ) 
n_signal_per_region <- table(
    	    cut(
	    	    x      = as.numeric( drop_na( res[[trait]] )$n_signals ),
    		    breaks = c( 0, 1, 2, 3, 4, 5, Inf ),
        		labels = c( '1', '2', '3', '4', '5', '6+' )
	        )
    )
n_snps_per_signal   <- table(
	        cut( 
		        x      = unlist( sapply( drop_na( res[[trait]] )$n_snps_per_signal, function( x ) as.numeric( strsplit( x, split = '\\|' )[[ 1 ]] ), USE.NAMES = F ) ),
    		    breaks = c( 0, 1, 5, 10, 20, 50, Inf ),
    	    	labels = c( '1', '2-5', '6-10', '11-20', '21-50', '51+' )
	        )
)

add_string <- function(str_list, prefix='', suffix='', idxs = NULL){
    if(is.null(idxs)){
        idxs <- c(length(str_list))
    }
    for(idx in idxs){
        str_list[idx] <- paste0(prefix, str_list[idx], suffix)            
    }

    str_list
}

# pdf(file.path('figs', paste0('fig3A.', trait, '.pdf')), width = 12, height = 3)
png(file.path('figs', paste0('fig3A.', trait, '.png')), width = 1200, height = 300)

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
axis( 1, tick = F, line = -8.5, at = rowMeans( start_end_rect ), labels = add_string( names( n_signal_per_region ), '', '  signals each', c(3,4,5,6) ) ) 
                
# axis( 1, tick = F, line = -6.3, at = rowMeans( start_end_rect ), labels = add_string( names( n_signal_per_region ), '', '  signals each', c(3,4,5,6) ) ) 
rect( start_end_rect[, 1 ], 0, start_end_rect[, 2 ], 1, col = colors6, border = 'white' )
text( rowMeans( start_end_rect ), rep( 0.5, nrow( start_end_rect ) ), labels = add_string( n_signal_per_region, 'in ', ' regions', c(3,4,5,6) ) )
lines( c( 0, 1 ), rep( -0.05, 2 ) )
lines( rep( 0, 2 ), c( -0.08, -0.02 ) )
lines( rep( 1, 2 ), c( -0.08, -0.02 ) )
legend_str <- sprintf( '%s distinct signals identified in %s regions', n_signals, n_regions )
rect( 0.5 - 0.6 * strwidth( legend_str ), -0.1, 0.5 + 0.6 * strwidth( legend_str ), 0, col = 'white', border = 'white' )
text( 0.5, -0.1, labels = legend_str, xpd = T )
text( 0, 1.375, labels = 'Number of distinct signals per region', pos = 4, font = 2, offset = 0 )

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
axis( 1, tick = F, line = -8.5, at = rowMeans( start_end_rect ), labels = add_string( names( n_snps_per_signal ), '', ' variants each', c(5,6) ) )
rect( start_end_rect[, 1 ], 0, start_end_rect[, 2 ], 1, col = colors6, border = 'white' )
text( rowMeans( start_end_rect ), rep( 0.5, nrow( start_end_rect ) ), labels = add_string( n_snps_per_signal, 'in ', ' signals', c(5,6) ) )
lines( c( 0, start_end_rect[ nrow( start_end_rect ) - 1, 2 ] ), rep( -0.05, 2 ) )
lines( rep( 0, 2 ), c( -0.08, -0.02 ) )
lines( rep( start_end_rect[ nrow( start_end_rect ) - 1, 2 ], 2 ), c( -0.08, -0.02 ) )
legend_str <- sprintf( '%s signals fine-mapped to < 51 variants', sum( n_snps_per_signal[ -length( n_snps_per_signal ) ] ) )
mid_pos_legend <- mean( c( 0, start_end_rect[ nrow( start_end_rect ) - 1, 2 ] ) )
rect( mid_pos_legend - 0.6 * strwidth( legend_str ), -0.1, mid_pos_legend + 0.6 * strwidth( legend_str ), 0, col = 'white', border = 'white' )
text( mid_pos_legend, -0.1, labels = legend_str, xpd = T )
text( 0, 1.375, labels = 'Number of variants in each signal', pos = 4, font = 2, offset = 0 )

dev.off()

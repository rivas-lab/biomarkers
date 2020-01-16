fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(data.table))

####################################################################

trait <- args[1]

res <- readRDS( '/oak/stanford/groups/mrivas/users/christian/finemap_results_figure3.rds' )

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

n_regions           <- nrow( res[[trait]] )
n_signals           <- sum( as.numeric( res[[trait]]$n_signals ) ) 
n_signal_per_region <- table(
    	    cut(
	    	    x      = as.numeric( res[[trait]]$n_signals ),
    		    breaks = c( 0, 1, 2, 3, 4, 5, Inf ),
        		labels = c( '1', '2', '3', '4', '5', '6+' )
	        )
    )
n_snps_per_signal   <- table(
	        cut( 
		        x      = unlist( sapply( res[[trait]]$n_snps_per_signal, function( x ) as.numeric( strsplit( x, split = '\\|' )[[ 1 ]] ), USE.NAMES = F ) ),
    		    breaks = c( 0, 1, 5, 10, 20, 50, Inf ),
    	    	labels = c( '1', '2-5', '6-10', '11-20', '21-50', '51+' )
	        )
)
                
png(file.path('figs', paste0('fig3.', trait, '.png')), width = 1080, height = 300)

layout( matrix( 1 : 2 ), height = c( 0.5, 0.5 ) )

## Figure 3a
par( mar = c( 2, 0.25, 0.25, 0.25 ) )
plot(
	x    = 0,
	y    = 0,
	type = 'n',
	xlim = c( 0, 1 ),
	ylim = c( -0.1, 1.25 ),
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
axis( 1, tick = F, line = -0.75, at = rowMeans( start_end_rect ), labels = names( n_signal_per_region ) )
rect( start_end_rect[, 1 ], 0, start_end_rect[, 2 ], 1, col = colors6, border = 'white' )
text( rowMeans( start_end_rect ), rep( 0.5, nrow( start_end_rect ) ), labels = n_signal_per_region )
lines( c( 0, 1 ), rep( -0.05, 2 ) )
lines( rep( 0, 2 ), c( -0.08, -0.02 ) )
lines( rep( 1, 2 ), c( -0.08, -0.02 ) )
legend_str <- sprintf( '%s distinct signals identified in %s regions for %s', n_signals, n_regions, plot_names[[trait]] )
rect( 0.5 - 0.6 * strwidth( legend_str ), -0.1, 0.5 + 0.6 * strwidth( legend_str ), 0, col = 'white', border = 'white' )
text( 0.5, -0.07, labels = legend_str, xpd = T )
text( 0, 1.125, labels = sprintf('%s  Number of signals/regions:', plot_names[[trait]]), pos = 4, font = 2 )

## Figure 3b
par( mar = c( 2, 0.25, 0.25, 0.25 ) )
plot(
	x    = 0,
	y    = 0,
	type = 'n',
	xlim = c( 0, 1 ),
	ylim = c( -0.1, 1.25 ),
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
axis( 1, tick = F, line = -0.75, at = rowMeans( start_end_rect ), labels = names( n_snps_per_signal ) )
rect( start_end_rect[, 1 ], 0, start_end_rect[, 2 ], 1, col = colors6, border = 'white' )
text( rowMeans( start_end_rect ), rep( 0.5, nrow( start_end_rect ) ), labels = n_snps_per_signal )
lines( c( 0, start_end_rect[ nrow( start_end_rect ) - 1, 2 ] ), rep( -0.05, 2 ) )
lines( rep( 0, 2 ), c( -0.08, -0.02 ) )
lines( rep( start_end_rect[ nrow( start_end_rect ) - 1, 2 ], 2 ), c( -0.08, -0.02 ) )
legend_str <- sprintf( '%s signals fine-mapped to < 51 variants for %s', sum( n_snps_per_signal[ -length( n_snps_per_signal ) ] ), plot_names[[trait]] )
mid_pos_legend <- mean( c( 0, start_end_rect[ nrow( start_end_rect ) - 1, 2 ] ) )
rect( mid_pos_legend - 0.6 * strwidth( legend_str ), -0.1, mid_pos_legend + 0.6 * strwidth( legend_str ), 0, col = 'white', border = 'white' )
text( mid_pos_legend, -0.07, labels = legend_str, xpd = T )
text( 0, 1.125, labels = sprintf('%s  Number of variants in each signal:', plot_names[[trait]] ), pos = 4, font = 2 )


dev.off()
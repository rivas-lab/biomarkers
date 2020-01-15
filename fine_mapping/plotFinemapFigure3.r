##---------------##
##               ##
## Plot results  ##
##               ##
##---------------##

res <- readRDS( '/Users/benner/Documents/OneDrive - University of Helsinki/Manuscripts/Lipids/finemap_results_figure3.rds' )

## Define six colors
colors6 <- c(
	rgb( 107, 223, 72,  max = 255 ),
	rgb( 121, 213, 117, max = 255 ),
	rgb( 129, 214, 161, max = 255 ),
	rgb( 93,  217, 206, max = 255 ),
	rgb( 168, 226, 242, max = 255 ),
	rgb( 101, 193, 227, max = 255 )
)

## Plot figure 3
n_regions           <- sum( sapply( res, nrow ) )
n_signals           <- sum( sapply( res, function( x ) sum( as.numeric( x$n_signals ) ) ) )
n_signal_per_region <- table(
    unlist( 
        lapply( res, function( x )
        {
    	    cut(
	    	    x      = as.numeric( x$n_signals ),
    		    breaks = c( 0, 1, 2, 3, 4, 5, Inf ),
        		labels = c( '1', '2', '3', '4', '5', '6+' )
	        )
        } )
    )
)
n_snps_per_signal   <- table(
	unlist( 
	    lapply( res, function( x )
    	{
	        cut( 
		        x      = unlist( sapply( x$n_snps_per_signal, function( x ) as.numeric( strsplit( x, split = '\\|' )[[ 1 ]] ), USE.NAMES = F ) ),
    		    breaks = c( 0, 1, 5, 10, 20, 50, Inf ),
    	    	labels = c( '1', '2-5', '6-10', '11-20', '21-50', '51+' )
	        )
	    } )
	)
)

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
legend_str <- sprintf( '%s distinct signals identified in %s regions', n_signals, n_regions )
rect( 0.5 - 0.6 * strwidth( legend_str ), -0.1, 0.5 + 0.6 * strwidth( legend_str ), 0, col = 'white', border = 'white' )
text( 0.5, -0.07, labels = legend_str, xpd = T )
text( 0, 1.125, labels = 'Number of signals/regions:', pos = 4, font = 2 )

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
legend_str <- sprintf( '%s signals fine-mapped to < 51 variants', sum( n_snps_per_signal[ -length( n_snps_per_signal ) ] ) )
mid_pos_legend <- mean( c( 0, start_end_rect[ nrow( start_end_rect ) - 1, 2 ] ) )
rect( mid_pos_legend - 0.6 * strwidth( legend_str ), -0.1, mid_pos_legend + 0.6 * strwidth( legend_str ), 0, col = 'white', border = 'white' )
text( mid_pos_legend, -0.07, labels = legend_str, xpd = T )
text( 0, 1.125, labels = 'Number of variants in each signal:', pos = 4, font = 2 )
##---------------##
##               ##
## Parse results ##
##               ##
##---------------##

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(data.table))

## Biomarkers
# traits     <- c( 'Alanine_aminotransferase', 'Calcium', 'Direct_bilirubin', 'IGF_1', 'Phosphate', 'Total_protein', 'Albumin', 'Cholesterol', 'eGFR', 'LDL_direct', 'Potassium_in_urine', 'Triglycerides', 'Alkaline_phosphatase', 'Cholesterol_adjstatins', 'Fasting_glucose', 'LDL_direct_adjstatins', 'Rheumatoid_factor', 'Urate', 'Apolipoprotein_A', 'C_reactive_protein', 'Gamma_glutamyltransferase', 'Lipoprotein_A', 'SHBG', 'Urea', 'Apolipoprotein_B', 'Creatinine', 'Glucose', 'Microalbumin_in_urine', 'Sodium_in_urine', 'Vitamin_D', 'Apolipoprotein_B_adjstatins', 'Creatinine_in_urine', 'Glycated_haemoglobin_HbA1c', 'Non_albumin_protein', 'Testosterone', 'Aspartate_aminotransferase', 'Cystatin_C', 'HDL_cholesterol', 'Oestradiol', 'Total_bilirubin' )
cascade_files <- file.path('../cascade', 'cascade.input.files.tsv')
traits_df <- fread(cascade_files)
traits <- traits_df %>% 
filter(annotation != 'AST_ALT_ratio') %>% 
select(annotation) %>% pull()

traits_abb <- traits

## Initialize buffer
finemap          <- vector( 'list', length( traits ) )
names( finemap ) <- traits

## Collect results
for( trait in traits )
{
# 	regions <- read.table( sprintf( '/oak/stanford/groups/mrivas/users/christian/regions/noSingles_noX/%s_noSingles_noX.txt', trait ), as.is = T )
# 	regions <- read.table( sprintf( '/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/biomarkers/fine_mapping/filtration/%s_subset.tsv', trait ), as.is = T )
	regions <- read.table( sprintf( '/oak/stanford/groups/mrivas/users/ytanigaw/repos/rivas-lab/biomarkers/fine_mapping/filtration/filtered_regions/%s.txt', trait ), as.is = T )
	
	## Skip if there are no regions for this trait
	if( nrow( regions ) == 0 ) { next }
	
	## Initialize buffer for trait
	finemap[[ trait ]] <- data.frame(
		trait             = rep( NA, nrow( regions ) ),
		n_signals         = NA,
		n_signals_prob    = NA,
		n_snps_per_signal = NA
	)
	
	for( ii in seq( nrow( regions ) ) )
	{
		print( sprintf( '%s-%d', trait, ii ) )
		
		chr   <- regions[ ii, 2 ]
		start <- regions[ ii, 3 ]
		end   <- regions[ ii, 4 ]
		
		trait_label <- sprintf( '%s, %s, chr%s:%s-%s', trait, traits_abb[ match( trait, traits) ], chr, start, end )
		
		## FINEMAP
		filename <- sprintf( '/oak/stanford/groups/mrivas/users/christian/chr%s/%s/range%s-%s/GLOBAL_%s_chr%s_range%s-%s.config', chr, trait, start, end, trait, chr, start, end )
		if( !is.na( file.info( filename )$size ) && file.info( filename )$size > 0 )
		{
			## Read config file
			tmp <- data.table::fread( filename )
			
			## Parse posterior probability of
			## there being k causal SNPs in the
			## region
			post_prob_k    <- sapply( unique( tmp$k ), function( k ) sum( tmp$prob[ tmp$k == k ] ) )
			post_prob_k    <- post_prob_k / sum( post_prob_k )
			n_signals      <- unique( tmp$k )[ which.max( post_prob_k ) ]
			n_signals_prob <- max( post_prob_k )
			
			## Read credible set file
			cred              <- read.table( sprintf( '/oak/stanford/groups/mrivas/users/christian/chr%s/%s/range%s-%s/GLOBAL_%s_chr%s_range%s-%s.cred%s', chr, trait, start, end, trait, chr, start, end, n_signals ), header = T, as.is = T )
			n_snps_per_signal <- apply( cred[, seq( 2, ncol( cred ), 2 ), drop = F ], 2, function( x ) length( na.omit( x ) ) )
			
			finemap[[ trait ]][ ii, ] <- c( trait_label, n_signals, n_signals_prob, paste( n_snps_per_signal, collapse = '|' ) )
		}
	}
}

## Save results
# saveRDS( finemap, file = '/oak/stanford/groups/mrivas/users/christian/finemap_results_figure3.rds' )
saveRDS( finemap, file = 'finemap_results_figure3.rds' )

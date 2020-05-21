fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(data.table))

####################################################################

# input
parsed_finemap_f <- 'FINEMAP_output.tsv'
traits_f <- '../common/canonical_trait_names.txt'

# output
out_f <- file.path('figs', 'fig3A.%s.png')
out_tsv_f <- 'plotFinemapFig.per.trait.numbers.tsv'

####################################################################
source('finemap_functions.R')

traits_df <- fread(traits_f, stringsAsFactors = F) %>%
filter(annotation != 'Fasting_glucose') %>%
rename('trait' = 'annotation') %>%
arrange(trait) %>%
select(trait, name)
trait_plot_name_dict <- setNames(traits_df$name, traits_df$trait)

traits <- names(trait_plot_name_dict)

df <- fread(parsed_finemap_f) %>%
filter(trait %in% traits)

res <- list()
for(t in traits){
    res[[ t ]] <- df %>% filter(trait == t) %>% select(-trait)
}

# generate FINEMAP summary plot for each trait
for(trait in traits){
    png(sprintf(out_f, trait), width = 1200, height = 300)
    plot_FINEMAP_summary(
        get_n_regions(res[[ trait ]]),
        get_n_signals(res[[ trait ]]),
        table( get_n_signal_per_region( res[[ trait ]] ) ), 
        table( get_n_snps_per_signal( res[[ trait ]] ) ), 
        get_colors6(), 
        sprintf('%s, ', trait_plot_name_dict[[ trait ]])
    )
    dev.off()
    message(sprintf(out_f, trait))
}

# save the numbers in the plots into a tsv file

count_df <- do.call(rbind, lapply(
    traits,
    function(t) { compute_finemap_sumstats(t, res[[ t ]]) }
)) %>% as.data.frame(stringsAsFactors = F)

traits_df %>%
left_join(count_df, by='trait') %>%
fwrite(out_tsv_f, sep='\t', na = "NA", quote=F)

message(out_tsv_f)

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(data.table))

hits <- fread('filtered.hits.99.tsv')
anno <- fread('filtered.hits.99.anno.tsv')

joined <- hits %>%
left_join(
    anno %>%
    rename(
        'chromosome' = '#CHROM', 
        'position' = 'POS'
    ) %>%
    select(-maf), 
    by=c('chromosome', 'position')
)

joined %>% 
fwrite('filtered.hits.99.anno.joined.tsv', sep='\t')

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(data.table))

hits <- fread('filtered.hits.99.tsv', colClasses = c("chromosome" = "character")) %>%
mutate(chromosome = str_replace(chromosome, '^0', ''))
anno <- fread('filtered.hits.99.anno.tsv', colClasses = c("#CHROM" = "character"))

# read the list of filtered regions (this file has the paths of the .z files from. FINEMAP)
regions_all <- fread(
    cmd=paste(
        'zcat',
        '@@@@@@/users/ytanigaw/repos/rivas-lab/biomarkers/fine_mapping/filtration/filtered_regions.txt.gz'
    )
) %>%
rename('CHROM' = '#CHROM') %>%
mutate(
    zpath = file.path(
        '@@@@@@/users/christian',
        paste0('chr', CHROM), 
        TRAIT, 
        paste0('GLOBAL_', TRAIT, '_chr', CHROM, '_range', BEGIN, '-', END, '.z')
    )
)

# read .z files and generate a mapping between variants and regions
map_df <- 
regions_all %>% select(TRAIT) %>% unique() %>% pull() %>%
lapply(
    function(trait){
        regions_all %>% filter(TRAIT == trait) %>%
        select(zpath) %>% pull() %>% 
        lapply(
            function(zpath){
                fread(
                    zpath, 
                    colClasses = c("chromosome" = "character")
                ) %>% 
                mutate(
                    trait=trait, 
                    region=str_replace_all(basename(zpath), 'GLOBAL_|.z', '')
                )
            }
        ) %>% bind_rows()
    }
) %>% bind_rows()

# join the 3 data frames
# 1. map_df (variant to region)
# 2. hits
# 3. variant annotations
joined <- map_df %>% select(chromosome, position, trait, region) %>%
right_join(
    hits, by=c('chromosome', 'position', 'trait')
) %>%
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

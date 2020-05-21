fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

####################################################################
in_f  <- args[1]
out_f <- args[2]
####################################################################

df <- fread(in_f)

df %>%
filter(!str_detect(MarkerName, 'X')) %>%
mutate(tmp = MarkerName) %>%
separate(tmp, c('CHROM', 'POS', NA, NA)) %>%
select(all_of(c('CHROM', 'POS', colnames(df)))) %>%
arrange(as.numeric(CHROM), as.numeric(POS)) %>%
rename('#CHROM' = 'CHROM') %>%
fwrite(out_f, sep='\t', na = "NA", quote=F)

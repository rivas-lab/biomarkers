args = commandArgs(trailingOnly=TRUE)

require(tidyverse)
require(data.table)
require(glmnet)
require(survival)

####################################################################
read_config_from_file <- function(config_file){
    config_df <- config_file %>% fread(header=T, sep='\t') %>%
    setnames(c('key', 'val'))
    
    config_l        <- config_df %>% select(val) %>% pull()
    names(config_l) <- config_df %>% select(key) %>% pull()
    
    return(config_l)
}
####################################################################

# read config file
config <- read_config_from_file(args[1])

# load snpnet
devtools::load_all(config[['snpnet_dir']])

# please check if glmnet version is >= 2.0.20
print(packageVersion("glmnet"))

# configue paths
data_dir_root  <- config[['data_dir_root']]
phenotype.name <- config[['phenotype_name']]
phenotype.file  <- file.path(data_dir_root, config[['phenotype_file']])
results.dir     <- file.path(data_dir_root, phenotype.name, 'results')
 
print(phenotype.name)

# call snpnet::snpnet
fit <- snpnet(
    genotype.dir = config[['genotype_dir']],
    phenotype.file = phenotype.file,
    phenotype = phenotype.name,
#    covariates = strsplit(config[['covariates']], ',')[[1]],
    covariates = c(),
    family = config[['family']],
    results.dir = results.dir,
    niter = config[['niter']], 
    configs = list(
        missing.rate = 0.1,
        MAF.thresh = 0.001,
        nCores = as.integer(config[['cpu']]),
        bufferSize = as.integer(as.integer(config[['mem']]) / as.integer(config[['mem2bufferSizeDivisionFactor']])),
        meta.dir = "meta",
        nlams.init = 10,
        nlams.delta = 5
    ),
    verbose = T, validation = T, save = T,
    prevIter = as.integer(config[['prevIter']])
)

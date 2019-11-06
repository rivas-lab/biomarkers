library(dplyr)

biomarkers <- read.table(commandArgs(TRUE)[1], header=T)
colnames(biomarkers)[1] = "IID"

biomarkers %>% mutate(NonAlbuminProtein=f.30860.0.0 - f.30600.0.0) %>%
    write.table(commandArgs(TRUE)[2], quote=F, sep="\t", row.names=F, col.names=T)

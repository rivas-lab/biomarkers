library(dplyr)
vars <- read.table(commandArgs(TRUE)[2], header=F)$V1
mfi <- data.table::fread("@@@@@@/projects/biomarkers/gwas/mfi_info03.txt.gz", header=T)


mfi %>% filter(ID %in% vars) -> mfilt

combined.leads <- data.table::rbindlist(lapply(commandArgs(TRUE)[3:length(commandArgs(TRUE))], function(zpath) {
    z <- read.table(zpath, header=T)
    
    inner_join(z, mfilt, by=c("rsid" = "SNP")) %>% mutate(P = 2*pnorm(-abs(beta/se))) %>% mutate(range=dirname(zpath)) 
}))

write.table(combined.leads, commandArgs(TRUE)[1], quote=F, sep="\t", row.names=F, col.names=T)

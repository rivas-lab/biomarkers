mfi <- data.table::fread("~/biomarkers/gwas/mfi_info03.txt.gz", header=T)
sumstats <- data.table::fread(commandArgs(TRUE)[1], header=T)
library(dplyr)

chromosome.order <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "X", "XY", "Y", "M")

inner_join(mfi, sumstats %>% filter(A1_FREQ >= 0.001, A1_FREQ <= 0.999, !is.na(P))) %>% arrange(factor(as.character(CHROM), levels=chromosome.order), POS) -> mfs
write.table(mfs, gzfile(commandArgs(TRUE)[2]), quote=F, sep="\t", row.names=F, col.names=T)

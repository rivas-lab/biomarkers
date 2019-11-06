#bim <- data.table::fread("~/scratch/tools/ldsc/1000G_EUR_Phase3_plink/mymerge.bim", header=F)
bim <- data.table::fread("/oak/stanford/groups/mrivas/projects/biomarkers/meta/decode_wgs_genetic_map_sex_combined.hg19.bed", header=F, col.names=c("CHROM", "POS0", "BP", "RR", "CM"))

bim$CHROM = gsub("chr", "", bim$CHROM)

urate <- read.table(commandArgs(TRUE)[1], header=T)
library(dplyr)

urate$CHROM <- gsub(":.*", "", urate$MarkerName)
urate$POS <- gsub("_.*", "", gsub(".*:", "", urate$MarkerName))
urate$P <- urate$P.value

urate %>% na.omit -> urate
urate$CM <- NA

for (i in as.character(c(1:22, "X"))) {
    approx(bim[bim$CHROM == i,]$BP, bim[bim$CHROM == i,]$CM, method="linear", xout=urate[urate$CHROM == i,]$POS)$y -> urate[urate$CHROM == i,]$CM
}

urate %>% group_by(CHROM) %>% arrange(CM) %>%
    mutate(id=1:n(), prev=lag(CM, 1, 0), block=cumsum(CM - prev > 1)) %>%
    group_by(CHROM, block) %>% arrange(P) %>% filter(1:n() == 1) %>%
    write.table(commandArgs(TRUE)[2], quote=F, sep="\t", row.names=F, col.names=T)

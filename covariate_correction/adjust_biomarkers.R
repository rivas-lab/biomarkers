library(dplyr)

adjust.statins <- read.table("adjustments/statins.txt", header=T)
column <- sprintf("f.%s.1.0", adjust.statins$ID)
adjust.statins$column <- sprintf("f.%s.1.0", adjust.statins$ID)
adjusted <- adjust.statins %>% filter(P < 0.01)


drugs.taken <- read.table("phenotypes/drugs_followup.phe", header=T)
drugs.adjusted <- read.table("adjustments/statins_ids.txt", header=F)$V1

num.drugs <- select(drugs.taken, f.eid)
num.drugs$Drugs <- 0

for (i in drugs.adjusted) {
    print(i)
    num.drugs$Drugs <- num.drugs$Drugs + rowSums(drugs.taken[,2:ncol(drugs.taken)] == i, na.rm=T)
}

print(summary(num.drugs$Drugs))

print(head(num.drugs))

num.drugs %>% mutate(AnyDrug=Drugs > 0) %>% write.table("covariates/statins_followup.phe", quote=F, sep="\t", row.names=F)

raw <- read.table("phenotypes/raw/biomarkers.phe", header=T)
rownames(raw) <- raw$f.eid
raw <- raw[,adjusted$column]

on.drugs <- num.drugs %>% filter(Drugs > 0) %>% .$f.eid

for (adj in 1:nrow(adjusted)) {
    slope.correction <- ifelse(rownames(raw) %in% on.drugs, adjusted$Multiplier[adj], 1)
    offset.correction <- ifelse(rownames(raw) %in% on.drugs, adjusted$Offset[adj], 0)
    raw[,adjusted$column[adj]] <- raw[,adjusted$column[adj]] * slope.correction + offset.correction
}
raw <- cbind(data.frame(IID=rownames(raw)), raw)
write.table(raw, "phenotypes/statin_adjusted/biomarkers.phe", quote=F, sep="\t", row.names=F, col.names=T)


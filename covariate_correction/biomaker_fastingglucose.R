library(dplyr)

biomarkers <- read.table(commandArgs(TRUE)[1], header=T)
colnames(biomarkers)[1] = "IID"

covar <- read.table("covariates/fastingtime.phe", header=T)

biomarkers %>% select(IID, f.30740.0.0) %>% inner_join(covar, by=c("IID" = "f.eid")) -> bio.cov

colnames(bio.cov) <- c("IID", "glucose", "fastingtime")

bio.cov <- bio.cov %>% mutate(FastingGlucose=ifelse(fastingtime >= 8 & fastingtime < 24, glucose, NA))

inner_join(biomarkers, bio.cov %>% select(IID, FastingGlucose), by=c("IID" = "IID")) %>%
    write.table(commandArgs(TRUE)[2], quote=F, sep="\t", row.names=F, col.names=T)

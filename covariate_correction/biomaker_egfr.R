
library(dplyr)
biomarkers <- read.table(commandArgs(TRUE)[1], header=T)
colnames(biomarkers)[1] = "IID"

covar <- read.table("covariates/egfr.covariates.phe", header=T)

biomarkers %>% select(IID, f.30700.0.0) %>% inner_join(covar, by=c("IID" = "f.eid")) -> bio.cov
colnames(bio.cov) <- c("IID", "creatinine", "sex", "ethnicity", "age")

bio.cov <- bio.cov %>% mutate(female = ifelse(sex == 0, TRUE, FALSE),
                   kappa=ifelse(female, 61.9, 79.6),
                   alpha=ifelse(female,-0.329,-0.411),
                   srblack = ethnicity %in% c(4, 4001,4002,4003),
                   eGFR = 141 * pmin(creatinine/kappa, 1)^alpha *
                                pmax(creatinine/kappa, 1)^-1.209 *
                                0.993^age * ifelse(female, 1.018, 1) *
                                ifelse(srblack, 1.159, 1))

inner_join(biomarkers, bio.cov %>% select(IID, eGFR), by=c("IID" = "IID")) %>%
    write.table(commandArgs(TRUE)[2], quote=F, sep="\t", row.names=F, col.names=T)

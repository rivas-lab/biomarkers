cov <- read.table("@@@@@@/ukbb/24983/sqc/ukb24983_GWAS_covar.phe", header=T)
drawtime <- read.table("covariates/draw_time_minutes.phe", header=T)
tdi <- read.table("covariates/townsend.phe", header=T)
dilution <- read.table("covariates/DilutionFactorTimepointZero.phe",header=T)
library(dplyr)
colnames(tdi) <- c("IID", "TDI")
usm <- read.table("covariates/UrineSampleMinutes.phe", header=T)
colnames(usm) <- c("IID", "UrineSampleMinutes")
fast <- read.table("covariates/fastingtime.phe", header=T)
colnames(fast) <- c("IID", "FastingTime")

cov %>% inner_join(usm) %>% inner_join(tdi) %>% inner_join(drawtime) %>% inner_join(dilution) %>% inner_join(fast) -> full.cov

assess <- read.table("covariates/assessment.phe", header=T)
assess$f.53.0.0 <- sub("-[^-]*$", "", assess$f.53.0.0)
library(mltools)
library(data.table)
assess$f.53.0.0 <- as.factor(assess$f.53.0.0)
assess$f.54.0.0 <- as.factor(assess$f.54.0.0)
assess$f.53.0.0 <- as.factor(gsub("^2006-.*", "2006", assess$f.53.0.0))
assess$f.53.0.0 <- as.factor(gsub("^2010-08", "2010-0810", assess$f.53.0.0))
assess$f.53.0.0 <- as.factor(gsub("^2010-09", "2010-0810", assess$f.53.0.0))
assess$f.53.0.0 <- as.factor(gsub("^2010-10", "2010-0810", assess$f.53.0.0))
oneassess <- one_hot(as.data.table(assess))
colnames(oneassess)[1] <- "IID"
full.cov %>% inner_join(oneassess) -> full.cov

write.table(full.cov, "covariates/merged.phe", quote=F, sep="\t", row.names=F, col.names=T)

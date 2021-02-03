library(dplyr)
library(broom)
library(RNOmni)

batch <- data.table::fread("@@@@@@/ukbb24983/fam/ukb2498_cal_v2_s488370.fam", header=F, col.names=c("FID", "IID", "P1", "P2", "S", "Batch")) %>% select(IID, Batch)

fix.ethnicity = c("4"=4003, "2"=2004, "1"=1003, "3"=3004, "-1" =6)

eth <- read.table("/scratch/groups/pritch/ukbb/irish/ethnicity.phe", header=T, col.names=c("IID", "Ethnicity")) %>%
    mutate(Ethnicity = ifelse(as.character(Ethnicity) %in% names(fix.ethnicity), fix.ethnicity[as.character(Ethnicity)], Ethnicity)) %>%
    mutate(Ethnicity = as.factor(Ethnicity))

anth <- read.table("phenotypes/anthropometrics.phe", header=T, stringsAsFactors=F) %>% select(f.eid, f.48.0.0, f.49.0.0, f.50.0.0, f.21002.0.0) %>%
    mutate(IID = f.eid, BMI = f.21002.0.0/f.50.0.0**2, WHRadjBMI = residuals(lm(log2(f.49.0.0/f.48.0.0) ~ BMI, na.action=na.exclude))) %>%
    mutate(BMI = as.factor(ntile(BMI, 50)), WHRadjBMI = as.factor(ntile(WHRadjBMI, 50))) %>% select(IID, BMI, WHRadjBMI)

print("Reading covariates")
full.cov <- read.table("covariates/merged.phe", header=T, stringsAsFactors=F) %>%
    mutate(ageIndicator = as.factor(ifelse(age < 50, 50, ifelse(age > 78, 78, age)))) %>% 
    mutate(ageBin = as.factor(ntile(age, 5))) %>% 
    mutate(FastingTime = as.factor(ifelse(FastingTime > 18, 18, ifelse(FastingTime == 0, 1, FastingTime)))) %>%
    mutate(UrineSampleMinutes=as.factor(ifelse(UrineSampleMinutes == 0, 0, ntile(UrineSampleMinutes, 20)))) %>%
    mutate(DrawTime=as.factor(ntile(DrawTime, 20))) %>%
    mutate(TDI=as.factor(ntile(TDI, 50))) %>%
    mutate(DilutionFactorTimeZero=as.factor(ntile(DilutionFactorTimeZero, 20))) %>%
    left_join(batch) %>% left_join(eth) %>% left_join(anth) %>% filter(sex==1, Ethnicity == "1001") %>% select(-sex, -Ethnicity)

print("Unfiltered")
print(dim(full.cov))

print("not na")
print(dim(na.omit(full.cov)))

print("Generating covariate formula")
kept.terms <- colnames(full.cov %>% select(-IID, -FID, -age, -Array))
covariates <- paste0(paste(kept.terms, collapse=" + "),
     " + ageBin * TDI + ageBin * BMI + ageBin * WHRadjBMI + ageBin * FastingTime")

invnorm.pops <- c("african", "e_asian", "s_asian", "white_british", "non_british_white")
invnorm.keeps <- sprintf("@@@@@@/private_data/ukbb/24983/sqc/population_stratification/ukb24983_%s.phe", invnorm.pops)
invnorm.ids <- lapply(invnorm.keeps, function(x) read.table(x, header=F)$V1)

#biomarker	name	date_field	aliquot_field
#30620	Alanine_aminotransferase	30621	30622
#30600	Albumin	30601	30602
#30610	Alkaline_phosphatase	30611	30612
biomarker2day <- read.table("@@@@@@/projects/biomarkers/covariate_corrected/biomarker2day.txt", header=T, stringsAsFactors=F)

bsf <- data.table::fread("@@@@@@/projects/biomarkers/covariate_corrected/phenotypes/raw/biomarkers_serum_full.phe", header=T)
buf <- data.table::fread("@@@@@@/projects/biomarkers/covariate_corrected/phenotypes/raw/biomarkers_urine_full.phe", header=T)

all_full <- inner_join(bsf, buf)

print(covariates)

regression.data <- full.cov %>% mutate(IID=as.numeric(IID), FID=as.numeric(FID)) %>% na.omit

print("regression data")
print(dim(regression.data))

process.phe <- function(biomarker.id, code, suffix, output.path, output.path.invnorm, time="\\.0") {
    phenotype.name <- paste0(biomarker.id, suffix)

    extra_fields.regex <- biomarker2day %>% filter(code == biomarker) %>% pull(extra_fields)

    print(phenotype.name)
    phe.columns.partial = grep(paste0(as.character(code), time), colnames(phes), value=T)
    phe.columns.exact = intersect(as.character(code), colnames(phes))
    phe.columns <- c(phe.columns.partial, phe.columns.exact)
    extra.covar.columns = grep(sprintf("(%s)%s", as.character(extra_fields.regex), time), colnames(all_full), value=T)

    if (length(phe.columns) != 1) {
        return(list(biomarker.id=phenotype.name, estimates=NA, power=NA));
    }

    phe <- phes[,c("IID", phe.columns)]

    colnames(phe) <- c("IID", phenotype.name)

    if (length(extra.covar.columns) > 0) {
        extra.covariates <- all_full[,c("f.eid", extra.covar.columns)]
        extra.covariate.names <- colnames(extra.covariates)[2:ncol(extra.covariates)]

        print(dim(extra.covariates))
        print(dim(na.omit(extra.covariates)))

        # Remove all samples where there are fewer than 42 individuals with the same extra indicator,
        # for each extra indicator. This removes less than 0.05% of individuals for almost all traits.
        for (extra in extra.covariate.names) {
            levels <- table(extra.covariates[,extra])
            dropped.levels <- names(levels)[levels < 42]
            extra.covariates[extra.covariates[,extra] %in% dropped.levels, extra] <- NA
            print(c(extra, sum(extra.covariates[,extra] %in% dropped.levels)))
        }

        extra.covar.terms <- paste(sprintf("as.factor(%s)", extra.covariate.names), collapse=" + ")

        print(head(phe))
        phe <- phe %>% inner_join(extra.covariates, by=c("IID" = "f.eid")) %>% na.omit
        regression.formula <- formula(sprintf("log(%s) ~ %s + %s", phenotype.name, covariates, extra.covar.terms))
    } else {
        regression.formula <- formula(sprintf("log(%s) ~ %s", phenotype.name, covariates))
    }

    regression.data <<- left_join(regression.data, phe)

    print(regression.formula)

    print(dim(phe))

    lm(regression.formula, regression.data) -> linreg

    regression.data[!is.na(regression.data[,phenotype.name]),paste0("residual.", phenotype.name)] <<- linreg$residuals

    regression.data %>% select(FID, IID) -> output
    output[,phenotype.name] <- NA
    output[!is.na(regression.data[,phenotype.name]),phenotype.name] = linreg$residuals

    dir.create(dirname(output.path),recursive=T)
    write.table(output, output.path, row.names=F, col.names=T, quote=F, sep="\t")

    for (invnorm.index in 1:length(invnorm.pops)) {
        print(invnorm.pops[invnorm.index])
        output.invnorm <- output %>% filter(IID %in% invnorm.ids[[invnorm.index]])
        output.invnorm[!is.na(output.invnorm[,phenotype.name]),phenotype.name] = rankNorm(output.invnorm[!is.na(output.invnorm[,phenotype.name]),phenotype.name])
        dir.create(dirname(sprintf(output.path.invnorm, invnorm.pops[invnorm.index])),recursive=T)
        write.table(output.invnorm, sprintf(output.path.invnorm, invnorm.pops[invnorm.index]), row.names=F, col.names=T, quote=F, sep="\t")
    }

    summary.linreg <- summary(linreg)

    list(name=phenotype.name, estimates=tidy(linreg), power=c(r.squared=summary.linreg$r.squared, adj.r.squared=summary.linreg$adj.r.squared, fstat=summary.linreg$fstatistic, df=summary.linreg$df))
}


print("Reading phenotypes")
phes <- read.table("phenotypes/biomarkers_with_egfr_fastingglucose_nonalbumin.phe", header=T, stringsAsFactors=F)
#phes <- read.table("phenotypes/raw/all_biomarkers.phe", header=T, stringsAsFactors=F)

colnames(phes)[1] <- "IID"

results <- sapply(1:nrow(biomarker2day), function(x) process.phe(biomarker2day$name[x], biomarker2day$biomarker[x], "", paste0("outputExtendedBMIreducedMaleWhiteBritish/phenotypes/residual/", biomarker2day$name[x], ".phe"), paste0("outputExtendedBMIreducedMaleWhiteBritish/phenotypes/invnorm/%s/", biomarker2day$name[x], ".phe")))

dir.create("outputExtendedBMIreducedMaleWhiteBritish/phenotypes", recursive=T)
dir.create("outputExtendedBMIreducedMaleWhiteBritish/covariates", recursive=T)
save(results, file="outputExtendedBMIreducedMaleWhiteBritish/covariates/regressions.RData")

print("Reading statin adjusted phenotypes")
phes <- read.table("phenotypes/statin_adjusted/biomarkers_simple.phe", header=T, stringsAsFactors=F)
colnames(phes)[1] <- "IID"

results.statins <- sapply(1:nrow(biomarker2day), function(x) process.phe(biomarker2day$name[x], biomarker2day$biomarker[x], "_adjstatins", paste0("outputExtendedBMIreducedMaleWhiteBritish/phenotypes/residual/", biomarker2day$name[x], ".adjust.statins.phe"), paste0("outputExtendedBMIreducedMaleWhiteBritish/phenotypes/invnorm/%s/", biomarker2day$name[x], ".adjust.statins.phe")))

save(results.statins, file="outputExtendedBMIreducedMaleWhiteBritish/covariates/regressions.adjust.statins.RData")

write.table(regression.data, "outputExtendedBMIreducedMaleWhiteBritish/phenotypes/full.table.phe", quote=F, sep="\t", row.names=F, col.names=T)

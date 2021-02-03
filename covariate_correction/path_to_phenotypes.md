
The covariate and phenotype data are stored in the following RDS file:

@@@@@@/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes/full.table.RDS

The full.table.RDS contains the phenotypes, the covariates, and the residualized phenotypes. There are also individual and combine phenotype files for the biomarkers at:

@@@@@@/projects/biomarkers/covariate_corrected/outputExtendedNoTDIreduced/phenotypes


Covariate adjustment
====================
The adjustment was run with the following covariates on the log trait to produce the residuals:

sex + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10 + PC11 + PC12 + PC13 + PC14 + PC15 + PC16 + PC17 + PC18 + PC19 + PC20 + PC21 + PC22 + PC23 + PC24 + PC25 + PC26 + PC27 + PC28 + PC29 + PC30 + PC31 + PC32 + PC33 + PC34 + PC35 + PC36 + PC37 + PC38 + PC39 + PC40 + UrineSampleMinutes + DrawTime + DilutionFactorTimeZero + FastingTime + f.53.0.0_2006 + f.53.0.0_2007.04 + f.53.0.0_2007.05 + f.53.0.0_2007.06 + f.53.0.0_2007.07 + f.53.0.0_2007.08 + f.53.0.0_2007.09 + f.53.0.0_2007.10 + f.53.0.0_2007.11 + f.53.0.0_2007.12 + f.53.0.0_2008.01 + f.53.0.0_2008.02 + f.53.0.0_2008.03 + f.53.0.0_2008.04 + f.53.0.0_2008.05 + f.53.0.0_2008.06 + f.53.0.0_2008.07 + f.53.0.0_2008.08 + f.53.0.0_2008.09 + f.53.0.0_2008.10 + f.53.0.0_2008.11 + f.53.0.0_2008.12 + f.53.0.0_2009.01 + f.53.0.0_2009.02 + f.53.0.0_2009.03 + f.53.0.0_2009.04 + f.53.0.0_2009.05 + f.53.0.0_2009.06 + f.53.0.0_2009.07 + f.53.0.0_2009.08 + f.53.0.0_2009.09 + f.53.0.0_2009.10 + f.53.0.0_2009.11 + f.53.0.0_2009.12 + f.53.0.0_2010.01 + f.53.0.0_2010.02 + f.53.0.0_2010.03 + f.53.0.0_2010.04 + f.53.0.0_2010.05 + f.53.0.0_2010.06 + f.53.0.0_2010.07 + f.53.0.0_2010.0810 + f.54.0.0_10003 + f.54.0.0_11001 + f.54.0.0_11002 + f.54.0.0_11003 + f.54.0.0_11004 + f.54.0.0_11005 + f.54.0.0_11006 + f.54.0.0_11007 + f.54.0.0_11008 + f.54.0.0_11009 + f.54.0.0_11010 + f.54.0.0_11011 + f.54.0.0_11012 + f.54.0.0_11013 + f.54.0.0_11014 + f.54.0.0_11016 + f.54.0.0_11017 + f.54.0.0_11018 + f.54.0.0_11020 + f.54.0.0_11021 + f.54.0.0_11022 + f.54.0.0_11023 + ageIndicator + ageBin + Batch + Ethnicity + ageIndicator * sex + sex * DrawTime + sex * UrineSampleMinutes + sex * FastingTime + ageBin * FastingTime + Ethnicity * sex
 + trait_specific_covariates

Trait_specific covariates are factors for the aliquot number and for the day of analysis for each of the traits which contributed. biomarker2day.txt has the details of which field IDs were used for each of the traits.


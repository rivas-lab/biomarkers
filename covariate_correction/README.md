The files included in this directory are as follows:

``adjust_biomarkers.R`` -- the code used for adjusting biomarkers for statin levels. This relies on two files, ``statins_ids.txt`` and ``statins.txt``, which contain the ATC codes for statins and the timepoint adjustments (as well as the raw p-values for those adjustments, excluding covariates).

``biomaker_egfr.R`` -- the code used to generate eGFR estimates from the creatinine biomarker data.
``biomaker_fastingglucose.R`` -- the code used to generate fasting glucose measurements from the glucose data.
``biomaker_nonalbumin.R`` -- the code used to generate non-albumin protein measurements from the total protein and the albumin measurements.

``full.cov.R`` -- the code used to make a table with all covariates to include in the residualization analysis.

``biomarker2day.txt`` -- the table of biomarkers, as well as the corresponding additional variables to include for the purposes of adjustment for biomarker-specific technical confounding.

Three versions of the covariate adjustment script are included:
``gen.full.table.bettercovariatesNoTDIreducedFemaleWhiteBritish.R``
``gen.full.table.bettercovariatesNoTDIreducedMaleWhiteBritish.R``
``gen.full.table.bettercovariatesNoTDIreduced.R``

This includes the main code used for the phenotype definitions, as well as the code used to generate the sex-stratified estimates among self-identified White British participants.

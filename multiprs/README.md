To evaluate the multi-PRS, we combined our White British test set with the self-identified non-British White individuals:

cat ../data/biomarker_free_white_british.phe /oak/stanford/groups/mrivas/ukbb24983/sqc/population_stratification/ukb24983_non_british_white.phe /oak/stanford/groups/mrivas/ukbb24983/sqc/population_stratification/split/ukb24983_white_british_{test,val}.phe | sort| uniq > ukb24983_european_testval.phe
cat ../data/biomarker_free_white_british.phe /oak/stanford/groups/mrivas/ukbb24983/sqc/population_stratification/ukb24983_non_british_white.phe /oak/stanford/groups/mrivas/ukbb24983/sqc/population_stratification/split/ukb24983_white_british_test.phe | sort| uniq > ukb24983_european_test.phe

Then the training set was defined as the individuals who had all the covariates in the self-identified White British individuals:

grep -vFf ukb24983_european_testval.phe /oak/stanford/groups/mrivas/ukbb24983/sqc/population_stratification/split/ukb24983_white_british_train.phe > ukb24983_white_british_train_biomarkers.phe

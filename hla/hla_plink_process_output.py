import pandas as pd
import os
import glob
import numpy as np
from statsmodels.stats import multitest



all_results = glob.glob('/oak/stanford/groups/mrivas/projects/biomarkers_rivas/main/w_british/*hla*gz')

all_results = [result for result in all_results if (("estradiol" not in result) and ("heumatoid" not in result))]

#bin_results = glob.glob('../hla_plink_output/*PHENO1.glm.logistic.hybrid')
#ini_results = glob.glob('../hla_plink_output/*PHENO1.glm.linear')

#all_results = bin_results + ini_results

haps_of_interest = open('../hla_genotype_data/haps_above_freq_thresh.tsv').read().splitlines()
names  = [result.split('w_british/')[1].split('.')[3] for result in all_results]

p_df = pd.DataFrame(columns=['ALL_ID', 'PHE_NAME', 'BETA', 'SE', 'T_STAT', 'P'])

#with open('/oak/stanford/groups/mrivas/users/guhan/repos/ukbb-tools/05_gbe/phenotype_info.tsv', 'r') as map_file:
#    gbe_id_to_name = {line.split()[0]:line.split()[1] for line in map_file}

for result, name in zip(all_results, names):
    print("Processing PLINK output file for " + name)
    #if result in bin_results:
    #    df = pd.read_table(result)[['ID', 'TEST', 'OR', 'SE', 'Z_STAT', 'P']]
    #else:
    #    df = pd.read_table(result)[['ID', 'TEST', 'BETA', 'SE', 'T_STAT', 'P']]
    df = pd.read_table(result)[['ID', 'TEST', 'BETA', 'SE', 'T_STAT', 'P']]
    df = df[df['TEST'] == 'ADD']
    df = df[df['ID'].isin(haps_of_interest)]
    for row in df.itertuples(index=True):
        #if result in bin_results:
        #    p_df.loc[len(p_df)] = [getattr(row, 'ID'), gbe_id_to_name[gbe_id], gbe_id, np.log(float(getattr(row, 'OR'))), float(getattr(row, 'SE')), float(getattr(row, 'Z_STAT')), float(getattr(row, 'P'))]
        #else:
        p_df.loc[len(p_df)] = [getattr(row, 'ID'), name, float(getattr(row, 'BETA')), float(getattr(row, 'SE')), float(getattr(row, 'T_STAT')), float(getattr(row, 'P'))]

p_df['ADJ_P'] = multitest.multipletests(p_df['P'], is_sorted=False, method='fdr_by')[1]

p_df.sort_values(['PHE_NAME', 'P', 'ALL_ID']).to_csv('plink_hla_results.tsv', sep='\t', index=False)

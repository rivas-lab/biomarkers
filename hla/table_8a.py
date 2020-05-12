import pandas as pd
import numpy as np


plink_table = pd.read_table('updated_names_plink_hla_results.tsv')

bma_sig_table = pd.read_table('updated_names_sig_bma_results.tsv')

new_df = pd.merge(plink_table, bma_sig_table,  how='right', left_on=['ALL_ID','PHENO'], right_on = ['ALL_ID','PHENO'])

all_ids = open('allelotypes_to_include.tsv').read().splitlines()

bma_df = new_df[new_df['posterior_prob'] >= 80].drop_duplicates()

bma_df = bma_df[bma_df['ALL_ID'].isin(all_ids)]
print("number:" + str(len(bma_df)))
print("alleles unique above 80:" + str(len(np.unique(bma_df['ALL_ID']))))
print("phenotypes unique above 80:" + str(len(np.unique(bma_df['PHENO']))))

blist = pd.read_table('biomarkerlist.tsv')[['Phenotype','GBE ID']]
blist.columns = ['PHENO','GBE ID']

bma_df = bma_df.merge(blist).drop(columns=['posterior_mean','posterior_sd'])
bma_df.columns = ['HLA Allele', 'Phenotype', 'PLINK Beta', 'PLINK SE', 'PLINK t-stat', 'PLINK P', 'BY-adjusted PLINK P', 'BMA posterior probability', 'GBE ID']
bma_df = bma_df[['HLA Allele', 'Phenotype', 'GBE ID', 'PLINK Beta', 'PLINK SE', 'PLINK t-stat', 'PLINK P', 'BY-adjusted PLINK P', 'BMA posterior probability']]

bma_df.drop_duplicates().to_csv('supp_table_8a.tsv', sep='\t', index=False)

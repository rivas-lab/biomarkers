import pandas as pd

plink_results = pd.read_table('plink_hla_results.tsv')
thresh = 0.05/1000

sig = plink_results[plink_results['P'] <= thresh]
all_ids = open('allelotypes.tsv').read().splitlines()
#name_df = pd.read_table('canonical_trait_names.txt')
#gbe_ids = set(name_df['GBE_ID'])
#sig = sig[sig['GBE_ID'].isin(gbe_ids)]
sig = sig[sig['ALL_ID'].isin(all_ids)]
sig.to_csv('paper_sig_plink_hla_results_191104.tsv', sep='\t', index=False)

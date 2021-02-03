# PheWAS analysis of protein-altering variants

```
Rscript phewas_data_prep.R 2>&1 | tee phewas_data_prep.log.txt
```

For GWAS catalog and FinnGen R2 look-up, we used the following scripts

```
bash ~/repos/rivas-lab/ukbb-tools/14_LD_map/LD_lookup.sh 17 45360730
tabix @@@@@@/public_data/snp153/VCF/GCF_000001405.25.gz NC_000017.10:45359511-45359511
```


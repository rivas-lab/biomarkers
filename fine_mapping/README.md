# Fine-mapping

To generate the figure for the fine-mapping analysis, we used the following scripts:

1. `parseFinemapOutputForFigure3.r`
2. `plotFinemapFigure3.ipynb` (this is the same content as in `plotFinemapFigure3.r`)
3. `plotFinemapFigure3.per.trait.R` 

```
[ytanigaw@sh-109-54 ~/repos/rivas-lab/biomarkers/fine_mapping]$ cat ../cascade/cascade.input.files.tsv | awk -v FS='\t' '(NR>1){print $2}' | grep -v AST_ALT_ratio | while read p ; do echo $p; Rscript plotFinemapFigure3.per.trait.R ${p} ; done
```

The results are saved and copied to the Google Drive shared folder: https://drive.google.com/drive/folders/1i6w0qQRfrv-vEi7NIMh2yoSsCgTYtdE-

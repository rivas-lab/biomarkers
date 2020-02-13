Clumping was run using the following plink command:

plink1.9 --bfile <WHITE_BRITISH_DOWNSAMPLE> --clump <INTERMEDIATE>
    --clump-p1 1e-3 --clump-p2 1e-3 --clump-r2 0.0001
    --clump-kb 10000 --clump-field P-value
    --clump-snp-field MarkerName

A clump map (which maps each variant to its corresponding clump) was generated with:

    awk '(NR>1) {{gsub(",", "," $3 "#", $0); print $3 "#" $12;}}' CLUMPFILE | tr ',' '\n' | sed 's/(.*//' | sed 's/#/\t/' > CLUMPMAP

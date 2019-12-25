require(tidyverse)
require(data.table)
require(latex2exp)


read_annot_ary <- function(annot_tbl){
    annot.arr <- fread(
        cmd=paste0('zcat ', annot_tbl), 
        sep='\t', 
        data.table=FALSE
    ) %>% mutate(
        MAF=pmin(freq, 1-freq)
    ) %>%
    mutate(
        variant = paste(CHROM, POS, REF, ALT, sep=':'),
        gbe_variant_page_key = paste0(CHROM, "-", POS)
    )
    annot.arr$Csq[!(annot.arr$Consequence %in% c("frameshift_variant","splice_donor_variant","stop_gained","stop_lost","start_lost","splice_acceptor_variant","splice_region_variant","missense_variant","inframe_insertion","inframe_deletion"))] = "non-coding"
    annot.arr$Csq[annot.arr$Consequence %in% c("splice_region_variant","missense_variant","inframe_insertion","inframe_deletion")] = "protein-altering"
    annot.arr$Csq[annot.arr$Consequence %in% c("frameshift_variant","splice_donor_variant","stop_gained","stop_lost","start_lost","splice_acceptor_variant")] = "protein-truncating"
    annot.arr    
}

compute_gene_name_mapping <-function(annot_ary){
    annot_ary %>% 
    select(ID, Gene_symbol, variant, Csq, Consequence, gbe_variant_page_key)
}

ld_filter <- function(df){
    # chr6:25477797-36448354
    df %>%
    mutate(
        chrom = as.numeric(chrom), pos = as.numeric(pos),
        is_outside_of_MHC = (chrom == 6 & pos < 25477797) | ( chrom == 6 & 36448354 < pos) | chrom != 6
    ) %>% select(-chrom, -pos)    
}

read_data_for_phewas_plot <- function(in_file, gene_name_mapping){
    fread(
        cmd=paste0('zcat <', in_file, "| egrep -v '^Code'"), sep='\t',
        stringsAsFactors=FALSE, data.table=FALSE
    ) %>% 
    filter(l10pval >= -log10(1/1000))%>% 
    rename(ID = affyid) %>%     
    left_join(gene_name_mapping, by='ID') %>%
    ld_filter() %>% 
    mutate(
        Code_group = str_replace_all(Code, '[0-9]', ''),
        is_biomarker_phe = FALSE
    ) %>% 
    filter(! Code_group %in% c('BROADQT', 'BROADBIN', 'MED'))  
}

show_dim <- function(df){
    paste0(
        'There are ',
        df %>% dim() %>% first(),
        ' associations with p <= ',
        10 ** -(df %>% select(l10pval) %>% min()),
        ' across ',
        df %>% select(Name) %>% pull() %>% unique() %>% length(),
        ' phenotypes and ',
        df %>% select(ID)   %>% pull() %>% unique() %>% length(),
        ' variants'
    )
}

summarize_numbers_by_lor_sign <- function(df){
    df %>%
    mutate(
        LOR_sign = if_else(LOR<0, 'negative', 'positive'),
    ) %>% 
    group_by(LOR_sign) %>%
    summarise(
        n_associations = n(),
        n_phenotypes   = length(unique(Code)),
        n_variants     = length(unique(ID))
    ) %>% bind_rows(
        df %>%
        mutate(
            LOR_sign = 'all',
            n_associations = n(),
            n_phenotypes   = length(unique(Code)),
            n_variants     = length(unique(ID))        
        ) %>%
        select(LOR_sign, n_associations, n_phenotypes, n_variants) %>% 
        unique()
    )

}

filter_by_code_group_and_p_and_MHC <- function(df, p_thr){
    df %>% 
    filter(
        l10pval >= -log10(p_thr)
    ) %>% 
    mutate(
        is_bin = ! Code_group %in% c('INI')
    ) %>%
    filter(is_outside_of_MHC)    
}

compute_n_assoc <- function(df){
    df %>% count(affyid, is_bin) %>% spread(is_bin, n) %>% 
    rename(
        n_assoc_qt = 'FALSE', n_assoc_bin = 'TRUE'
    ) %>%
    mutate(
        n_assoc_qt  = as.numeric(n_assoc_qt),
        n_assoc_bin = as.numeric(n_assoc_bin)
    )     
}

filter_variants <- function(n_assoc_df, n_assoc_qt_min, n_assoc_bin_min){
    filtered <- n_assoc_df %>%
    filter(
        n_assoc_qt >= n_assoc_qt_min, 
        n_assoc_bin >= n_assoc_bin_min
    ) %>% select(affyid) %>% pull()    
    paste0('There are ', length(filtered), ' variants after the filter') %>% print()
    filtered
}

filter_phenotypes <- function(df, min_count){
    filtered <- df %>% count(Code) %>% arrange(-n) %>% filter(n >= min_count) %>% 
    select(Code) %>% pull()    
    paste0(
        'There are ', length(filtered), 
        ' phenotypes after the filter')  %>% print()
    filtered
}

combine_with_biomarkers <- function(df, biomarker_df = array_df_plot, p_thr = 1e-4){
    df_IDs <- df %>% select(ID) %>% pull()
    
    df %>% show_dim() %>% print()
    
    df_combined <- df %>% 
    mutate(
        x_color = if_else(Code_group %in% c('HC', 'FH', 'RH', 'cancer', 'BIN'), '#D95F02', '#1B9E77')
    ) %>%
    select(ID, Code, l10pval, LOR, Name, Gene_symbol, Csq, Consequence, is_biomarker_phe, x_color) %>%
    bind_rows(
        array_df_plot %>% filter(ID %in% df_IDs) %>% mutate(x_color = '#7570B3')
    ) %>%
    filter(l10pval >= -log10(p_thr)) 
    
    df_combined %>% show_dim() %>% print()
    
    return(df_combined)
}

get_hclust_order_from_mat <- function(mat){
    mat_hclust <- (mat %>% dist() %>% hclust())
    sort_order <- mat_hclust$order
    keys <- mat %>% select(key) %>% pull()
    data.frame(
        key = keys[sort_order],
        order = 1:length(keys)
    )    
}

generate_heatmap <- function(
    df, max_value = .5,
    axis_text_x_size = 8,
    axis_text_y_size = 8,
    x_axis_color='#666666',
    y_axis_color='#666666',    
    xlab='Phenotype',
    ylab='Variant',
    sizelab = TeX('-$\\log_{10}$(P-value)'),    
    legend_color_title = 'Log odds ratio or beta  '
){
    if( ! 'x_color' %in% colnames(df) ) df$x_color = x_axis_color
    if( ! 'y_color' %in% colnames(df) ) df$y_color = y_axis_color
    
    y_order<- df %>% 
    rename(key = y_col) %>%
    dcast(key ~ x_col, mean, value.var = 'value_col', fill=0) %>%
    get_hclust_order_from_mat() %>%
    rename(y_col = key, y_order = order) %>%
    left_join(df %>% select(y_col, y_color) %>% unique(), by='y_col') %>%
    replace_na(list(y_color = y_axis_color))
    
    x_order<- df %>% 
    rename(key = x_col) %>%    
    dcast(key ~ y_col, mean, value.var = 'value_col', fill=0) %>%
    get_hclust_order_from_mat() %>%
    rename(x_col = key, x_order = order) %>%
    left_join(df %>% select(x_col, x_color) %>% unique(), by='x_col') %>%
    replace_na(list(x_color = x_axis_color))
    
    df_plot <- df %>%
    inner_join(x_order, by='x_col') %>% 
    inner_join(y_order, by='y_col') %>%
    mutate(
        value_col = if_else(value_col >  max_value,  max_value, value_col),
        value_col = if_else(value_col < -max_value, -max_value, value_col)
    ) 
    
    df_plot %>%    
    ggplot(aes(
        y = reorder(y_label, y_order), 
        x = reorder(x_label, x_order), 
        color = value_col, 
        size  = size_col
    )) + 
    geom_point() + 
    theme_classic() + 
    theme(
        panel.background = element_rect(
            fill = "grey79", 
            colour = "grey79", 
            size = 0.5, 
            linetype = "solid"
        ),
        panel.grid.major = element_line(colour="white", size=0.5),
        axis.text.x = element_text(
            size=axis_text_x_size, 
            color=x_order%>%arrange(x_order)%>%select(x_color)%>%pull(),
            angle = 90, hjust = 1, vjust=.4
        ),
        axis.text.y = element_text(
            size=axis_text_y_size, 
            color=y_order%>%arrange(y_order)%>%select(y_color)%>%pull(),
        ),
        legend.position="bottom"
    ) + 
    scale_color_gradient2(
        name=legend_color_title, low="turquoise4", mid="white", high="orangered1") +
    guides(
        size=guide_legend(override.aes=list(colour="turquoise4"))
    ) +    
    labs(
        y = ylab,
        x = xlab,
        size=sizelab
    ) + guides(
        color = guide_colourbar(order = 1),
        size = guide_legend(order = 2, ncol = 3)
    )
}

generate_phewas_heatmap <- function(
    df, max_LOR = .5,
    axis_text_x_size = 8,
    axis_text_y_size = 8,    
    xlab='Phenotype',
    ylab='Variant',
    sizelab = TeX('-$\\log_{10}$(P-value)'),
    legend_color_title = 'Log odds ratio or beta  '
){
    df %>%
    rename(
        x_col = Name, 
        y_col = ID,
        value_col = LOR, 
        size_col = l10pval
    ) %>%
    mutate(
        x_label = str_trunc(x_col, 30, "right"),
        x_label = paste0(x_label, ' (', Code, ')'),
        x_label = str_replace_all(x_label, '_', ' '),
        x_label = str_replace_all(x_label, '[(][)]', ''),
        y_label = paste0(y_col, '(', Gene_symbol, ')'),
        y_label = str_replace(y_label, '[(][)]$', ''),
        y_color = if_else(
            Csq == 'protein-truncating', '#D95F02', 
            if_else(
                Csq == 'protein-altering', '#1B9E77', '#7570B3'
            )
        )
    ) %>% 
    generate_heatmap(
        max_value = max_LOR, 
        axis_text_x_size = axis_text_x_size,
        axis_text_y_size = axis_text_y_size,
        xlab=xlab,
        ylab=ylab,
        sizelab=sizelab,
        legend_color_title=legend_color_title
    )    
}

generate_phewas_heatmap_v3 <- function(
    df, max_LOR = .5, 
    xlab='Phenotype',
    ylab='Variant',
    legend_color_title = 'Log odds ratio'
){
    affyid_order <- df %>% 
    rename(key = affyid) %>%
    dcast(key ~ Code, mean, value.var = 'LOR', fill=0) %>%
    get_hclust_order_from_mat() %>%
    rename(affyid = key, affyid_order = order)    
    
    Code_order <- df %>% 
    rename(key = Code) %>%
    dcast(key ~ affyid, mean, value.var = 'LOR', fill=0) %>%
    get_hclust_order_from_mat() %>%
    rename(Code = key, Code_order = order)    
    
    df %>%
    inner_join(affyid_order, by='affyid') %>% 
    inner_join(Code_order,   by='Code') %>%
    mutate(
        Name_trunc = str_trunc(Name, 30, "right"),
        Name_plot = paste0(Name_trunc, ' (', Code, ')'),
        affyid_plot = paste0(affyid, '(', Gene_symbol, ')')
    ) %>%
    mutate(
        LOR = if_else(LOR >  max_LOR,  max_LOR, LOR),
        LOR = if_else(LOR < -max_LOR, -max_LOR, LOR)
    ) %>%    
    ggplot(aes(
        y = reorder(affyid_plot, affyid_order), 
        x = reorder(Name_plot, Code_order), 
        color = LOR, 
        size = l10pval
    )) + 
    geom_point() + 
    theme_classic() + 
    theme(
        panel.background = element_rect(
            fill = "grey79", 
            colour = "grey79", 
            size = 0.5, 
            linetype = "solid"
        ),
        panel.grid.major = element_line(colour="white", size=0.5),
        axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position="bottom"
    ) + 
    scale_color_gradient2(
        name=legend_color_title, low="turquoise4", mid="white", high="orangered1") +
    guides(
        size=guide_legend(override.aes=list(colour="turquoise4"))
    ) +    
    labs(
        y = ylab,
        x = xlab
    ) 
}

generate_phewas_heatmap_v2 <- function(
    df,
    xlab='Phenotype',
    ylab='Variant',
    legend_color_title = 'Log odds ratio'
){
    affyid_order <- df %>% 
    rename(key = affyid) %>%
    dcast(key ~ Code, mean, value.var = 'LOR', fill=0) %>%
    get_hclust_order_from_mat() %>%
    rename(affyid = key, affyid_order = order)    
    
    Code_order <- df %>% 
    rename(key = Code) %>%
    dcast(key ~ affyid, mean, value.var = 'LOR', fill=0) %>%
    get_hclust_order_from_mat() %>%
    rename(Code = key, Code_order = order)    
    
    df %>%
    inner_join(affyid_order, by='affyid') %>% 
    inner_join(Code_order,   by='Code') %>%
    mutate(
        Name_trunc = str_trunc(Name, 30, "right"),
        Name_plot = paste0(Name_trunc, ' (', Code, ')'),
        affyid_plot = paste0(affyid, '(', Gene_symbol, ')')
    ) %>%
    ggplot(aes(
        y = reorder(affyid_plot, affyid_order), 
        x = reorder(Name_plot, Code_order), 
        color = LOR, 
        size = l10pval
    )) + 
    geom_point() + 
    theme_classic() + 
    theme(
        panel.background = element_rect(
            fill = "grey79", 
            colour = "grey79", 
            size = 0.5, 
            linetype = "solid"
        ),
        panel.grid.major = element_line(colour="white", size=0.5),
        axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position="bottom"
    ) + 
    scale_color_gradient2(
        name=legend_color_title, low="turquoise4", mid="white", high="orangered1") +
    guides(
        size=guide_legend(override.aes=list(colour="turquoise4"))
    ) +    
    labs(
        y = ylab,
        x = xlab
    ) 
}

generate_phewas_heatmap_v1 <- function(
    df, max_LOR = .5, 
    xlab='Phenotype',
    ylab='Variant',
    legend_title = 'Log odds ratio'
){
    affyid_order <- df %>% 
    rename(key = affyid) %>%
    dcast(key ~ Code, mean, value.var = 'LOR', fill=0) %>%
    get_hclust_order_from_mat() %>%
    rename(affyid = key, affyid_order = order)    
    
    Code_order <- df %>% 
    rename(key = Code) %>%
    dcast(key ~ affyid, mean, value.var = 'LOR', fill=0) %>%
    get_hclust_order_from_mat() %>%
    rename(Code = key, Code_order = order)    
    
    df %>%
    inner_join(affyid_order, by='affyid') %>% 
    inner_join(Code_order,   by='Code') %>%
    mutate(
        Name_trunc = str_trunc(Name, 30, "right"),
        Name_plot = paste0(Name_trunc, ' (', Code, ')'),
        affyid_plot = paste0(affyid, '(', Gene_symbol, ')'),
        LOR = if_else(LOR >  max_LOR,  max_LOR, LOR),
        LOR = if_else(LOR < -max_LOR, -max_LOR, LOR)
    ) %>%
    ggplot(aes(
        y = reorder(affyid_plot, affyid_order), 
        x = reorder(Name_plot, Code_order), 
        fill = LOR
    )) + geom_tile() +
    labs(
        y = ylab,
        x = xlab
    ) + theme_classic() + 
    theme(
        panel.grid.major = element_line(colour="gray", size=0.5),
        axis.text.x = element_text(size=6, angle = 90, hjust = 1),
        axis.text.y = element_text(size=6), 
        legend.position="bottom"
    ) + 
    # scale_fill_gradient2(
    #     low="navy", mid="white", high="red", 
    #     midpoint=0
    # ) 
    scale_fill_gradientn(
        legend_title,
        colors=colorRampPalette(c("#ff4466", "#ff7799", "#ffaabb", "#ffffff","#aaccff", "#77ccff", "#4477ff"))(200),
        limit=c(-max_LOR, max_LOR)
    )
}

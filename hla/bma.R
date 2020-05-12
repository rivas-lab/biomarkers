library("BMA")
library("dplyr")
args <- commandArgs(TRUE)
phe_path <- args[1]
num_alls <- args[2]
options(warn=1)

phe_name <- strsplit(phe_path, "/")[[1]]
phe_name <- strsplit(phe_name[length(phe_name)], "[.]")[[1]][1]
#phe_name <- 'HC430'
#analysis_type <- substr(phe_name, 1, 3)
thresh <- 0.05/1000
adj_thresh <- 0.05

all_ids = scan("allelotypes.tsv", what="", sep="\n")
#extra_names = scan("extra_phes.txt", what="", sep="\n")
#name_df = as.data.frame(read.table("canonical_trait_names.txt", header=TRUE, sep='\t'))
print(phe_name)
# Read in from "all sig results" file, get the sigs pertaining to this one. Don't run BMA if not enough hits.
phe_results <- as.data.frame(read.table("paper_sig_plink_hla_results_191104.tsv", header=TRUE))

#phe_results <- phe_results %>% filter(PHENO == phe_name) %>% filter(ADJ_P <= adj_thresh) %>% filter(GBE_ID %in% name_df$GBE_ID | GBE_ID %in% extra_names) %>% filter(ALL_ID %in% all_ids) %>% arrange(P) %>% top_n(-strtoi(num_alls), P)
phe_results <- phe_results %>% filter(PHE_NAME == phe_name) %>% filter(ADJ_P <= adj_thresh) %>% filter(ALL_ID %in% all_ids) %>% arrange(P) %>% top_n(-strtoi(num_alls), P)
#phe_results <- phe_results %>% filter(GBE_ID == phe_name) %>% filter(ADJ_P <= adj_thresh) %>% filter(ALL_ID %in% all_ids) %>% arrange(P) %>% top_n(-strtoi(num_alls), P)

print(phe_results)
if (nrow(phe_results) < 2) {
    print("Not enough significant results to run BMA!")
} else {
    print("Reading in dosage file...")
    dosage <- readRDS("/oak/stanford/groups/mrivas/users/guhan/repos/hla-assoc/scripts/output/ukb_hla_v3_24983_wb.rds")
    print("Reading in covariates file...")
    covars <- readRDS("/oak/stanford/groups/mrivas/users/guhan/repos/hla-assoc/scripts/output/ukb_hla_v3_covar_24983_wb.rds")

    print("Subsetting to non-sparse columns...")
    # use only columns with more than 5 nonzero entries
    col_idx = colSums(dosage != 0) > 5
    dosage <- dosage[,col_idx]

    print(paste0("Number of haplotypes excluded (additive): ", 362 - ncol(dosage)))

    print("Subsetting to covariates of interest...")
    covars <- covars[, c("age", "sex", "Array", "PC1", "PC2", "PC3", "PC4")]
    
    print("Reading phenotype:")
    print(phe_name)
    print("from file:")
    print(phe_path)
    phe <- as.data.frame(read.table(phe_path, header=FALSE, row.names=1))
    
    subset_ids <- intersect(rownames(covars), rownames(phe))
    print("Subsetting to those rows that have covariates...")
    phe <- phe[subset_ids,]
    covars <- covars[subset_ids,]
    dosage <- dosage[subset_ids,]
   
    print("Adding phenotype to covariate matrix, filtering out missing phenotypes...")
    covars["status"] = as.numeric(phe$V3)
    covars <- subset(covars, status!=-9)
    #if (analysis_type == "BIN") {
    #    print("Replacing binary values...")
    #    covars[covars$status == 1, "status"] = rep(0, sum(covars$status == 1))
    #    covars[covars$status == 2, "status"] = rep(1, sum(covars$status == 2))
    #}
    
    # get the names of the allelotypes were using
    all_names = phe_results$ALL_ID
    print("Running BMA for allelotypes: ")
    print(all_names)
    
    # filter dosages for these allelotypes
    dosage <- dosage[, names(dosage) %in% all_names]
    
    print("Subsetting dosage file to those rows in covariates file...")
    if (dim(covars)[1] != dim(dosage)[1]) {
        dosage <- dosage[rownames(covars),]
    }
    
    input = cbind(dosage, covars[, c("age", "sex", "Array", "PC1", "PC2", "PC3", "PC4")])
    pheno <- covars[, c("status")]
    print(head(input))
    print(head(pheno))
   
    print("Starting BMA...")

    # run BMA analysis
    #analysis_type <- substr(phe_name, 1, 3)
    #if (analysis_type == "BIN") {
    #    glm.out.FF <- bic.glm(input, pheno, strict = FALSE, OR = 5, glm.family="binomial", factor.type=FALSE, maxCol=100)
    #} else {
    #    glm.out.FF <- bic.glm(input, pheno, strict = FALSE, OR = 5, glm.family="gaussian", factor.type=FALSE, maxCol=100)
    #}
    glm.out.FF <- bic.glm(input, pheno, strict = FALSE, OR = 5, glm.family="gaussian", factor.type=FALSE, maxCol=100)
    fit <- summary(glm.out.FF)
    desired_row_names <- names(glm.out.FF$probne0)
    post_mean <- unname(glm.out.FF$condpostmean)[2:length(glm.out.FF$condpostmean)]
    post_sd <- unname(glm.out.FF$condpostsd)[2:length(glm.out.FF$condpostsd)]
    prob_ne0 <- unname(glm.out.FF$probne0)
    filename_col <- rep(phe_name, length(prob_ne0))
    results_df <- cbind.data.frame(post_mean, post_sd, prob_ne0, filename_col)
    row.names(results_df) <- desired_row_names
    names(results_df) <- c("Posterior mean", "Posterior standard deviation", "Prob!=0", "Phenotype")
    # save output
    print("Saving results to file prefix:")
    print(paste0("/oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/scripts/bma_output_191104/bma_", phe_name))
    write.table(results_df, paste0("/oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/scripts/bma_output_191104/bma_", phe_name, "_","round_all",".tsv"), col.names=NA, quote=FALSE, sep='\t')
    pdf(paste0("/oak/stanford/groups/mrivas/users/guhan/sandbox/hla_biomarkers/scripts/bma_output_191104/bma_", phe_name, "_round_adjp_all",".pdf"))

    # plot image
    imageplot.bma(glm.out.FF)
    dev.off()
}

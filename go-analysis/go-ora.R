# --------------------------- #
# GO Term Enrichment Analysis for Outlier-Associated Genes
# --------------------------- #
# This script performs over-representation analysis (ORA) of GO terms for genes
# near outlier SNPs using eggNOG-mapper annotations and the clusterProfiler package.
#
# Requirements:
# - R packages: data.table, tidyverse, ontologyIndex, clusterProfiler, DOSE
#
# Data:
# - eggNOG-mapper annotations: pika_background_proteins.emapper.annotations
# - GO ontology file: go.obo)
# - SNP-to-gene mapping files:
#   - pika_10pop_genes_20kb.txt (background genes)
#   - pika_outlier_genes_20kb.txt (outlier-associated genes)
# --------------------------- #

# --------------------------- #
# Environment setup
# --------------------------- #
library(data.table)
library(tidyverse)
library(ontologyIndex)
library(clusterProfiler)
library(DOSE)

# --------------------------- #
# Prepare GO term annotations
# --------------------------- #
# Load eggNOG-mapper annotation file and extract GO term–gene mappings
emapper_annot <- fread("go-annotation/pika_background_proteins.emapper.annotations", sep = "\t", skip = "query") %>%
  select(GOs, Preferred_name) %>%
  filter(GOs != "-") %>%
  separate_rows(GOs, sep = ",") %>%
  rename(term = GOs, gene = Preferred_name) %>%
  distinct()

# Load GO ontology file
# The ontology file can be downloaded from the Gene Ontology website:
# https://geneontology.org/docs/download-ontology/
ontology <- get_ontology(
  file = "data/go.obo",
  propagate_relationships = "is_a",
  extract_tags = "everything",
  merge_equivalent_terms = TRUE
)

# Create term -> name mapping and filter obsolete terms
emapper_term <- emapper_annot %>%
  mutate(name = ontology$name[term]) %>%
  select(term, name) %>%
  distinct() %>%
  drop_na() %>%
  filter(!grepl("obsolete", name))

# Filter annotation table to keep only non-obsolete terms
emapper_annot <- emapper_annot %>%
  filter(term %in% emapper_term$term)

# Save TERM2GENE and TERM2NAME files
write_tsv(emapper_annot, file = "go-ora-results/term2gene_GO.tsv")
write_tsv(emapper_term, file = "go-ora-results/term2name_GO.tsv")

# --------------------------- #
# Load gene sets
# --------------------------- #
# Background genes: all genes within 20kb of SNPs
background_genes <- read.table("snps-to-genes/pika_10pop_genes_20kb.txt") %>%
  unlist() %>% as.vector()

# Outlier-associated genes: genes within 20kb of outlier SNPs
interest_genes <- read.table("snps-to-genes/pika_outlier_genes_20kb_pcadapt_bayescan.txt") %>%
  unlist() %>% as.vector()

# --------------------------- #
# Run over-representation analysis (ORA)
# --------------------------- #
term2gene <- read_tsv("go-ora-results/term2gene_GO.tsv")
term2name <- read_tsv("go-ora-results/term2name_GO.tsv")

go_ora <- enricher(
    gene = interest_genes,
    pvalueCutoff = 0.01,
    pAdjustMethod = "BH",
    universe = background_genes,
    qvalueCutoff = 0.2,
    TERM2GENE = term2gene,
    TERM2NAME = term2name
)

# Save results
write.csv(as.data.frame(go_ora), file = "go-ora-results/go_ora_result.csv")

# --------------------------- #
# Visualize enrichment
# --------------------------- #
# Dotplot
if (any(go_ora@result$p.adjust <= 0.01)) {
  p1 <- dotplot(go_ora,
              x = "geneRatio",
              color = "p.adjust",
              orderBy = "x",
              showCategory = 10,
              font.size = 8) +
    ggtitle("Dotplot for GO ORA")

  ggsave(filename = "go-ora-results/go_ora_dotplot.png",
        plot = p1, dpi = 300, width = 21, height = 42, units = "cm")
}

# Enrichment map
if (any(go_ora@result$p.adjust <= 0.01)) {
  go_ora_sim <- pairwise_termsim(go_ora)
  p2 <- emapplot(go_ora_sim,
                showCategory = 20) +
    ggtitle("Enrichment Map for GO ORA")
  
  ggsave(filename = "go-ora-results/go_ora_emapplot.png",
         plot = p2, dpi = 300, width = 21, height = 42, units = "cm")
}

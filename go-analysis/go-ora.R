# --------------------------- #
# GO Term Enrichment Analysis for Outlier-Associated Genes
# --------------------------- #
# This script performs over-representation analysis (ORA) of GO terms for genes
# near outlier SNPs using eggNOG-mapper annotations and the clusterProfiler package.
#
# Requirements:
# - R packages: data.table, tidyverse, ontologyIndex, clusterProfiler, DOSE, enrichplot
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
library(enrichplot)

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
write.csv(as.data.frame(go_ora), file = "go-ora-results/go_ora_result.csv",
          row.names = FALSE, quote = FALSE)

# --------------------------- #
# Analyze key genes from top GO terms
# --------------------------- #
# Extract top 20 GO terms and identify key genes across functional categories

# Convert to dataframe and take top 20 GO terms (sorted by p.adjust)
go_ora_results_df <- as.data.frame(go_ora)
top20_GO_terms <- go_ora_results_df[1:min(20, nrow(go_ora_results_df)), ]

# Parse geneID column to create term-gene pairs
top20_term_gene_pairs <- top20_GO_terms %>%
  select(ID, Description, p.adjust, geneID) %>%
  separate_rows(geneID, sep = "/") %>%
  rename(Gene = geneID)

# Define functional categories based on GO term descriptions
categorize_go_terms <- function(description) {
  description <- tolower(description)

  if (grepl("synapse|synaptic", description)) {
    return("Synaptic")
  } else if (grepl("gtpase|guanyl", description)) {
    return("GTPase")
  } else if (grepl("development|metamorphosis|morphogenesis", description)) {
    return("Developmental")
  } else if (grepl("cellular component|chromatin|cytoplasmic", description)) {
    return("Cellular")
  } else {
    return("Other")
  }
}

# Add functional categories to term-gene pairs
top20_term_gene_pairs$Functional_Category <- sapply(top20_term_gene_pairs$Description, categorize_go_terms)

# Count genes per functional category
func_category_summary <- top20_term_gene_pairs %>%
  group_by(Functional_Category) %>%
  summarise(
    GO_terms = n_distinct(ID),
    Unique_genes = n_distinct(Gene),
    .groups = "drop"
  ) %>%
  arrange(desc(GO_terms))

# Identify genes appearing in multiple categories
gene_func_category_counts <- top20_term_gene_pairs %>%
  group_by(Gene) %>%
  summarise(
    Total_GO_terms = n(),
    Categories = n_distinct(Functional_Category),
    Category_list = paste(sort(unique(Functional_Category)), collapse = ", "),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_GO_terms), desc(Categories))

# Create priority ranking
prioritized_genes <- gene_func_category_counts %>%
  mutate(
    Prioritized = case_when(
      Total_GO_terms >= 5 & Categories >= 3 ~ "Yes",
      TRUE ~ "No"
    )
  ) %>%
  arrange(
    factor(Prioritized, levels = c("Yes", "No")),
    desc(Total_GO_terms)
  )

# Print summary results
cat("=== GO TERM ANALYSIS SUMMARY ===\n")
cat("Top 20 GO terms analyzed\n")
cat("Total unique genes:", length(unique(top20_term_gene_pairs$Gene)), "\n\n")

cat("=== FUNCTIONAL CATEGORY DISTRIBUTION ===\n")
print(func_category_summary)

cat("\n=== TOP 20 KEY GENES ===\n")
print(head(prioritized_genes, 20))

cat("\n=== PRIORITY COUNTS ===\n")
print(table(prioritized_genes$Prioritized))

# Save detailed results
write.csv(prioritized_genes %>% filter(Prioritized == "Yes"),
          "go-ora-results/go_ora_prioritized_genes.csv", row.names = FALSE, quote = FALSE)
write.csv(top20_term_gene_pairs, "go-ora-results/go_ora_top20_term_gene_pairs.csv",
          row.names = FALSE, quote = FALSE)
write.csv(func_category_summary, "go-ora-results/go_ora_functional_category_summary.csv",
          row.names = FALSE, quote = FALSE)

# --------------------------- #
# Visualize enrichment
# --------------------------- #
# Dotplot
if (any(go_ora@result$p.adjust <= 0.01)) {
  p1 <- dotplot(go_ora,
              x = "geneRatio",
              color = "p.adjust",
              orderBy = "x",
              showCategory = 20,
              font.size = 14) +
        labs(x = "Gene Ratio")

  ggsave(filename = "go-ora-results/go_ora_dotplot.png",
        plot = p1, width = 10, height = 15, units = "in", dpi = 300)
}

# Enrichment map
if (any(go_ora@result$p.adjust <= 0.01)) {
  go_ora_sim <- pairwise_termsim(go_ora)
  p2 <- emapplot(go_ora_sim,
                showCategory = 20)
  
  ggsave(filename = "go-ora-results/go_ora_emapplot.png",
         plot = p2, width = 10, height = 10, units = "in", dpi = 300)
}

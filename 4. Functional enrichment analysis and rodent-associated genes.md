# Funcitonal enrichment analysis
Functional enrichment analysis was done using anvi'o. For this, strain metadata was added to the pangenome as a layer information, after which the enrichment analysis was done as follows:

```
# Adding layer inforamtion
anvi-import-misc-data Layer_info/metadata.txt -p LJ_Gut/LJ_Gut-PAN.db --target-data-table layers

# Computing functional enrichment
anvi-compute-functional-enrichment-in-pan -p LJ_Gut/LJ_Gut-PAN.db -g LJ_Gut-GENOMES.db --category Host --annotation-source COG20_FUNCTION -o enriched.txt
```
This analysis was done using the Host category, from which gene clusters significantly associated with Rodent host groups was selected for further analysis.

# Rodent/MR1 uniques gene clusters
Simultaneously, gene clusters that were unique to rodents were identified using an R script from the summarized pangenome text file. 

```
# Reading in the anvi-summarize output
anvio_ouput <- read.csv('anvi_summarize.txt')

# Filtering for gene clusters unique to rodent isolates
AllRodent <- anvio_output[grep('Rodent_', anvio_output$genome_name),]
AllNotRodent <- anvio_output[!anvio_output$genome_name %in% unique(AllRodent$genome_name),]
OnlyInRodent <- AllRodent[!AllRodent$gene_cluster_id%in%AllNotRodent$gene_cluster_id,]

# Getting MR1 specific genes
MR1_specific <- OnlyInRodent %>% 
  filter(genome_name == "Rodent_MR1") %>% 
  select(gene_cluster_id, aa_sequence, COG20_CATEGORY) %>% 
  distinct(aa_sequence,.keep_all = T)
```
# Identifying the homologous of the rodent-associated gene clusters in MR1 strain
Once a list of rodent-associated gene clusters was acquired from both the functional enrichment analysis and the R script, the next step was to identify the coding sequences in MR1 that were homologous to the gene clusters. This was done using the pBLAST, with the gene cluster amino acid sequences as the query, and the MRI amino acid sequences as the subject. A gene was considered a positive hit if the per. Ident was>85% and a query coverage of at least 50%.

# Confirming that the identified genes are primarily rodent-associated.
Finally, the last step is to confirm that the identified genes in MR1 as rodent enriched/unique are indeed enriched/unique. This was done using an nBLAST analysis of the identified CDS against the fasta files of the _L. johnsonii_ strains. This was done by creating a local database.

```
# Concatenate the fasta files of all the strains
cat *5K.fasta > Lj_cat.fasta

# Make a local database
makeblastdb -in Lj42_cat.fasta -parse_seqids -title "Lj vertebrate GIT isolates" -dbtype nucl -out Lj_db

# Running the nBLAST
blastn -query rodent_assocaited_nuc.fna -db Lj_db -out rodent_associated_nuc_results.txt -outfmt "6 qseqid sseqid pident qcovs qlen length mismatch gapopen qstart qend sstart send evalue bitscore"
```

A hit alignment hit was considered positive if the percent identity is >85% and the query coverage is >50%. 
Any genes that had positive hits in all the strains were removed.

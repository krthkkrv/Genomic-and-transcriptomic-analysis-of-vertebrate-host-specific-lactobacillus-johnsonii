The maximum likelihood tree is built using the alignment of single-copy core gene clusters. The single-copy core gene clusters were then extracted from the pangenome using the interface. Once a collection bin of all the target gene clusters is set up, the amino acid sequences can be pulled down, using,

```
anvi-get-sequences-for-gene-clusters -p LJ_Gut/LJ_Gut-PAN.db \
                                       -g LJ-GENOMES.db \
                                       -C SCG -b SCG \
                                       --concatenate-gene-clusters \
                                       -o SCG_Gut.fa
```

A robust phylogenetic tree was then built using the SCG_gut.fa, and the two packages trimal and iqtree.

```
# Trim the fasta file
# Removing sequences that had over 50% gap sequences
trimal -in SCG_Gut.fa -out SCG_Gut-clean.fa -gt 0.50

# Run phylogenetic analysis using IQtree
iqtree -s SCG_Gut-clean.fa -nt 8 -m WAG -bb 1000
```

The consensus tree file generated was then visualized using Phylo.io

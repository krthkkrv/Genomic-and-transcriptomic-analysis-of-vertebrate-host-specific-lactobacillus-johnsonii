With the downloaded fasta files, the first step was to convert them into a anvi'o compatible fasta file. While doing so, a contig size limit was also set, at 2.5kb. This removes all contigs smaller than 2.5kb in the files.
To quickly run through all the files, this and following steps are all done using for/while loop

```
cat fastafiles.txt| while read -r base
do
echo "Working on $base ..."
anvi-script-reformat-fasta downloaded/${base}.fasta --min-len 2500 --simplify-names -o anvio_fasta/${base}_scaffolds_2.5K.fasta
done
```

The next step is generating a contig database file for each fasta file. Once this contig database is created, the next step is to annotate the contigs. This includes identifying gene calls, bacterial single-copy core genes, ribosomal RNAs, and transfer RNAs, as well as functional annotations. 

```
cat fastafiles.txt| while read -r g
do
echo "Working on $g ..."
anvi-gen-contigs-database -f anvio_fasta/${g}_scaffolds_2.5K.fasta -o contig_db/${g}.db --num-threads 4 -n ${g}
done

for g in contig_db/*.db
do
echo $g
anvi-run-hmms -c $g --num-threads 4 
anvi-run-ncbi-cogs -c $g --num-threads 4 
anvi-scan-trnas -c $g --num-threads 4 
anvi-run-scg-taxonomy -c $g --num-threads 4 
anvi-run-kegg-kofams -c $g --num-threads 4 
echo '$g completed'
done
```

Next, we assess the quality of the contigs, including parameters like completeness and contamination using,

```
anvi-display-contigs-stats contig_db/*db
```

Finally, the last step is to build a pangenome using these contig databases.

```
## Creating an external database
anvi-script-gen-genomes-file --input-dir contig_db/ \
                             -o external-genomes.txt
anvi-gen-genomes-storage -e external-genomes.txt \
                         -o LJ-GENOMES.db

anvi-pan-genome -g LJ-GENOMES.db \
                --project-name LJ_Gut\
                --num-threads 6 --output-dir LJ_Gut\
                --minbit 0.5 \
                --mcl-inflation 10 \
                --use-ncbi-blast
```

A TAB-delimited output file of the pangenome can be generated using,

```
anvi-summarize -g LJ-GENOMES.db \
               -p LJ_GUT-db \
               -C default
```

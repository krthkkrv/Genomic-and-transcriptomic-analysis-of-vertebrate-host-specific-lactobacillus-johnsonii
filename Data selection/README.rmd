Entrez Direct was used to pull down all assemblies of Lactobacillus johnsonii available at the time of the analysis (04/17/23). 

```
esearch -db assembly -query 'Lactobacillus johnsonii'| efetch -format docsum \
| xtract -pattern DocumentSummary \
-element AssemblyAccession,BioSampleAccn,Sub_value,AssemblyStatus,FtpPath_RefSeq > assembly_query_output.txt
```



## from this list remove thoses that do not have a RefSeq fttp link.
## Remaining 85 entries (in excel) 
	## ATCC33220 has two assembly accession, picked the scaffold assembly instead of contig
## Using this list of assembly accesssion numbers moving onto the next step.
## Pulling down all attribute information for the submission.
##
## 156 entries (as of 04/17/23) Of these 85 has ftp links 
for acc in `cat biosampleAccesson_list_86.txt`;
do 
esearch -db assembly -query $acc| elink -target biosample | efetch -format docsum \
| xtract -pattern DocumentSummary -element Accession -block Attribute -pfx "\t|" -sep "|" -tab "" \
-element Attribute@display_name,Attribute >> biosampleAccesson_list_86_output.txt;
## this gives every single attribute that is available for the biosample, spitting out both the key name and value seperated by  "|" and each pair seperated by '\t'.
done

## sed -n 's/|strain|//g' -n 's/|isolation source|//g' -n 's/|host|//g' -n 's/|geographic location|//g' biosampleAccesson_list_86_output.txt
## Could not parse the biosample query output using sed or awk, so did it manually in excel.

## Organised the metadata in the excel file, grouping first by host and then by site of isolation (Gut, Oral, Blood, Food..)
## Additionally altering the strain names to a more anvi'o friendly format (no '-' and '.')
## Also,creating a new column with the followig format <host>_<strain>, to be used as fasta file name.
## Finally two columns, assembly accession number and the new fasta file name are copied onto linux in query.txt file.

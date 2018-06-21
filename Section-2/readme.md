## Section 2: 16S Phylogenetic Analysis

In this exercise, we will learn how to make a robust species identification using DNA sequence data. We will start with a bacterial genome and extract the full length 16S rRNA gene from it. We will then use a web-tool to construct a phylogenetic tree.


### Download some data for a bacterial genome

Lets use the single cell genomics data we collected in Section 1.  The important thing is that this data is high-quality and does not contain any adapter sequences, so use the XX_cutadapt.q30.fastq files.




To reconstruct the full length 16S rRNA gene, we will use a program call Emirge:

https://github.com/csmiller/EMIRGE

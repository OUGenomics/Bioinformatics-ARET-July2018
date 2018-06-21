## Section 2: 16S Phylogenetic Analysis

In this exercise, we will learn how to make a robust species identification using DNA sequence data. We will start with a bacterial genome and extract the full length 16S rRNA gene from it. We will then use a web-tool to construct a phylogenetic tree.


### Download some data for a bacterial genome

Lets use the single cell genomics data we collected in Section 1.  The important thing is that this data is high-quality and does not contain any adapter sequences, so use the XX_cutadapt.q30.fastq files.

To reconstruct the full length 16S rRNA gene, we will use a program call Emirge:

https://github.com/csmiller/EMIRGE

Before we can use this software, we need to download a 16S database for reference.  I don't keep this in my docker file to prevent bloat of the file size. To do this, we will need to go into the EMIGE folder and run the download script:

```sh
cd /opt/local/software/EMIRGE
python emirge_makedb.py
```

This will download the SILVA_132_SSUREF_Nr99 files to your computer, which contain >600,000 reference 16S rRNA gene sequences.  It will then proceed to clustering.  Be patient. This may take a few minutes.


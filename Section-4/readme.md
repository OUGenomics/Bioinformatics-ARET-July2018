## Section 4: Genome Analysis

The process of genome annotation aims to assign function to DNA sequence.  In the simplest terms, it involves predicting the presence of functional RNA and protein coding genes.  Subsequently, these assignments are used to determine what the purpose the resulting products have inside cells.  It is not a trivial task and can be extremely time consuming.  It is also fraught with pitfalls and opportunities to do yourself a great disservice by confounding your ability to perform worthwhile downstream analysis.

We'll start the secion with a 5 minutes presentation from each person on what they have learned about their genome from the RAST annoation.  We'll then proceed to predicting some features of an assembled genome dataset.  We'll do this using some web-based tools and then I'll show you how to use linux bases software to do the same.

The following websites will come in handy for this:

#### rRNA prediction
http://www.cbs.dtu.dk/services/RNAmmer/
#### tRNA prediction
http://lowelab.ucsc.edu/tRNAscan-SE/
#### Protein prediction
http://linux1.softberry.com/berry.phtml?topic=fgenesb&group=programs&subgroup=gfindb
#### Annotation software
http://www.sanger.ac.uk/Software/Artemis/
#### Database Blast seraches
http://blast.ncbi.nlm.nih.gov/Blast.cgi
#### Enzyme descriptions
http://www.ebi.ac.uk/embl/

### RAST Annotation

RAST is a wonderful, fast annoation tool that gives you some basic idea of the genomic content of your organisms:

![RAST pie chart](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/RAST_pie.PNG)

Explore this graph a little.  Can you learn something about your critter ?  Does this make sense based on what you know about its ecology and origin ?

Then lest look at the KEGG maps.  

![kegg maps](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/kegg%20maps.PNG)

Can you learn somehting interesting from this ?

### Predicting Proteins and Extracting ORFs

Lets predict protein coding genes using two different methods called Prodigal and FragGeneScan:

### Prodigal

https://github.com/hyattpd/Prodigal

Lets start by making a sub-directory called 'prodigal' to deposit our output:

```sh 
mkdir /data/prodigal
cd /data
```

To predict ORFs as nucleotide (fna) and amio acid (faa) sequences do the following with your Contigs.fna file:

```sh 
prodigal -d prodigal/temp.orfs.fna -a prodigal/temp.orfs.faa -i contigs.fna -m -o prodigal/scores.txt -p meta -q
```
You can clean the output file up a little using a cut command:
```sh 
cut -f1 -d " " prodigal/temp.orfs.fna > prodigal/orfs.fna
cut -f1 -d " " prodigal/temp.orfs.faa > prodigal/orfs.faa
```

### FragGeneScan
http://omics.informatics.indiana.edu/FragGeneScan/

OK, now lets do it a different way using FragGeneScan.  Start by making an output directory.  Then you'll need to copy the training set into a local directory. This is a workaround; I'm not sure why it doesn't work without copying these files; sorry !) :
```sh 
mkdir /data/FragGeneScan
mkdir /data/Ftrain
cp /opt/local/software/FragGeneScan1.19/train/* /data/Ftrain
```

And now predict the ORFs:

```sh 
FragGene_Scan -s contigs.fna -o /data/FragGeneScan/output.FragGeneScan -w 1 -t complete
```

Lets compare the two methods:

```sh
wget https://github.com/bwawrik/MBIO5810/raw/master/perl_scripts/N50.pl
perl N50.pl FragGeneScan/output.frag.ffn
perl N50.pl prodigal/orfs.fna
```

Which one produces longers ORFs ? Which produces more ORFs ? Which is better ? Why ? What would be a better way to assess the quality of ORF calling ?


### Finding tRNA and rRNA genes

Lets start with tRNAs.  You can  use the web-portal above, and that is great. However, you are essentially tied ot the computational resources of someone else.  If they are busy, the server goes down, or your sequence file is too large, you will be stuck.  There are also many situations where you potentially have a large batch of sequences to check.  Most 'free' services will not be able to handle that sort of large data load.  In these situations, it is necessary to run requistie software locally. For tRNAScan-SE, you can find the documentation here:

http://lowelab.ucsc.edu/software/tRNAscan-SE-1.23.README

To run the program locally, first make an output directory and then run it on your contigs file:

```sh
mkdir tRNAscan
tRNAscan-SE -G -o tRNAscan/output.txt  contigs.fna
```

Did you get the same result as on the web-portal ?


### Pairwise Blast -- Genome-to-Genome Comparison


### KEGG Annotation -- and KEGG Mapping




### Assessing Genome Completeness


## Metagenome Gene Frequencies

### Proportion of Arachae to Bacteria

Microbial populations are made of both bacteria and archaea - but at what proportoin ? You can use metagenome analysis to figure this out by comparing all reads against a reference database of a single copy marker gene (SCMG).  SCMGs are genes which are only found once in each genome but are required to make a functional cell.  The 16S rRNA gene is not actually a SCMG, as it is frequently found twice, three, or four times or more in bacterial genomes (about once per megabase of sequence).  My preferred marker gene is rpoB.  We'll use two reference fasta files, one from bacteria and one from archaea. You can download these from this github entry here (lets put them in a sub-directory so we don't clutter things up):

```sh
mkdir rpoB
wget https://github.com/OUGenomics/Bioinformatics-ARET-July2018/raw/master/sample_seqs/arc_rpoB_AA.faa
wget https://github.com/OUGenomics/Bioinformatics-ARET-July2018/raw/master/sample_seqs/bac_rpoB_AA.faa
```

Do you remember how to make userach reference databases ? If not, go back to the prior tutorials.

The nice thing about usearch is that it eats both DNA and protein as well as fasta or fastq file. Very convenient ! Now find your metagenome files from the earlier tutorial and run usearch against the archaeal and bacterial reference databases:

```sh
usearch -usearch_global SRX3577904_1.fastq -db bac.udb -id 0.4 -strand both -mincols 20 -maxhits 1 -qsegout bac_hit.fas -blast6out bac_hit.tab

usearch -usearch_global SRX3577904_1.fastq -db arc.udb -id 0.4 -strand both -mincols 20 -maxhits 1 -qsegout arc_hit.fas -blast6out arc_hit.tab
```

The number of lines in the .tab file is equivalent to the number of hits.  You can get the number of hits using

```sh
wc -l < filename
```

In my case this produces:

```sh
[root@ffc80b019c25 rpob]# wc -l arc_hit.tab
746 arc_hit.tab
[root@ffc80b019c25 rpob]# wc -l <arc_hit.tab
746
[root@ffc80b019c25 rpob]# wc -l <bac_hit.tab
2923
```

The proportion of bacteria is (2923/(2923+746))*100 = 79.7%.  This of course mease that 20.3% of prokaryotic cells are Archaea.

While we are at it -- lets have some R-fun.  Try this:

```sh
wget https://github.com/bwawrik/MBIO5810/raw/master/R_scripts/bargraph_redgreen_scale.r
Rscript bargraph_redgreen_scale.r $(calc 3669*$(fgrep -o ">" bac_hit.fas | wc -l)/$(fgrep -o "+" SRX3577904_1.fastq | wc -l)*2) bac.png
Rscript bargraph_redgreen_scale.r $(calc 3669*$(fgrep -o ">" arc_hit.fas | wc -l)/$(fgrep -o "+" SRX3577904_1.fastq | wc -l)*2) arc.png
```
Take a look at the .png files that are produced. Extra points if you can figure out what happened here ;)



### What proportion of a population carries a particular Gene ?

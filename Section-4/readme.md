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

Yesterday you assembled a partial genome from a single cell genome sequencing project.  One qustion you may have is how similar this genome is to the genomes of previously sequenced bacteria - maybe the most closely related strain.   You can do this by downloading all the predicted proteins for a bacterium from a public database and then running a pairwise blast.  The best way to do this is to go to NCBIs GenBank 

https://www.ncbi.nlm.nih.gov/genbank/

Then search for the name of the  most closely related organism and add the term 'whole genome' to the search criteria. So, for example, search for 'Prochlorococcus marinus whole genome'.  You'll get a series of hits --

```sh
Prochlorococcus marinus MED4 complete genome
1,657,990 bp circular DNA
Accession:    NC_005072.1	GI:    33860560

Prochlorococcus marinus MIT9313 complete genome
2,410,873 bp circular DNA
Accession:    NC_005071.1	GI:    33862273

[...]
```

Select one -- make sure it is a whole genome sequence (check the size).  On the next page, select 'send to file' and choose 'coding sequences' and 'fasta nucleotide'

![get genome fasta](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/get_genome_fasta.PNG)

Save the file and name it appropriately.  I will name mine 'pcc.fas' for this example. Transfer the file to your docker /data folder.  Now prepare a usearch database from your predicted ORFs (nucleotide) and from this genome data:

```sh
cd /data
mkdir genome2genome
cp pcc.fna genome2genome
cp prodigal/orfs.fna genome2genome/orfs.fna
cd genome2genome
usearch -makeudb_usearch pcc.fna -output pcc.udb
usearch -makeudb_usearch orfs.fna -output orfs.udb
```

Now run a search of A vs B and the B vs A:

```sh
usearch -usearch_global pcc.fna -db orfs.udb -id 0.7 -strand both -mincols 50 -maxhits 1 -qsegout forward_hits.fas -blast6out forward_hit.tab

usearch -usearch_global orfs.fna -db pcc.udb -id 0.7 -strand both -mincols 50 -maxhits 1 -qsegout reverse_hits.fas -blast6out reverse_hit.tab
```
In my case I get this:
```sh
00:27 198Mb  100.0% Searching, 16.6% matched
00:08 175Mb  100.0% Searching, 72.2% matched
```
The number of lines in the .tab file is equivalent to the number of hits. You can count the ">" character in the .fna files to find out how many sequences in total you had.  You can get the number with the following commands:

```sh
wc -l < forward_hit.tab
wc -l < reverse_hit.tab
fgrep -o ">" pcc.fna | wc -l
fgrep -o ">" orfs.fna | wc -l
```

Are the forward and reverse numbers the same ? Why might they not be ?

Use this data to make a Venn-diagram:

![genome2genome venn](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/venn.png)


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

The number of lines in the .tab file is equivalent to the number of hits:

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

![bacteria vs archaea](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/BAC_ARC.png)


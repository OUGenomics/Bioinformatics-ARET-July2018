## Section 4: Genome Analysis

The process of genome annotation aims to assign function to DNA sequence.  In the simplest terms, it involves predicting the presence of functional RNA and protein coding genes.  Subsequently, these assignments are used to determine what the purpose the resulting products have inside cells.  It is not a trivial task and can be extremely time consuming.  It is also fraught with pitfalls and opportunities to do yourself a great disservice by confounding your ability to perform worthwhile downstream analysis.

We'll start the section with a 5 minutes presentation from each person on what they have learned about their genome from the RAST annotation.  We'll then proceed to predicting some features of an assembled genome dataset.  We'll do this using some web-based tools and then I'll show you how to use linux bases software to do the same.

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

RAST is a wonderful, fast annotation tool that gives you some basic idea of the genomic content of your organisms:

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
mkdir prodigal
cd /data # If you aren't already in the data directory
```

To predict ORFs as nucleotide (fna) and amino acid (faa) sequences do the following with your Contigs.fna file:

```sh 
prodigal -d prodigal/temp.orfs.fna -a prodigal/temp.orfs.faa -i ray_31/contigs.fasta -m -o prodigal/scores.txt -p meta -q
# Replace the ray_31 directory with whatever directory your contig.fasta file is located in
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
mkdir FragGeneScan
mkdir Ftrain
cp /opt/local/software/FragGeneScan1.19/train/* Ftrain
```

And now predict the ORFs:

```sh 
FragGene_Scan -s ray_31/contigs.fasta -o FragGeneScan/output.FragGeneScan -w 1 -t complete
```

Lets compare the two methods:

```sh
wget https://github.com/bwawrik/MBIO5810/raw/master/perl_scripts/N50.pl
perl N50.pl FragGeneScan/output.FragGeneScan.ffn
perl N50.pl prodigal/orfs.fna
```

Which one produces longers ORFs ? Which produces more ORFs ? Which is better ? Why ? What would be a better way to assess the quality of ORF calling ?


### Finding tRNA and rRNA genes

Lets start with tRNAs.  You can  use the web-portal above, and that is great. However, you are essentially tied to the computational resources of someone else.  If they are busy, the server goes down, or your sequence file is too large, you will be stuck.  There are also many situations where you potentially have a large batch of sequences to check.  Most 'free' services will not be able to handle that sort of large data load.  In these situations, it is necessary to run requisite software locally. For tRNAScan-SE, you can find the documentation here:

http://lowelab.ucsc.edu/software/tRNAscan-SE-1.23.README

To run the program locally, first make an output directory and then run it on your contigs file:

```sh
mkdir tRNAscan
tRNAscan-SE -G -o tRNAscan/output.txt  contigs.fna
```

Did you get the same result as on the web-portal ?


### Pairwise Blast -- Genome-to-Genome Comparison

Yesterday you assembled a partial genome from a single cell genome sequencing project.  One question you may have is how similar this genome is to the genomes of previously sequenced bacteria - maybe the most closely related strain.   You can do this by downloading all the predicted proteins for a bacterium from a public database and then running a pairwise blast.  The best way to do this is to go to NCBI's GenBank 

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

### Assessing Genome Completeness

Genome sequencing has become very routine, but rarely do you have a complete microbial genome after a simple Illumina run. In most cases, assuming that a genome is sequenced to a coverage of about 200x, you end up with 50-100 contigs of varying length.   Similarly, metagenomic binning or single cell genome sequencing typically only results in partial genome bins.  In these cases, it helps to be able to assess how complete the assembly is, i.e. what proportion of a bacterial genome is not captured by the assembly. In the above example, I show a dashed circle to indicate that we are likely missing the majority of the genome.  All things being equal and random sequencing we should be able to estimate that proportion of missing genome data by comparison to a database of single copy marker genes:

```
Wu, D.Y., Jospin, G., and Eisen, J.A. (2013) Systematic Identification of Gene Families for Use as "Markers" for Phylogenetic and Phylogeny-Driven Ecological Studies of Bacteria and Archaea and Their Major Subgroups. Plos One 8.
```
Download a reference marker hmm file. You'll need to get yourself the prodigal/orfs.faa file for this.

```sh
cd /data
mkdir smc
cp prodigal/orfs.faa smc
cd smc
wget https://github.com/bwawrik/MBIO5810/raw/master/sequence_data/sc_markers_bacteria.hmm
```
The .hmm file contains the models for 111 single copy marker genes found in all bacteria.

Run the HMM search:

The first step is to run an HMM search of your HMM models against each of the amino acid sequences. I'm applying an E score of 1E-10 here. This is relatively conservative. The commands below are for the SDB_ONE.faa file. 

```sh 
hmmsearch -E 0.0000000001 --domtblout sscmarkers.out.txt sc_markers_bacteria.hmm orfs.faa > sscmarkers.hmmsearch.txt
```

"--domblout" creates a tab delimited output file which we will use to count the number of unique hits.  The other file contains the complete HMM search output in case you are interested in it.

Lets break down the --domblout output and learn about piping. This command puts the content of the file out the screen:

```sh
cat sscmarkers.domtblout.txt
```

By using '|' we can 'pipe' the outptut to another linux command such as 'sed or awk:


```sh
cat sscmarkers.out.txt | sed '/^#/ d' | awk '{print $4}'
```

The 'sed' command removes all annotation lines, which start with a '#' character.
the 'awk' command extracts the fourth column, which contains the single copy marker gene identifiers.


- We can get the UNIQUE HITS using 'sort'

```sh
cat sscmarkers.out.txt | sed '/^#/ d' | awk '{print $4}' | sort -u
```

- All that is left is to count them

```sh
cat sscmarkers.out.txt | sed '/^#/ d' | awk '{print $4}' | sort -u | wc -l
```

This produces 36 for me.  (36 / 111) * 100 = 32.4%.   We also know from our prior analysis that we have 414 total genes in our dataset.  => (414 / 32.4)  * 100  => the estimated total genome size is ~1,277 genes

#### SELF EVALUATION

- Run the analysis on a complete genome you obtain from Genbank. Can you find all 111 single copy marker genes ?


## Metagenome Gene Frequencies

### Proportion of Arachae to Bacteria

Microbial populations are made of both bacteria and archaea - but at what proportion  ? You can use metagenome analysis to figure this out by comparing all reads against a reference database of a single copy marker gene (SCMG).  SCMGs are genes which are only found once in each genome but are required to make a functional cell.  The 16S rRNA gene is not actually a SCMG, as it is frequently found twice, three, or four times or more in bacterial genomes (about once per megabase of sequence).  My preferred marker gene is rpoB.  We'll use two reference fasta files, one from bacteria and one from archaea. You can download these from this github entry here (lets put them in a sub-directory so we don't clutter things up):

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

The proportion of bacteria is (2923/(2923+746))*100 = 79.7%.  This, of course, means that 20.3% of prokaryotic cells are Archaea.

While we are at it -- lets have some R-fun.  Try this:

```sh
wget https://github.com/bwawrik/MBIO5810/raw/master/R_scripts/bargraph_redgreen_scale.r
Rscript bargraph_redgreen_scale.r $(calc 3669*$(fgrep -o ">" bac_hit.fas | wc -l)/$(fgrep -o "+" SRX3577904_1.fastq | wc -l)*2) bac.png
Rscript bargraph_redgreen_scale.r $(calc 3669*$(fgrep -o ">" arc_hit.fas | wc -l)/$(fgrep -o "+" SRX3577904_1.fastq | wc -l)*2) arc.png
```
Take a look at the .png files that are produced. Extra points if you can figure out what happened here ;)

![bacteria vs archaea](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/BAC_ARC.png)


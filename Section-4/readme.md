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

To predict ORFs as nucleotide (fna) and amio acid (faa) sequences do the following with your Contigs.fna file:

```sh 
prodigal -d orfs.fna -a output/temp.orfs.faa -i pipeline_mg_contigs.fas -m -o output/tempt.txt -p meta -q
cut -f1 -d " " output/temp.orfs.fna > output/prodigal.orfs.fna
cut -f1 -d " " output/temp.orfs.faa > output/prodigal.orfs.faa
rm -f output/temp*
```

You can do this separately by just call the ' -d output/temp.orfs.fna' or '-a output/temp.orfs.faa' flags.  The last command removes the temporary files.

### FragGeneScan

- First you need to copy the model files to the local directory. (This is a workaround; I'm not sure why it doesn't work without copying these files; sorry !)

```sh 
mkdir Ftrain
cp /opt/local/software/FragGeneScan1.19/train/* Ftrain
```

- Now lets predict the ORFs

```sh 
FragGene_Scan -s VigP03RayK31Contigs.fasta -o output/VigP03RayK31.FragGeneScan -w 1 -t complete
```

- Clean up

```sh 
rm -rf Ftrain
```



### Finding rRNA and tRNA genes



### Pairwise Blast -- Genome-to-Genome Comparison


### KEGG Annotation -- and KEGG Mapping




### Assessing Genome Completeness


## Metagenome Gene Frequencies

### Proportion of Arachae to Bacteria

### What proportion of a population carries a particular Gene ?

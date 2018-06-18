# Bioinformatics-ARET-July2018
Bioinformatics ARET - BI for NSF GEO OCE grant # 1634630


# Why Bioinformatics ?

The past decade has seen a tremendous shift in the way biological science is conducted.  Many of the problems that are now routinely tackled as part of the average research project would have been insurmountable one a few short years ago.   Two fundamental advances have made this leap forward possible – new technolgoies for [DNA sequencing](https://en.wikipedia.org/wiki/DNA_sequencing) and raw rapid advances in computational horsepower allowing [computational biology](https://en.wikipedia.org/wiki/Computational_biology) problems to be solved without the use of a supercomputer.


 Arguably the most important aspect of biology data revolution has been the ability to sequence whole genomes.  While the first full genome sequence (that of [bacteriophage φX174]( https://en.wikipedia.org/wiki/Phi_X_174)) became available as early as 1977, the ability to sequence the complete genome of an organism remained out of reach for the average research project until very recent advances in DNA sequencing lowered the cost dramatically.  A series of technologies pushed the envelope in this area beyond the classical [dideoxy-Sanger sequencing]( https://en.wikipedia.org/wiki/Sanger_sequencing) methodology, lowering the cost from dollars to fractions of a penny per kilobase of sequence.
 
 
![Cost of Sequencing a Human Genome](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Historic_cost_of_sequencing_a_human_genome.svg/1200px-Historic_cost_of_sequencing_a_human_genome.svg.png)


The result, of course, is a tremendous amount of sequence data.  These data are historically deposited and made available to the public through the [National Center for Biotechnology Information]( https://www.ncbi.nlm.nih.gov/), which maintain [GenBank](https://www.ncbi.nlm.nih.gov/genbank/) our most important data repository.  As you can imagine, the [size of GenBank]( https://www.ncbi.nlm.nih.gov/genbank/statistics/) has increase dramatically over recent  years.

![Number of Bases in GenBank as Individual Reads or Whole Genome Sequences](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/GenBank_size.png)

Several specialty databases have sprung up over the years to handle portions of GenBank that are used by specialized research communities.  For example, if one studies the genome of teh rice plant, it may not be encessary to include bacterial genomes in a reference database.  We will be using one of these alternate repositories, [iMicrobe](https://www.imicrobe.us/), for this short-course (more on this in the activities).

# TOPICS

The topic of bioinformatics is vast.  We easily fill two to three college classes with just the basic material.  However, that does not mean you cannot acquire some basic skills that are very useful, even in the short amount of time available to us in this short-course.   Science is about the questions, and, believe it or now, you can ask some pretty sophisticated and cutting-edge questions with the tools that are available to you on your desktop using freely available data.  
Keep in mind that bioinformatics is like riding a bicycle.  One can not learn it form talking about it. The only way to learn requisite skills is to get your hands on some data.  We will therefore spend minimal time in a ‘lecture’ style environment.  We will provide ~20 minutes of context at the beginning of each section and then proceed to working with some real data.  Our hope is that every person can choose a dataset from the iMicrobe website and try to learn some basic facts about the sample.

The course will have four sections:

## Section 1:  Basic Sequence Handling, QC, and Sequence Assembly

The goal will be to learn how to download a sequence file from a repository, view it, and assess its quality statistics.  We will then test two assembly programs and choose one for whole genome assembly based on the statistics we generate.  The results from assembly will be uploaded to RAST. 

## Section 2:  16S Phylogenetic Analysis

We will learn how to make a robust species identification using DNA sequence data.  We will start with a bacterial genome and extract the full length 16S rRNA gene from it.  We will then use a web-tool to construct a phylogenetic tree.

## Section 3:  Microbiome Analysis

The phylogenetic analysis from Section 2 is not feasible when one has thousands of sequences.  You will learn how to analyze the composition of a complex microbiome.  We will start with a metagenome from iMicrobe.  We will then learn how to blast search the data for 16S containing reads and use microbiome software to assign identities.

## Section 4:  Genome Analysis

Hopefully, the RAST annotation is complete. It will allow us to look at functional capacity and metabolic mapping.  We will also learn some basic tools of the trade like predicting protein coding, rRNA, and tRNA genes.  From here we can get creative and might look the presence of specific functional genes or a pairwise genome comparison, if time allows.


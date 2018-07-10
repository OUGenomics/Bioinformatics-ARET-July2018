## Section 2: 16S Phylogenetic Analysis

In this exercise, we will learn how to make a robust species identification using DNA sequence data. We will start with a bacterial genome and extract the full length 16S rRNA gene from it. We will then use a web-tool to construct a phylogenetic tree.

The first thing you will need is a good reference dataset to compare your reads against.  The following downloads a slightly older version of the SILVA database.  I actually like this older file, because it is smaller and does not contain the bloat of next generation sequencing reads.  Its great for the purpose of read extraction. It is not the best for classification (Section 4).  

```sh
wget http://mgmic.oscer.ou.edu/sequence_data/ARET/Silva_108_rep_set.fasta.gz
gunzip *.gz
```

The most up to date SILVA files can be found on the SILVA homepage :

https://www.arb-silva.de/

Lets start by preparing our reference database from the SILVA file:

```sh
usearch -makeudb_usearch Silva_108_rep_set.fasta -output SILVA_108.udb
```

Now lets go to the SRA and find ourselves some data.   For this, you will need some data with decent read lengths.  Much of the SRA is unfortunately populated with very short HiSeq reads (<100 bp of usable data).   I prefer using MiSeq when sequencing a genome because the reads are 250-300 bp long.   

Conduct a search of the SRA with the following search terms:

- miseq
- genome
- bacterium

I'll show you how to find the average read length in class.  Lets pick this sample for the purpose of the exercise: SRX3577904
It is labeled as "Uncultivated genome  	Shewanella sp.". Lets see if we can confirm this.  Start by getting your data and trimming the reads.  Don't worry about trimming adapters.

```sh
fastq-dump -I --split-files SRX3577904 -X 400000

read_fastq -e base_33 -i SRX3577904_1.fastq | trim_seq -m 30 -l 8 --trim=right | write_fastq -o SRX3577904_1.q30.fastq -x
read_fastq -e base_33 -i SRX3577904_2.fastq | trim_seq -m 30 -l 8 --trim=right | write_fastq -o SRX3577904_2.q30.fastq -x

```

We will now use as search tool called 'usearch' to compare each of the reads to the SILVA reference data set.  About 1 in 1000 genes in a typical genome codes for a 16S rRNA gene.  We downloaded 400000 reads so we should expect about 400 hits.  That should be sufficient to assemble the complete 16S sequence, so we'll only need to run the forward reads (you'd get another 400 if you ran the reverse reads):

```sh
usearch -usearch_global SRX3577904_1.q30.fastq -db SILVA_108.udb -id 0.7 -strand both -mincols 50 -maxhits 1 -qsegout Fhits.fasta -blast6out Fhits.tab
```

The search will take a about 15 minutes on your typical desktop. After it completes, you'll need to do some text file parsing:

```sh
cut -d \t Fhits.tab -f2 | awk '{print $1}' > f_h.txt
grep -A 1 -f f_h.txt SRX3577904_1.fastq > f_h.fas
sed '/--/d' f_h.fas > f_h.fasta
```

I know this looks complicated.  Don't try to overthink these commands at this point.  They remove some extra lines and produce a fasta files that contains the reads that match something in SILVA.  The reads are then placed into a file called "f_h.fasta".

Of course, you remember how to run an assembly from exercise 1 ;) Lets use a shorter kmer here, because the reads are little shorter than I'd like after trimming.

```sh
Ray -k 15 -s f_h.fasta -o ray_SRX3577904_16S/
chmod 777 ray_SRX3577904_16S/
```

Now go into the assembly subfolder and find the Contigs.fasta file. Open it with wordpad (don't use notepad; it doesn't know how to wrap the text correctly for a linux text file).  The contents like something like this:

```sh
>contig-0 185 nucleotides
CGTGCGCTTTTCTCGGATTTTGCTAATGAAGCGATGTCGGGATGACTCATGATCTGGCAG
CTGAAAAAGTGTTGGCTAATTAGATCACATAATTAAAGAGATTGGTATAAACTGGCATGG
AAGGTAAGGGGGAATTTCGGACATAAAAAAACCTGCTTTAAGCAGGTTGTTTGGTACACC
CGAGT
>contig-1000000 117 nucleotides
AAGTGGCTCCCCTGACTGGATTCGAACCAGTGACATACGGATTAACAGTCCGCCGTTCTA
CCGACTGAACTACAGGGGAATTGAAATTTTCAGGGGGCAAAATCGAAGTGGCTCCCC
>contig-2000000 112 nucleotides
CTCGGGTGTACCACTATCTTCAGATTTTCAAAAAAATGAAAATCATGCGATACACCCGTA
GCTCAGCTGGTTAGAGCACTACCTTGACATGGTAGGGGTCGGTGGTTCGAGT
```

A 16S rRNA gene is about 1500 bp in length.  These are really crummy contigs... hmmmm... what could have happened ?  Lets sort it out using BLAST and the Ribosomal RNA Database Project.

### Using BLAST

Once you have retrieved your 16S contig you can typically get a rough idea what organism you are dealing with by ‘BLASTing” your sequence against the NCBI database.  We'll do this two ways.  We'll use a web-interface, and (later) I will show you how to set up your own blast database locally.  For now, we'll use the web-search. Go to the NCBI blast website:

https://blast.ncbi.nlm.nih.gov/Blast.cgi


Select the BLASTN function. This will open the Standard Nucleotide BLAST web-page.  Here, you will paste your fasta file.  Use only the longest contig that you got from your assemlby step.  It should be the top one in the Contigs.fasta file. Choose the ‘16S rRNA Sequences (Bacteria and Archaea)’ dataase and search and the default ‘highly similar sequences (megablast)’ program.  Click the “BLAST” button.  

You will be directed to a results window, where you will wait for your sequence to be ‘BLASTed’ against the entire nr database.  Once the search is finished, you will see an output that will include a visual of the top 100 BLAST hits.  Below that, you will see the ‘Descriptions’, which includes the Description of each of the top 100 sequences along with statistics of how well your sequence matched those listed.  Key parameters include the Max score, E value and the Identity (%).  You will also see an Accession number.  This link will take you to the GenBank record for the sequence that you choose.  This will contain information about the origin of the sequence that your sequence is very similar to. 

Did that happen for the SRX3577904 containing Shewanella data ? 

As an alternative search tool, lets try the seq-match function of the Ribosomal RNA Database Project :

https://rdp.cme.msu.edu/seqmatch/seqmatch_intro.jsp

Paste your sequence into the box and press submit.

![seq-match](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/seq_match.PNG)

What's your output ? Do you now understand why it failed ? What's the lesson ?

### Lets try one that works

In Section 1 we downloaded some data for an isolate (diox_f_50000.fastq and diox_r_50000.fastq).  If you did not, because you worked with your own data, go back to section 1 and run the wget and cutadapt commands.  Then use usearch to compare the reads to the SILVA database:

```sh
usearch -usearch_global diox_f_cutadapt.fastq -db SILVA_108.udb -id 0.7 -strand both -mincols 50 -maxhits 1 -qsegout Fhits.fasta -blast6out dFhits.tab
usearch -usearch_global diox_r_cutadapt.fastq -db SILVA_108.udb -id 0.7 -strand both -mincols 50 -maxhits 1 -qsegout Rhits.fasta -blast6out dRhits.tab
```

Good. Now do your file parsing:

```sh
cut -d \t dFhits.tab -f2 | awk '{print $1}' > df_h.txt
grep -A 1 -f df_h.txt diox_f_cutadapt.fastq > df_h.fas
sed '/--/d' df_h.fas > df_h.fasta


cut -d \t dRhits.tab -f2 | awk '{print $1}' > dr_h.txt
grep -A 1 -f dr_h.txt diox_r_cutadapt.fastq > dr_h.fas
sed '/--/d' dr_h.fas > dr_h.fasta
```


We combine the files into one like this:

```sh
cat dr_h.fasta df_h.fasta > 16S_diox_hits.fasta
```

Lastly, we assemble the reads as we did in exercise 1:

```sh
Ray -k 15 -s 16S_diox_hits.fasta -o ray_diox_16S/
chmod 777 ray_diox_16S/
```

Now go and open the ray_diox_16S/Contigs.fasta file.  There are three contigs, the largest of which is 2,200 base pairs.  Go back to the blastN page and blast your sequences.  You should get an output that looks something like this:

![blast output](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/blastN.PNG)

Good, you now have a great blast hit, but you'll notice that the red bar covers only part of your contig.  This happens because the reads run over the end of the gene.  16S rRNA genes are only ~1,500 base pairs, so you'll need to trim the edges for the next step.  Look at the alignment below, find the start and stop position and trim your sequence accordingly. Hint: text searchers really help.

![alignment](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/blast_alignment.PNG)

Your final 16S sequence should look something like this:

```sh
>contig-0 2231 nucleotides
CCGTCCCCCTTGCGGTTAGACTAG
CTACTTCTGGTGCAACCCACTCCCATGGTGTGACGGGCGGTGTGTACAAGGCCCGGGAAC
GTATTCACCGTGACATTCTGATTCACGATTACTAGCGATTCCGACTTCACGCAGTCGAGT
TGCAGACTGCGATCCGGACTACGATCGGTTTTATGGGATTAGCTCCACCTCGCGGCTTGG
CAACCCTTTGTACCGACCATTGTAGCACGTGTGTAGCCCTGGCCGTAAGGGCCATGATGA
CTTGACGTCATCCCCACCTTCCTCCGGTTTGTCACCGGCAGTCTCCTTAGAGTTCCCACC
ATAACGTGCTGGTAACTAAGGACAAGGGTTGCGCTCGTTACGGGACTTAACCCAACATCT
CACGACACGAGCTGACGACAGCCATGCAGCACCTGTGTCTGAGTTCCCGAAGGCACCAAT
CTATCTCTAGAAAGTTCTCAGCATGTCAAGGCCAGGTAAGGTTCTTCGCGTTGCTTCGAA
TTAAACCACATGCTCCACCGCTTGTGCGGGCCCCCGTCAATTCATTTGAGTTTTAACCTT
GCGGCCGTACTCCCCAGGCGGTCAACTTAATGCGTTAGCTGCGCCACTAAGAGTTCAAGA
CTCCCAACGGCTAGTTGACATCGTTTACGGCGTGGACTACCAGGGTATCTAATCCTGTTT
GCTCCCCACGCTTTCGCACCTCAGTGTCAGTATCAGTCCAGGTGGTCGCCTTCGCCACTG
GTGTTCCTTCCTATATCTACGCATTTCACCGCTACACAGGAAATTCCACCACCCTCTACC
GTACTCTAGCTTGCCAGTTTTGGATGCAGTTCCCAGGTTGAGCCCGGGGCTTTCACATCC
AACTTAACAAACCACCTACGCGCGCTTTACGCCCAGTAATTCCGATTAACGCTTGCACCC
TCTGTATTACCGCGGCTGCTGGCACAGAGTTAGCCGGTGCTTATTCTGTCGGTAACGTCA
AAATAGCAACGTATTAAGTTACTACCCTTCCTCCCAACTTAAAGTGCTTTACAATCCGAA
GACCTTCTTCACACACGCGGCATGGCTGGATCAGGCTTTCGCCCATTGTCCAATATTCCC
CACTGCTGCCTCCCGTAGGAGTCTGGACCGTGTCTCAGTTCCAGTGTGACTGATCATCCT
CTCAGACCAGTTACGGATCGTCGCCTTGGTGAGCCGTTACCTCACCAACTAGCTAATCCG
ACCTAGGCTCATCTAATGGCGCGAGGCCCGAAGGTCCCCCGCTTTCTCCCGTAGGACGTA
TGCGGTATTAGCGTCCGTTTCCGAACGTTATCCCCCACCACTAGGCAGATTCCTAGGCAT
TACTCACCCGTCCGCCGCTCTCAAGGGAAGCAAGCTCCCCTCTACCGCTCGACTTGCATG
TGTTAGGCCTGCCGCCAGCGTTCAATCTGAGCCATGATCAAACTC
```

Save this as a text file on your computer. You'll need this for the next step.

Lets go back to Seq-Match -- you'll see that this time, you get very confident identification of a pseudomonad.

![good match](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/seq_match_good.PNG)


### Phylogenetically informed analysis

Now that we have a quick an dirty look at the potential taxonomy of your single cell genome, we will want to do a more refined and comprehensive analysis of your isolate’s 16S rRNA sequence taxonomy and phylogeny.  For this, go to the homepage of the Ribosomal Database Project website:

http://rdp.cme.msu.edu


First, you will need to upload your sequence to RDP.  Do this by clicking on the “my RDP” icon in the upper right hand corner of the homepage.  Click on the “Test Drive” button on the next screen and you will have entered the myRDP portal as a guest.  Once on the “Overview” page, you will select the “upload” function and upload your sequence.  Choose the “Bacterial 16S rRNA” option and a project name that is consistent with your sequence name.  After uploading, it may take several minutes for your sequence to be aligned against the RDP aligned database. 

You will be directed (or can navigate to) the “overview” webpage.  You will see the status of your sequence.  Once it is aligned, select your sequence by clicking on it.  Choose (by clicking) the “View Classification” button on the right side of the page (just above the "List of Sequences" line).  This will bring you to the Classifier “Hierarchy View” page.  Here, you will see the hierarchy of the taxonomic identification of your sequence.  Click on the “show assignment detail for Root only” link.  This will take you to a page that will summarize the taxonomic hierarchy for your sequence.  Click on the “download fixrank result button. 

### Extracting Reference Sequences

At this point, you pretty much have a good idea of the taxonomy of your isolate.  We still want to determine how your isolate is phylogenetically related to other members of similar taxonomic groups.  To do this we will match our sequence against the whole database.  Select the “Seqmatch” link at the top of the page.  You should be directed to the Seqmatch – Start page, where you will click on the “Do Seqmatch with Selected Sequences” button. You will again see a Hierarchy View as the result, only this time you will see a “[view selectable matches]” link next to your sequence.  Click on it and you will see the top 20 sequence “hits” in the database. 


Choose the top 5 sequences based on the “S_ab score” by clicking in the corresponding box. Click back on the “Save selection and return to summary” button at the top of the page and you will be returned to the Seqmatch Summary page. 

Click on the “Seqcart” link at the top of the page and you should see that you now have your sequence “1 myRDP sequences” and 5 public sequences in your cart. 

At this point, we want to select several sequences at varying phylogenetic and taxonomic distances to the sequences that we have already selected.  Click on the 
“Browsers” link at the top of the page.  You will see that whatever group contains selected sequences will show a half-­‐red “plus” symbol. Click on the phylum NAME (not the + symbol) of the sequences you have already selected.  Scroll down the page to reveal the “Data Set Options”.  Select “Type” for Strain, only showing the type strains in the Browser.  Select up to 3 different species in the same genus of your sequence and up to 3 different genera in the same family.  Lastly, choose a sequence from a different phylum that can be used as an outgroup later in our phylogenetic tree. Make sure that you click on the “Seqcart” link after each selection to confirm that the sequences you want to select are indeed selected. 

Download the sequences that you have selected (by clicking on the “download” link at the top of the page).  Make sure that the number of myRDP and public sequences selected is what you expect to be selected. You will want to download the sequences as Fasta, unaligned. 

### Making an Alignment

Navigate to the EMBLEBI webpage for multiple sequence alignment programs:

https://www.ebi.ac.uk/Tools/msa/

We'll be using a program called MAFFT to align our sequnces.  Select the link for MAFFT and paste the sequences you retrieved from the RDP into the text box:

![use MAFFT](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/mafft.PNG)

The press the align button to perform the multiple sequence alignment. The output will be displayed, showing the multiple sequence alignment. Click on the Phylogenetic tree button.   You will be redirected to a Phylogeny page.  You will see the phylogenetic tree results. If you click on the “View Phylogenetic Tree File” button, a new window will open showing the text of the phylogenetic tree data (series of parentheses and your sequence accession numbers). Select all of this text, copy it and paste it in a text editor program.  Make sure you save it as plain text and give it the suffix “.tre”.  
If you go back to the web browser and scroll down the previous page, you will find the Phylogram data (phylogenetic tree), which can be shown using a java program.

![tree results](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/mafft_tree.PNG)

### Draw a Phylogenetic Tree 
There are many programs that are capable of drawing phylogenetic trees.  The most suitable, widely used and free program that does this is “FigTree”. http://tree.bio.ed.ac.uk/software/figtree/.  If we have time, we'll download and install this program.  
In the program FigTree, under File, Open, choose the phylogenetic tree file you saved from ClustalW2 that you gave the .tre suffix. Export your phylogenetic tree as a PDF file.   

### Running Alignments Locally

In many cases, you don't have the luxury of using a web interface, either because you want to automate things, or because your file is too big.  In that case, you can run MAFFT locally.  Place your sequences in the you /data folder into a file called rdp_results.fas.  The run:

```sh
sh /opt/local/software/mafft-linux64/mafft.bat rdp_results.fas > allign.fas
```
Allign.fas should contain the same alignment that the online portal generated for you.  Finally, you can generate the tree file with a program calle MUSCLE:

```sh
muscle -in alling.fas -tree1 tree.phy
```
You can view your tree file with cat:


```sh
cat tree.phy
```

or by importing it into FigTree.

Enjoy !




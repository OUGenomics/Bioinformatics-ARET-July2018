## Section 2: 16S Phylogenetic Analysis

In this exercise, we will learn how to make a robust species identification using DNA sequence data. We will start with a bacterial genome and extract the full length 16S rRNA gene from it. We will then use a web-tool to construct a phylogenetic tree.

The first thing you will need is a good reference dataset to compare your reads against.  The follwoing downloads a slightly older version of the SILVA database.  I actually like this older file, because it is smaller and does not contain the bloat of next generation sequencing reads.  Its great for the purpose of read extraction. It is not the best for classification (Section 4).  

wget http://mgmic.oscer.ou.edu/sequence_data/ARET/Silva_108_rep_set.fasta

The most up to date SILVA files can be found on the SILVA homepage :

https://www.arb-silva.de/

Lets start by preparing our reference database from the SILVA file:

```sh
usearch -makeudb_usearch Silva_108_rep_set.fasta -output SILVA_108.udb
```

Now lets go to the SRA and find ourselves some data.   For this, you will need some data with decent read lengths.  Much of the SRA is unfortunatelly populated with very short HiSeq reads (<100 bp of usable data).   I prefer using MiSeq when sequencing a genome becuase the reads are 250-300 bp long.  

Conduct a search of the SRA with the following search terms:

- miseq
- genome
- bacterium

I'll show you how to tind the average read length in class.  I picked this sample: SRX3577904

```sh
fastq-dump -I --split-files SRX3577904 -X 400000
```


usearch -usearch_global SRX3577904_1.fastq -db SILVA_108.udb -id 0.7 -strand both -mincols 50 -maxhits 1 -qsegout Fhits.fasta -blast6out Fhits.tab
usearch -usearch_global SRX3577904_2.fastq -db SILVA_108.udb -id 0.7 -strand both -mincols 50 -maxhits 1 -qsegout Rhits.fasta -blast6out Rhits.tab


cut -d \t Fhits.tab -f2 | awk '{print $1}' > f_h.txt
grep -A 1 -f f_h.txt SRX3973296_1.q30.fastq > f_h.fas
sed '/--/d' f_h.fas > f_h.fasta

cut -d \t Rhits.tab -f2 | awk '{print $1}' > r_h.txt
grep -A 1 -f r_h.txt SRX3973296_2.q30.fastq > r_h.fas
sed '/--/d' r_h.fas > r_h.fasta

cat r_h.fasta f_h.fasta > 16S_hits.fasta



Ray -k 15 -s 16S_hits.fasta -o ray_16S/





















### Download some data for a bacterial genome

Lets use the single cell genomics data we collected in Section 1.  The important thing is that this data is high-quality and does not contain any adapter sequences, so use the XX_cutadapt.q30.fastq files.

To reconstruct the full length 16S rRNA gene, we will use a program call Emirge:

https://github.com/csmiller/EMIRGE

Before we can use this software, we need to download a 16S database for reference.  I don't keep this in my docker file to prevent bloat of the file size. To build the index yourself, you will need to go into the EMIGE folder and run the download script:

```sh
cd /opt/local/software/EMIRGE
python emirge_makedb.py
```

This will download the SILVA_132_SSUREF_Nr99 files to your computer, which contain >600,000 reference 16S rRNA gene sequences.  It will then proceed to clustering and making a bowtie-index file.  Be patient. This takes over an hour on a typical PC, which is why I have done this for you, and I am sharing the output over my private server. Instead of running emirge_makedb.py, download them to the emirge folder:

```sh
cd /opt/local/software/EMIRGE
wget
```

Please keep in mind that I may delete these files at some point in the future.  In that case you will need to run the makedb file.  You can preserve the ouput by copying the files to you /data folder.  That way they will not be lost when you shut your docker down.  Alternatively  you can use docke commit (see instructions to docker).










### Using BLAST

Once you have retrieved a full length 16S sequence you can quickly get a rough idea what orgnanism you are dealing with by ‘BLASTing” your sequence against the NCBI database.  We'll do this two ways.  We'll use a web-interface, and I will show you how to set up your own blast database locally.  For the web-search, go to the NCBI blast website:

https://blast.ncbi.nlm.nih.gov/Blast.cgi


Select the BLASTN function. This will open the Standard Nucleotide BLAST web-page.  Here, you will paste your fasta file, choose the ‘16S rRNA Sequences (Bacteria and Archaea)’ dataase and search and the default ‘highly similar sequences (megablast)’ program.  Click the “BLAST” button.  

You will be directed to a results window, where you will wait for your sequence to be ‘BLASTed’ against the entire nr database.  Once the search is finished, you will see an output that will include a visual of the top 100 BLAST hits.  Below that, you will see the ‘Descriptions’, which includes the Description of each of the top 100 sequences along with statistics of how well your sequence matched those listed.  Key parameters include the Max score, E value and the Identity (%).  You will also see an Accession number.  This link will take you to the GenBank record for the sequence that you choose.  This will contain information about the origin of the sequence that your sequence is very similar to. 






### Phhylogenetically informed analysis

Now that we have a quick an dirty look at the potential taxonomy of your single cell genome, we will want to do a more refined and comprehensive analysis of your isolate’s 16S rRNA sequence taxonomy and phylogeny.  The Ribosomal Database Project website:

http://rdp.cme.msu.edu


First, you will need to upload your sequence to RDP.  Do this by clicking on the “my RDP” icon in the upper right hand corner of the homepage.  Click on the “Test Drive” button on the next screen and you will have entered the myRDP portal as a guest.  Once on the “Overview” page, you will select the “upload” function and upload your sequence.  Choose the “Bacterial 16S rRNA” option, give it the group name 
“MBIO4873” and a project name that is consistent with your sequence name.  After uploading, it may take several minutes for your sequence to be aligned against the RDP aligned database. 

You will be directed (or can navigate to) the “overview” webpage.  You will see the status of your sequence.  Once it is aligned, select your sequence by clicking on it.  Choose (by clicking) the “Classifier” at the top of the page.  This will bring you to the Classifier page. Select the “Do classification with Selected Sequences” button. You will be directed to the Classifier “Hierarchy View” page.  Here, you will see the hierarchy of the taxonomic identification of your sequence.  Click on the “show assignment detail for Root only” link.  This will take you to a page that will summarize the taxonomic hierarchy for your sequence.  Click on the “download fixrank result button. 


### Extracting Reference Sequences

At this point, you pretty much have a good idea of the taxonomy of your isolate.  We still want to determine how your isolate is phylogenetically related to other members of similar taxonomic groups.  To do this we will match our sequence against the whole database.  Select the “Seqmatch” link at the top of the page.  You should be directed to the Seqmatch – Start page, where you will click on the “Do Seqmatch with Selected Sequences” button. You will again see a Hierarchy View as the result, only this time you will see a “[view selectable matches]” link next to your sequence.  Click on it and you will see the top 20 sequence “hits” in the database. 


Choose the top 5 sequences based on the “S_ab score” by clicking in the corresponding box. Click back on the “Save selection and return to summary” button at the top of the page and you will be returned to the Seqmatch Summary page. 

Click on the “Seqcart” link at the top of the page and you should see that you now have your sequence “1 myRDP sequences” and 5 public sequences in your cart. 

At this point, we want to select several sequences at varying phylogenetic and taxonomic distances to the sequences that we have already selected.  Click on the 
“Browsers” link at the top of the page.  You will see that whatever group contains selected sequences will show a half-­‐red “plus” symbol. Click on the phylum NAME (not the + symbol) of the sequences you have already selected.  Scroll down the page to reveal the “Data Set Options”.  Select “Type” for Strain, only showing the type strains in the Browser.  Select up to 3 different species in the same genus of your sequence and up to 3 different genera in the same family.  Lastly, choose a sequence from a different phylum that can be used as an outgroup later in our phylogenetic tree. Make sure that you click on the “Seqcart” link after each selection to confirm that the sequences you want to select are indeed selected. 

Download the sequences that you have selected (by clicking on the “download” link at the top of the page).  Make sure that the number of myRDP and public sequences selected is what you expect to be selected. You will want to download the sequences as Fasta, unaligned and Jukes Cantor corrected. 

### Making an Allignment


Navigate to the EMBL-­‐EBI webpage for the program CLUSTALW2, a general purpose multiple sequence alignment program for DNA or proteins 
(http://www.ebi.ac.uk/Tools/msa/clustalw2/). Upload your fasta file that contains your sequence and those selected from RDP. Accept all of the default settings and click on the “Submit” button to perform the multiple sequence alignment. The output will be displayed, showing the multiple sequence alignment. Click on the 
“Send to ClustalW2_Phylogeny” button. Accept all of the default settings on the next page and click the “Submit” button. 

You will be redirected to a Phylogeny page.  You will see the phylogenetic tree results. If you click on the “View Phylogenetic Tree File” button, a new window will open showing the text of the phylogenetic tree data (series of parentheses and your sequence accession numbers). Select all of this text, copy it and paste it in a text editor program.  Make sure you save it as plain text and give it the suffix “.tre”.  
If you go back to the web browser and scroll down the previous page, you will find the Phylogram data (phylogenetic tree), which can be shown using a java program.


### Draw a Phylogenetic Tree 
There are many programs that are capable of drawing phylogenetic trees.  The most suitable, widely used and free program that does this is “FigTree” 
http://tree.bio.ed.ac.uk/software/figtree/.  Download and install this program.  

In the program FigTree, under File, Open, choose the phylogenetic tree file you saved from ClustalW2 that you gave the .tre suffix. Export your phylogenetic tree as a PDF file.   


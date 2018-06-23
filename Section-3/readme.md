## Section 3: Microbiome Analysis



## Identifying and Downloading a Sequence File

Today, we'll use a different data repostiory.  The SRA is the largest and most widely used repository, but there are others. We'll try the [iMicrobe website](https://www.imicrobe.us/) for today's exercises. Choose browse to look at the different data sets that are available:

![choose browse on imicrobe](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/imicrobe_home.PNG)

For the purpose of this exercise, we will find some data for from an environmental metagenome.  Browse the data [by project](https://www.imicrobe.us/#projects).  

I'm going to choose one of the arctic samples - just because that's cool:

https://www.imicrobe.us/#/samples/71

Clicking through to the samples I can find the data file.  A link to the reads can be found here:

https://de.cyverse.org/anon-files//iplant/home/shared/imicrobe/projects/4/samples/71/CAM_SMPL_SRA022063.fa

Everyone should find their own dataset to work on.  Idenfity the link to the reads and download the data using wget. In my case:

```sh
wget https://de.cyverse.org/anon-files//iplant/home/shared/imicrobe/projects/4/samples/71/CAM_SMPL_SRA022063.fa
```
We'll also need a SILVA reference dataset.  Lets grab one from my server and make a usearch database:

- Download the SILVA 111 database of known 16S rRNA genes

```sh 
wget http://mgmic.oscer.ou.edu/sequence_data/tutorials/SSURef_111_candidate_db.fasta
```
- Prepare 16S database for searching by creating a UDB datase as follows
```sh 
usearch -makeudb_usearch SSURef_111_candidate_db.fasta -output SSURef_111_candidate_db.udb
```

If you are using a dataset that is in fastq format, you'll need to convert the data to fasta:
```sh
read_fastq -i filename.fastq | write_fasta -o filename.fasta -x
```

As in Section 2, we now run a search of all the reads against the SILVA reference file.  It might be useful to limit yourself to 100k reads so the search can be completed in a reasonable time frame for this class -- this depends somewhat on the size of the metagenome you picked.  I picked a fairly large one for my example:

```sh
usearch -usearch_global CAM_SMPL_SRA022063.fa -db SSURef_111_candidate_db.udb -id 0.7 -fastapairs COM_SMPL_Fhits.fasta -strand both
```
You will also need to process the file.  We'll have to do it slighlty differently, because I am using a fasta instead of a fastq file. You'll need to grap a perl script and run several shell commands:

```sh
wget https://github.com/bwawrik/MBIO5810/raw/master/perl_scripts/parse_hits.pl
perl parse_hits.pl COM_SMPL_Fhits.fasta HITS.fasta
grep -A 1 -f HITS.fasta.tags CAM_SMPL_SRA022063.fa > h.fas
sed '/--/d' h.fas > MG_16_seqs.fasta
```

The file "h.fasta" contains your 16S reads, this time not from an isolate but rather from an community.  Lets take this to the RDP classifier to get a rough idea what we have in the file:

![rdp classifier community](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/rdp_classifier_community.PNG)

Looks like some proteobacteri, some actinobacteria, and lots of unknown things. Awesome (!), but it is a very unsophisticated way of solving the problem. Next I'll show you how a microbiome is analyzed using a software suite called Qiime.

### Installing the SILVA Database for use with Qiime

You'll need a more complete verison of the Silva111 database than we have been using so far.  Lets downlaod version 111 and install it into your data drive:
 
```sh
mkdir -p /data/DATABASES/16S
cd /data/DATABASES/16S
wget http://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_111_release.tgz
tar -xvf Silva_111_release.tgz
cd Silva_111_post/rep_set_aligned
gunzip *
cd ..
cd rep_set
gunzip *
```

Do you understand what happened here ?

Now exit bwawrik/bioinformatics by typing

```sh
exit
```
This should return you to the windows powershell prompt.  Sometimes you might have to type exit more than once.

### Running Qiime

To run Qiime, the first thing you will need to do is exit the bioinformatics docker.  For qiime, you'll need a second container. Qiime is not packaged into the bioinformatics container because it uses some older versions of certain dependencies, making some of the software incompatible without constant version maintenance.  Pull my qiime docker:

```sh
docker pull bwawrik/qiime:latest
```
... and fire it up:

```so
docker run -t -i -v c:/docker_data/data/:/data bwawrik/qiime:latest
```
 
You will need a few other filed.  First, you need a barcodes file.  This file contains unique tags that can be added to the sequences in a file.  That way we can catenate multiple files later (each tagged with a different barcode) and analyze them together.  The add_tag.pl script is a little perl magic that actually does the tagging.  Lastly, you'll need a quime configureation file call qiime_default.par.

```sh
cd /data
wget https://github.com/OUGenomics/Bioinformatics-ARET-July2018/raw/master/sample_seqs/barcodes.txt
wget https://github.com/OUGenomics/Bioinformatics-ARET-July2018/raw/master/sample_seqs/add_tag.pl
wget https://github.com/OUGenomics/Bioinformatics-ARET-July2018/raw/master/sample_seqs/qiime_default.par
```
Remember, you can look at any of these file by simply typing:
```sh
cat filename
```
View the first 10 lines with:

```sh
head -n 10 filename
```

### Adding Barcodes

Add a barcode from the barcodes.txt file.  We will make a list on the board. Each person is using a different metagenome. I want each person to use a differnt tag so we can analyze things together later.  I will use tag 3 in this example:

```sh
perl add_tag.pl 3 MG_16_seqs.fasta
```
This script will prduce a map file.  Open it with nano to inspect it.  Adding more lines here will let you combine samples.
Lets make sure its a valid map file:

```sh
validate_mapping_file.py -m MG_16_seqs.map -o mg_mapping
```

- Split libraries

```sh
split_libraries.py -f MG_16_seqsATCACCAGGTGT.fasta -m MG_16_seqs.map -o mg_processed_seqs/ --barcode_type 12
```
Look at the histogram and stats:

```sh
cat mg_processed_seqs/histograms.txt
cat mg_processed_seqs/split_library_log.txt
```
What do these files tell you ?

Validate the fasta file

```sh
validate_demultiplexed_fasta.py -i mg_processed_seqs/seqs.fna -m  MG_16_seqs.map
cat seqs.fna_report.log
```

- Lets pick our OTUs and assign taxonomy via closed reference picking
note: closed reference is necessary, because reads don't overlap;
 
```sh
pick_closed_reference_otus.py -i mg_processed_seqs/seqs.fna -o mg_OTUs -r /data/DATABASES/16S/Silva_111_post/rep_set/97_Silva_111_rep_set.fasta  -t /data/DATABASES/16S/Silva_111_post/taxonomy/97_Silva_111_taxa_map_RDP_6_levels.txt -f
```

- Inspect the BIOM file

```sh
biom summarize-table -i mg_OTUs/otu_table.biom
```
 
- Make a pie chart

```sh
summarize_taxa_through_plots.py -i mg_OTUs/otu_table.biom -o mg_taxplots -m  ssu_hits_corrected.map -p qiime_default.par -f
```

- The parameters file contains one line:

```sh
plot_taxa_summary:chart_type bar
```

- If you would like to make a pie chart instead, edit the the parameters file with nano to:

```sh
plot_taxa_summary:chart_type pie
```



## Lunchtime Assignment

Run an assembly of your metagenome over lunch.  This can take a while and we'll need the data for section 4.  Remember to make a small subset of the data and then run a few assmelies at different kmers to see which is best. If we are short on time, just use 25. For example:


```sh
Ray -k 25 -n 4 -minimum-contig-length 500 -s CAM_SMPL_SRA022063.fa -o CAM_SMPL_SRA022063_k25/
```








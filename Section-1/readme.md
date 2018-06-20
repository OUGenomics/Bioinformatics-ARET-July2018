## Section 1: Basic Sequence Handling, QC, and Sequence Assembly

### Downloading and launching a docker file

Lests start by getting all the bioinforamtics software you'll need.  Open your powershell and enter:

```sh
docker pull bwawrik/bioinformatics:latest
```

This pulls my bioinformatics docker.  It may take a few minutes since the docker is over six gigabytes in size.

You will also need a data directory to work in.  Powershell should open in your home directory, but just in case, go to your home directory by typing:

```sh
cd ~
```

Now create a data directory.  You can give it any name you wish; just keep track:

```sh
mkdir /docker_data/data/
```

Start your docker by typing:

```sh
cd /docker_data/data
docker run -t -i -v c:/docker_data/data/:/data bwawrik/bioinformatics:latest
```

Congratulations!! You are now running my bioinformatics docker! Perform all your analyses in the `/data` directory. When you exit the docker your files will be in `~/data` and accesible to windows.

```sh
NOTE: IF YOU ARE HAVING A PERMISSION ERROR AT THIS STAGE -- HERE IS HOW TO FIX IT:
http://peterjohnlightfoot.com/docker-for-windows-on-hyper-v-fix-the-host-volume-sharing-issue/
```

Now lets find ourselves some data.  For this we will need to go to the NCBI short read archive:

https://www.ncbi.nlm.nih.gov/sra

Select the advanced search:

![SRA search](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/sra_advanced_search_Step_1.PNG)

Lets search for some single cell genomics data from the oceans by using the search terms 'single amplified genome', and 'marine':

![search advanced](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/sra_search_step_2.PNG)

This will give us some options.  I will select entry 13 for demonstration, but for the purpose of the exercise, I'd like everyone to pick a different one.

[Genome sequencing of marine microorganism: single cell AG-341-O18](https://www.ncbi.nlm.nih.gov/sra/SRX3972923[accn])
1 ILLUMINA (NextSeq 500) run: 4.8M spots, 1.3G bases, 650.8Mb downloads
Accession: SRX3972923

Some other data sets from the same project can be found here:

https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=SRP141175

Using the NCBI website is far form intuitive, so don't get discouraged.  Even I will frequenlt scratch my head why the site just sent me in circles ! Be pateint, and you'll find what you need.

In order to download data, you will need to use fastq-dump:
https://ncbi.github.io/sra-tools/fastq-dump.html

For example:

```sh
fastq-dump -I --split-files SRX3973296 --gzip -X 400000
```
Where SRX3973296 represents the accession number of the data set we are trying to download.  Be carefull ! A RUN may contain several EXPERIMENTS and a BIOSAMPLE or BIOPROJECT may contain several RUNS, so you could end up pullin a lot of data. In this case, we are using the -X flag to give ourselves about 400000 paired reads to work with.  

the "--gzip" portion of the command means that the file will be downloaded in compressed format.  

Check your folder contents:

```sh
ls
```

You should get an output something like this:

```sh
SRX3973296_1.fastq.gz SRX3973296_2.fastq.gz
```

Lets uncompress the files:

```sh
gunzip *.gz
```
Your direcotry content should now be this:

```sh
SRX3973296_1.fastq SRX3973296_2.fastq
```
## ASSESSING THE QUALITY OF THE DATA

First, lets run the QC profiler FASTQC on your data:

```sh
fastqc SRX3973296_1.fastq 
fastqc SRX3973296_2.fastq
```

This should create two HTML files you can view in firefox by locating your data/ directory with you web browser. I will dicuss the outbput in class, but here is an example of the qScore and adapter plots:

![qscore](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/SRX3973273_1_per_base_quality.png)

![adapters](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/SRX3973273_1_adapter_content.png)


As you can see, there are no illumina adapters in the data -- good, they did a good job removing them.  However, there is a fair amount of data that is below a threshold of Q30.  We will remove this from the data befor proceeding.


If your data does not contain any illumina adapter contamination, download my two example data files, run fastqc on them and view the output:


```sh
wget https://github.com/OUGenomics/Bioinformatics-ARET-July2018/raw/master/sample_seqs/diox_f_50000.fastq
wget https://github.com/OUGenomics/Bioinformatics-ARET-July2018/raw/master/sample_seqs/diox_r_50000.fastq
fastqc diox_f_50000.fastq
fastqc diox_r_50000.fastq
```

Wiew the data in your web browser.  As you can see, there is significant Illumina adapater contamination in this data set.

!(trueseq contamination)[https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/trueseq_adapter_contamination.PNG]

## REMOVING ILLUMINA ADAPTERS (IF PRESENT)

OK, lests clean some of this data up. 



## RUNNING ASSEMBLIES

Lets benchmark two different assembly programs with your data to decide which one we should use.  First, make a small sub-set of your data that contains about 10% of the reads.

```sh
head f.fastq -n 80000 > fs.fastq
head r.fastq -n 80000 > rs.fastq
```
This should give you about 40,000 paired reads. These are partial files to allow the assembly to complete in a reasonable amount of time. Together the files contain about 5*10^6 bp of sequence, which is about 1x coverage of a typical bacerial genome.  For a good assmebly of a whole genome, you would typically aim for 100-200X coverage, but even 50X will yield a decent assembly.

### Ray Assembly

*Brief [description](http://denovoassembler.sourceforge.net/index.html) of Ray:*

> Ray is a parallel software that computes de novo genome assemblies with next-generation sequencing data.  Ray is written in C++ and can run in parallel on numerous interconnected computers using the message-passing interface (MPI) standard.

Run a [Ray](http://denovoassembler.sourceforge.net/manual.html) assembly with a [k-mer](https://en.wikipedia.org/wiki/K-mer) setting of 31 as follows
  
```sh
Ray -k31 -n 4 -p fs.fastq rs.fastq -o ray_31/
```

If you want to do this with multiple cores, control the number of cores with the -n flag (this will depend on how many cores you have assigned using docker).

NOTE: If you are having trouble seeing the contents of teh ray output folder in your web browswer you need to give permission:

```sh
chmod 777 ray_31/
```


### Velvet Assembly

*Brief [description](https://www.ebi.ac.uk/~zerbino/velvet/) of Velvet:*

>Velvet is a de novo genomic assembler specially designed for short read sequencing technologies, such as Solexa or 454, developed by Daniel Zerbino and Ewan Birney at the European Bioinformatics Institute (EMBL-EBI), near Cambridge, in the United Kingdom.  Velvet currently takes in short read sequences, removes errors then produces high quality unique contigs. It then uses paired-end read and long read information, when available, to retrieve the repeated areas between contigs.

Let's try a [Velvet](https://www.ebi.ac.uk/~zerbino/velvet/) assembly.

```sh
velveth velvet/ 31 -shortPaired -fastq -separate fs.fastq rs.fastq
velvetg velvet/
```

Download the [N50](https://en.wikipedia.org/wiki/N50_statistic) perl script
 
```sh
wget https://github.com/bwawrik/MBIO5810/raw/master/perl_scripts/N50.pl
```

Then assess the N50 stats on both assemblies.

```sh
perl N50.pl velvet/contigs.fa
perl N50.pl ray_31/Contigs.fasta
```

### Self-Examination
Which assembly is faster ? Which assembly is better ? Why ?




### Now Lets assemble a larger portion of your data



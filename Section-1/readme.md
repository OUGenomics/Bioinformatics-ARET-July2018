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
mkdir ~/data
```

Start your docker by typing:

```sh
docker run -t -i -v ~/data:/data bwawrik/bioinformatics:latest
```

Congratulations!! You are now running my bioinformatics docker! Perform all your analyses in the `/data` directory. When you exit the docker your files will be in `~/data` and accesible to windows.

-
NOTE: IF YOU ARE HAVING A PERMISSION ERROR AT THIS STAGE -- HERE IS HOW TO FIX IT:
http://peterjohnlightfoot.com/docker-for-windows-on-hyper-v-fix-the-host-volume-sharing-issue/
-

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
fastq-dump -I --split-files SRR7041300
```
Where SRR7041300 represents the accession number of the data set we are trying to download.

![]()

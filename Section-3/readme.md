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


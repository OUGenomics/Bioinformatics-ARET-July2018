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


## Identifying and Downloading a Sequence File

Let go to the [iMicrobe website](https://www.imicrobe.us/). Choose browse to look at the different data sets that are available:


















download a sequence file from a repository, view it, and assess its quality statistics. We will then test two assembly programs and choose one for whole genome assembly based on the statistics we generate. The results from assembly will be uploaded to RAST.

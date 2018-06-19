## Prerequisites


### Installing Docker

First things first.  In all liklyhood you do not own a computer that runs linux - at least not in the way that we will need to use it in this course.  You first order of business is to install docker. Before you can do this, you need to create an account on dockerhub:

https://hub.docker.com/

Fill choose a user name and create an account:
![creating a docker acccount ](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/docker_create_account.PNG)

Don’t forget to accept the privacy policy and terms of service.  Once you create your account, follow the instructions in the email that will be sent to you to finish the account setup.  

Then navigate to the homepage for the Windows installation, which can be found here:

https://docs.docker.com/docker-for-windows/install/

You will be asked to to log into your account before you can download the installer.

![login first](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/docker_login_before_Download.PNG)

Once you are logged in, download the stable windows client:

![stable client](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/docker_download_Windos_Stable.PNG)

Save the file. Then locate it, double click it, and follow the instructions for installation.  This may take a while.  For a new installation it may require windows to install a range of dependencies.   After your installation, docker will start automatically, but upon rebooting, you’ll likely have to restart docker before you can use it.  If it auto-starts, I would unselect this option, since docker will use resources in the background.   To start docker, find the docker icon and double click:

![start docker](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/docker_icon.PNG)

Once docker is started (this can take a minute or two; be patient), you'll need to open a powershell window.  I pin my powershell icon to the taskbar. If you don't know where to find it, click the windows icon and type 'powershell' into the search bar:

![find powershell](https://github.com/OUGenomics/Bioinformatics-ARET-July2018/blob/master/images/finding_powershell.png)

Test your docker installation by typing:

```sh
docker run hello-world
```

This will confirm that docker is installed correctly.  You should get this output:

```sh
PS C:\Users\your_user_name> docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/

PS C:\Users\your_user_name>
```

Now follow the instruction and launch an unbuntu linux container.  

$ docker pull ubuntu
$ docker run -it ubuntu bash

### GENERAL LINUX TUTORIALS

http://www.ee.surrey.ac.uk/Teaching/Unix/

### SOFTWARE CARPENTRY UNIX TUTORIALS

http://swcarpentry.github.io/shell-novice/


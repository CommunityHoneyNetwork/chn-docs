Deploying More Honeypots
=============================

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, require the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

**Please ensure the user on the system installing the honeypot is in the local
 docker group**
 
 Please see your system documentation for adding a user to the docker group.

## Deploying More Honeypots

Currently the following Honeypots are supported with CHN:

* [Cowrie](cowrie.md)
* [Dionaea](dionaea.md)
* [Glastopf](glastopf.md)
* [Wordpot](wordpot.md)
* [Conpot](conpot.md)
* [Amun](amun.md)
* [RDPHoney](rdphoney.md)

The general deployment model is the same for each of these:
* Select the deploy script you wish to deploy via the web interface
* Paste the "Deploy Command" into a VM host *with Docker installed already* 
* Verify installation succeded by examing the command line output and 
checking the view sensor page on CHN Server

## Customizing your deployments

To customize your deployment of a particular honeypot, you can copy an 
existing deployment script, change the drop down script selection option to 
"New Script", and paste into the script space. You can then create a new 
name, add notes, and save your new script.

You can then edit and re-save the script as desired. Some examples of items 
you might want to change include:

* Changing the listening port in the docker-compose.yml file
* Customizing options in the sysconfig file
* Addition additional code to ease deployment such as installing 
docker-compose and adding the local user to the docker group

**Please Note** that you should generally not change the ports in the 
sysconfig files, but rather change the ports that Docker translates 
connects to (i.e., in the )

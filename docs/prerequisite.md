# Prerequisites

Basic understanding of logging in to a systems console, and root access are
both necessary for installation

## Docker & Docker-Compose

The default deployment model uses Docker and Docker Compose to deploy
containers for the project's tools, and so, require the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

```
$ sudo apt install docker docker-compose
$ sudo systemctl enable docker
$ sudo systemctl start docker
```

## Certificate Strategy

Decide on what type of certificates you are going to use for your CHN Server
interface.  More information on these choices can be found
[here](https://communityhoneynetwork.readthedocs.io/en/stable/certificates/)

## Quickstart Repository

For the quickstart tutorial, you'll need to install a git client, and check out with repository:

```
$ sudo apt install git
$ git clone https://github.com/CommunityHoneyNetwork/chn-quickstart.git
```

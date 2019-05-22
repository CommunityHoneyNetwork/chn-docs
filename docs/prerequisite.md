# Prerequisites

Basic understanding of logging in to a systems console, and root access are
both necessary for installation

## Docker & Docker-Compose

CHN relies heavily on both Docker and Docker-compose.  Some introductory guides
to get you familiar with these technologies are linked below:

[Docker Getting Started](https://docs.docker.com/get-started/)

[Docker Compose Overview](https://docs.docker.com/compose/overview/)

The default deployment model uses Docker and Docker Compose to deploy
containers for the project's tools, and so, require the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

### Ubuntu Installation

```
$ sudo apt install docker docker-compose
$ sudo systemctl enable docker
$ sudo systemctl start docker
```

### RHEL/CentOS Installation

Ensure that you have the EPEL repository available.  Instructions on how to
enable this can be found [here](https://fedoraproject.org/wiki/EPEL)

```
$ sudo yum install docker docker-compose
$ sudo systemctl enable docker
$ sudo systemctl start docker
```

### OSX Installation

Ensure that Homebrew is installed.  Homebrew installation information can be
found [here](https://brew.sh/)

```
$ brew install docker docker-compose
```

Note that on Linux, you will need some escalated privileges to run docker.
This may include having rights to run `$ sudo docker`, or being a part of the
`docker` group.



## Certificate Strategy

Decide on what type of certificates you are going to use for your CHN Server
interface.  More information on these choices can be found
[here](https://communityhoneynetwork.readthedocs.io/en/stable/certificates/)

## Network Connectivity

When using the CERTBOT Certificate strategy, your CHN server will need to have
port 80 open and reachable by the world.  This is required by the ACME protocol
in order to verify your domain.

If you are deploying honeypots to networks beyond the network that your CHN
server lives on, you will need to be sure that the honeypots can reach back to
the CHN server on ports 80, 443, and 10000.

## Quickstart Repository

For the quickstart tutorial, you'll need to install a git client, and check out with repository:

```
$ sudo apt install git
$ git clone https://github.com/CommunityHoneyNetwork/chn-quickstart.git
```

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
* Python 3
* Pip 3

Please note that you will have a more stable experience by installing docker-compose and docker from your 
distributions repos, rather than downloading docker directly from Docker. Direct downloads from Docker *do* tend to 
have more features, but those features often come at the price of unresolved bugs. 

__Note:__ On Linux, you will need some escalated privileges to run docker.
This may include having rights to run `$ sudo docker-compose`, or your user being a part of the
`docker` group.

### Ubuntu Installation

```
$ sudo apt install docker docker-compose python3 python3-pip
$ sudo systemctl enable docker
$ sudo systemctl start docker
```

### RHEL/CentOS Installation

Ensure that you have the EPEL repository available.  Instructions on how to
enable this can be found [here](https://fedoraproject.org/wiki/EPEL)
You may need to specify whether you want python3.4 or python3.6. Where possible, use python3.6 or newer.
```
$ sudo yum install docker docker-compose python3 python3-pip
$ sudo systemctl enable docker
$ sudo systemctl start docker
```

### OSX Installation

Ensure that Homebrew is installed.  Homebrew installation information can be
found [here](https://brew.sh/)

```
$ brew install docker docker-compose
```

## Considerations when using Docker

Since Docker can introduce some interesting capabilities, organizations will choose different ways for
 implementing docker on hosts, and restricting what users can run docker commands. This documentation will not always
 assume that you are running as the _root_ user, but will assume you can run sudo commands, and that your current
 user is in the _docker_ group that, in default installations, is required for users to run docker commands. This
 guide cannot account for all possible combinations, so we default to a model of "you've spun up an Ubuntu VM in
 AWS with full network access and have full administrative priveleges". YMMV. :)
 
## Certificate Strategy

Decide on what type of certificates you are going to use for your CHN Server
interface.  More information on these choices can be found
[here](https://communityhoneynetwork.readthedocs.io/en/stable/certificates/)

The Certificate Strategy section is not relevant to honeypot pre-requisites and you can skip to the [network prerequisites](#network-connectivity)

### CERTBOT ###
There are advantages to each strategy that you should keep in mind.

The `CERTBOT` method will give you a valid certificate trusted by browsers, with no intervention on your part. This
 is the default strategy for the CHN project, but it does have some pre-requisites:

* The CHN Fully Qualified Domain Name (FQDN) must be publicly resolvable
* Public IP address, associated with the FQDN, must be reachable by Let's Encrypt on TCP port 80

The Let's Encrypt service must be able to resolve the domain name you're using in order to issue a certificate for
 that domain.

Part of the process for obtaining a certificate from Let's Encrypt requires that the CHN server provide the answer to
 a cryptographic challenge via a temporary web server on port 80. If the Let's Encrypt servers cannot reach the CHN
 server on port 80, this process will fail and the CHN server will restart until it is successful.

### BYO ###
If you can obtain your own validated certificate, you are welcome to use it with CHN. Adding your own certificate is
 as simple as naming your public certificate `cert.pem` and your private certificate `key.pem`, then volume mounting
  a directory containing these files to the `/tls` directory inside the container. See [here](https://communityhoneynetwork.readthedocs.io/en/stable/certificates/) for more information on this process.
  
Bringing your own certificate lets you leverage your existing certificate provider. Just like with Let's Encrypt
, if there's any issue with the CHN server reading and using the certificate you provide, the server will restart in
 a loop.
 
### SELFSIGNED ###
The CHN Server can create it's own, self-signed, certificate for use with the CHN server. This is the least desirable
 option, as browsers will give warnings on every inital load of the web interface. Additionally, the deployment
 commands, which leverage the command line utility `wget` will error when using a self-signed certificate. Users
 will need to add `--no-check-certificate` to these deployment commands in order to successfully pull the deployment
  script.
   
## Network Connectivity

When using the CERTBOT Certificate strategy, your CHN server will need to have
port 80/tcp open and reachable by the world.  This is required by the ACME protocol
in order to verify your domain. Once you have successfully received a certificate, port 80/tcp is no longer required
 to be available.

In order for honeypots to register with the CHN server, the CHN server must be accessible on 443/tcp. We do not
 recommend using the `http` scheme for deploying honeypots, though it is possible. If you do choose to use `http` for
  deployments, then port 80/tcp must be available. 

Honeypots need to access either 80/tcp or 443/tcp on the CHN Server during the registration process, but always need port
 10000/tcp accessible in order to send data to the central server.

## Quickstart Repository

To make use of the quickstart method for CHN Server deployment, you'll need to install a git client, and check out the
 [quickstart repository](serverinstall.md#deploying-the-server-the-quickstart-way).

The Quickstart method requires an additional python module not typically required, validators. Please install if using:

```bash
sudo apt install git
pip3 install validators
```

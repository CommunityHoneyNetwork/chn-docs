Conpot Honeypot
===============

!!! note "Note"
    Conpot is currently in alpha. This honeypot has been verified to work under limited test cases. However, all functionality may not be currently implemented.

    Please report any issues or feature requests to the [Conpot issues page](https://github.com/CommunityHoneyNetwork/conpot/issues).

The CommunityHoneyNetwork Conpot Honeypot is an implementation of of [@mushorg's Conpot](https://github.com/mushorg/conpot), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Conpot is an ICS honeypot with the goal to collect intelligence about the motives and methods of adversaries targeting industrial control systems."

## Configuring Conpot to talk to the CHN management server

Prior to starting, Conpot will parse some options from `/etc/sysconfig/conpot` for RedHat-based or `/etc/default/conpot` for Debian-based systems or containers. The following is an example config file:

```
# This file is read from /etc/sysconfig/conpot or /etc/default/conpot
# depending on the base distro
#
# This can be modified to change the default setup of the conpot unattended installation

DEBUG=false

# CHN Server api to register to
CHN_SERVER="http://chnserver"

# Server to stream data to
FEEDS_SERVER="hpfeeds"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=

# Registration information file
# If running in a container, this needs to persist
CONPOT_JSON="/etc/conpot/conpot.json"

# Conpot specific configuration options
CONPOT_TEMPLATE=default
```

### Configuration Options

The following options are supported in the `/etc/sysconfig/conpot` or `/etc/default/conpot` files:

* DEBUG: (boolean) Enable more verbose output to the console
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events. This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* CONPOT_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* CONPOT_TEMPLATE: (string) The service template to use for the Conpot daemon. Options include **iec104**, **default**, **guardian_ast**, **ipmi**, **kamstrup_382**, and **proxy**.

# Deploying Conpot with Docker and docker-compose

This example covers how to build and deploy an example [Conpot honeypot](https://github.com/mushorg/conpot) and connect it to a running CommunityHoneyNetwork server for collection of data.

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, requires the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

## Building and Deploying Conpot

Copy the following Docker Compose yaml, and save it as `docker-compose.yml`:

```
version: '2'
services:
    conpot:
        build:
            context: https://github.com/CommunityHoneyNetwork/conpot.git
            dockerfile: Dockerfile-centos
        image: conpot:centos
        volumes:
            - ./conpot.sysconfig:/etc/sysconfig/conpot
        ports:
            - "127.0.0.1:8082:80"
            - "127.0.0.1:102:102"
            - "127.0.0.1:502:502"
```

This will tell docker-compose to build the Conpot container image from the files in the [CommunityHoneyNetwork Conpot repository](https://github.com/CommunityHoneyNetwork/conpot), and mount the volume:

* ./conpot.sysconfig as /etc/sysconfig/conpot - configuration file for Conpot (see below)

Before starting the container, copy the following and save it as `conpot.sysconfig`, setting the `FEEDS_SERVER` and `CHN_SERVER` to the ip or hostname of the management server the honeypot will be reporting to, and `DEPLOY_KEY`

If you havent' yet set up a management server, follow the [Quickstart Guide](quickstart.md)

```
# This file is read from /etc/sysconfig/conpot or /etc/default/conpot
# depending on the base distro
#
# This can be modified to change the default setup of the conpot unattended installation

DEBUG=false

# CHN Server api to register to
CHN_SERVER="http://chnserver"

# Server to stream data to
FEEDS_SERVER="hpfeeds"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=

# Registration information file
# If running in a container, this needs to persist
CONPOT_JSON="/etc/conpot/conpot.json"

# Conpot specific configuration options
CONPOT_TEMPLATE=default
```

Build the container images for the Conpot container:

    $ docker-compose build

When the images are built, start the honeypot with:

    $ docker-compose up -d

You can verify the honeypot is running with `docker-compose ps`

    $ docker-compose ps
            Name                       Command               State                    Ports
    ----------------------------------------------------------------------------------------------------------------
    chnserver_conpot_1       /usr/bin/runsvdir -P /etc/ ...   Up               0.0.0.0:8080->8080/tcp

When you're ready, the honeypot can be stopped by running `docker-compose down` from the directory containing the docker-compose.yml file.

Your new honeypot should show up within the web interface of your management server under the `Sensors` tab, with the hostname of the container and the UUID that was stored in the conpot.json file during registration. As it detects attempts to login to its fake services, it will send this attack info to the management server.


You can now test the honeypot logging by trying to connect to one of the open honeypot ports in your web browser.

Attacks logged to your management server will show up under the `Attacks` section in the web interface.

# Acknowlegements

CommunityHoneyNetwork Conpot is an adaptation of [@mushorg's Conpot](https://github.com/mushorg/conpot) Conpot software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Conpot & HPFeeds work, among other contributors and collaborators.

# License

Conpot is licensed under the [GNU GENERAL PUBLIC LICENSE Version 2.0](https://raw.githubusercontent.com/mushorg/conpot/master/LICENSE.txt)

The ThreatStream implementation of Conpot with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Conpot deployment model and code](https://github.com/CommunityHoneyNetwork/conpot) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/conpot/master/LICENSE)
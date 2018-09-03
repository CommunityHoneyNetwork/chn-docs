RDPhoney Honeypot
=================

!!! note "Note"
    RDPhoney is currently in alpha. This honeypot has been verified to work under limited test cases. However, all functionality may not be currently implemented.

    Please report any issues or feature requests to the [RDPhoney issues page](https://github.com/CommunityHoneyNetwork/rdphoney/issues).


The CommunityHoneyNetwork RDPhoney Honeypot is a basic RDP honeypot, configured to report logged attacks to the CommunityHoneyNetwork management server.

## Configuring RDPhoney to talk to the CHN management server

Prior to starting, RDPhoney will parse some options from `/etc/sysconfig/rdphoney` for RedHat-base or `/etc/default/rdphoney` for Debian-based systems or containers. The following is an example config file:

```
# This file is read from /etc/sysconfig/rdphoney or /etc/default/rdphoney
# depending on the base distro
#
# This can be modified to change the default setup of the rdphoney unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

# CHN Server api to register to
CHN_SERVER="http://chnserver"

# Server to stream data to
FEEDS_SERVER="localhost"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=

# Registration information file
# If running in a container, this needs to persist
# RDPHONEY_JSON="/etc/rdphoney/rdphoney.json
```

### Configuration Options

The following options are supported in the `/etc/sysconfig/rdphoney` or `/etc/default/rdphoney` files:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events. This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* RDPHONEY_JSON: (string) The location to store the registration information returned from the HPFeeds server.


# Deploying RDPhoney with Docker and docker-compose

This example covers how to build and eploy an example [RDPhoney honeypot](https://github.com/CommunityHoneyNetwork/rdphoney) and connect it to a running CommunityHoneyNetwork server for collection of data.

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, requires the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

## Building and Deploying RDPhoney

Copy the following Docker Compose yaml, and save it as `docker-compose.yml`:

```
version: '2'
services:
    rdphoney:
        image: stingar/rdphoney:0.2-alpha-centos
        volumes:
            - ./rdphoney.sysconfig:/etc/sysconfig/rdphoney
            - ./rdphoney:/etc/rdphoney
        ports:
            - "3389:3389"
```

This will tell docker-compose to build the RDPhoney container image from the files in the [CommunityHoneyNetwork RDPhoney repository](https://github.com/CommunityHoneyNetwork/rdphoney), and mount the volume:

* ./rdphoney.sysconfig as /etc/sysconfig/rdphoney - configuration file for RDPhoney (see below)

Before starting the container, copy the following and save it as `rdphoney.sysconfig`, setting the `FEEDS_SERVER` and `CHN_SERVER` to the ip or hostname of the management server the honeypot will be reporting to, and `DEPLOY_KEY`

If you haven't yet set up a management server, follow the [Quickstart Guide](quickstart.md)

```
# This file is read from /etc/sysconfig/rdphoney or /etc/default/rdphoney
# depending on the base distro
#
# This can be modified to change the default setup of the rdphoney unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

# CHN Server api to register to
CHN_SERVER="http://chnserver"

# Server to stream data to
FEEDS_SERVER="localhost"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=

# Registration information file
# If running in a container, this needs to persist
# RDPHONEY_JSON="/etc/rdphoney/rdphoney.json
```

Once you have saved your `docker-compose.yml` file, start the honeypot with:

    $ docker-compose up -d

This command will download the pre-built image from hub.docker.com, and start your honeypot using this image.

You can verify the honeypot is running with `docker-compose ps`

    $ docker-compose ps
            Name                       Command               State                    Ports
    ----------------------------------------------------------------------------------------------------------------
    chnserver_rdphoney_1     /usr/bin/runsvdir -P /etc/ ...   Up               0.0.0.0:3389->3389/tcp

When you're ready, the honeypot can be stopped by running `docker-compose down` from the directory containing the docker-compose.yml file.

Your new honeypot should show up within the web interface of your management server under the `Sensors` tab, with the hostname of the container and the UUID that was stored in the rdphoney.json file during registration. As it detects attempts to login to its fake services, it will send this attack info to the management server.

You can now test the honeypot logging by trying to connect to one of the open honeypot ports in your web browser.

Attacks logged to your management server will show up under the `Attacks` section in the web interface

# License

RDPhoney is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/rdphoney/master/LICENSE)
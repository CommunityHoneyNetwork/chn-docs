Amun Honeypot
=============

!!! note "Note"
    Amun is currently in alpha. This honeypot has been verified to work under limited test cases. However, all functionality may not be currently implemented.

    Please report any issues or feature requests to the [Amun issues page](https://github.com/CommunityHoneyNetwork/amun/issues).

The CommunityHoneyNetwork Amun Honeypot is an implementation of [@zeroq's Amun](https://github.com/zeroq/amun), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Amun was the first python-based low-interaction honeypot, following the concepts of Nepenthes but extending it with more sophisticated emulation and easier maintenance."

## Configuring Amun to talk to the CHN management server

Prior to starting, Amun will parse some options from `/etc/sysconfig/amun` for RedHat-based or `/etc/default/amun` for Debian-based systems or containers. The following is an example config file:

```
# This file is read from /etc/sysconfig/amun or /etc/default/amun
# depending on the base distro
#
# This can be modified to change the default setup of the amun unattended installation

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
AMUN_JSON="/etc/amun/amun.json"
```

### Configuration Options

The following options are supported in the `/etc/sysconfig/amun` or `/etc/default/amun` files:

* DEBUG: (boolean) Enable more verbose output to the console
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events. This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* AMUN_JSON: (string) The location to store the registration information returned from the HPFeeds server.


# Deploying Amun with Docker and docker-compose

This example covers how to build and deploy an example [Amun honeypot](https://github.com/zeroq/amun) and connect it to a running CommunityHoneyNetwork server for collection of data.

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, requires the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

## Building and Deploying Amun

Copy the following Docker Compose yaml, and save it as `docker-compose.yml`:

```
version: '2'
services:
    amun:
        build:
            context: https://github.com/CommunityHoneyNetwork/amun.git
            dockerfile: Dockerfile-centos
        image: amun:centos
        volumes:
            - ./amun.sysconfig:/etc/sysconfig/amun
        ports:
            - "445:445"
```

This will tell docker-compose to build the Amun container image from the files in the [CommunityHoneyNetwork Amun repository](https://github.com/CommunityHoneyNetwork/amun), and mount the volume:

* ./amun.sysconfig as /etc/sysconfig/amun - configuration file for Amun (see below)

Before starting the container, copy the following and save it as `amun.sysconfig`, setting the `FEEDS_SERVER` and `CHN_SERVER` to the ip or hostname of the management server the honeypot will be reporting to, and `DEPLOY_KEY`

If you haven't yet set up a management server, follow the [Quickstart Guide](quickstart.md)

```
# This file is read from /etc/sysconfig/amun or /etc/default/amun
# depending on the base distro
#
# This can be modified to change the default setup of the amun unattended installation

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
AMUN_JSON="/etc/amun/amun.json"
```

Build the container images for the Amun container:

    $ docker-compose build

When the images are built, start the honeypot with:

    $ docker-compose up -d

You can verify the honeypot is running with `docker-compose ps`

    $ docker-compose ps
            Name                       Command               State                    Ports
    ----------------------------------------------------------------------------------------------------------------
    chnserver_amun_1         /usr/bin/runsvdir -P /etc/ ...   Up                0.0.0.0:445->445/tcp

When you're ready, the honeypot can be stopped by running `docker-compose down` from the directory containing the docker-compose.yml file.

Your new honeypot should show up within the web interface of your management server under the `Sensors` tab, with the hostname of the container and the UUID that was stored in the amun.json file during registration. As it detects attempts to login to its fake services, it will send this attack info to the management server.

You can now test the honeypot logging by trying to connect to one of the open honeypot ports in your web browser.

Attacks logged to your management server will show up under the `Attacks` section in the web interface

# Acknowlegements

CommunityHoneyNetwork Amun is an adaptation of [@zeroq's Amun](https://github.com/zeroq/amun) Amun software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Amun & HPFeeds work, among other contributors and collaborators.

# License

Amun is licensed under the [GNU GENERAL PUBLIC LICENSE Version 2.0](https://raw.githubusercontent.com/zeroq/amun/master/LICENSE)

The ThreatStream implementation of Amun with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Amun deployment model and code](https://github.com/CommunityHoneyNetwork/amun) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/amun/master/LICENSE)


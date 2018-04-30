Glastopf Honeypot
=================

!!! note "Note"
    Glastopf is currently in alpha. This honeypot has been verified to work under limited test cases. However, all functionality may not be currently implemented.

    Please report any issues or feature requests to the [Glastopf issues page](https://github.com/CommunityHoneyNetwork/glastopf/issues).

The CommunityHoneyNetwork Glastopf Honeypot is an implementation of [@mushorgs's Glastopf](https://github.com/mushorg/glastopf), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Glastopf is a Python web application honeypot founded by Lukas Rist."

## Configuring Glastopf to talk to the CHN management server

Prior to starting, Glastopf will parse some options from `/etc/default/glastopf` for Debian-based systems or containers. The following is an example config file:

```
# This file is read from /etc/default/glastopf
# depending on the base distro
#
# This can be modified to change the default setup of the glastopf unattended installation

DEBUG=false

# CHN Server api to register to
CHN_SERVER="http://<IP.OR.NAME.OF.YOUR.CHNSERVER>"

# Server to stream data to
FEEDS_SERVER="<IP.OR.NAME.OF.YOUR.HPFEEDS"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=

# Registration information file
# If running in a container, this needs to persist
GLASTOPF_JSON="/etc/glastopf/glastopf.json"

GLASTOPF_PORT=8080
```

### Configuration Options

The following options are supported in the `/etc/default/glastopf` files

* DEBUG: (boolean) Enable more verbose output to the console
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events.  This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port.  Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup.  This key is **required** for registration.
* GLASTOPF_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* GLASTOPF_PORT: (integer) The web server port for the Glastopf daemon. In containerized applications, this is _inside the container_, and the port can still be mapped to a different port on the host.

# Deploying Glastopf with Docker and docker-compose

This example covers how to build and deploy an example [Glastopf honeypot](https://github.com/mushorg/glastopf) and connect it to a running CommunityHoneyNetwork server for collection of data.

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, require the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

## Building and Deploying Glastopf

Copy the following Docker Compose yaml, and save it as `docker-compose.yml`:

```
version: '2'
services:
    glastopf:
        build:
            context: https://github.com/CommunityHoneyNetwork/glastopf.git
            dockerfile: Dockerfile-ubuntu
        image: glastopf:ubuntu
        volumes:
            - ./glastopf.sysconfig:/etc/default/glastopf
        ports:
            - "8080:8080"
```

This will tell docker-compose to build the Glastopf container image from the files in the [CommunityHoneyNetwork Glastopf repository](https://github.com/CommunityHoneyNetwork/glastopf), and mount the volume:

* ./glastopf.sysconfig as /etc/default/glastopf - configuration file for Glastopf (see below)

Before starting the container, copy the following and save it as `glastopf.sysconfig`, setting the `FEEDS_SERVER` and `CHN_SERVER` to the ip or hostname of the management server the honeypot will be reporting to, and `DEPLOY_KEY`

If you haven't yet setup a management server, follow the [Quickstart Guide](quickstart.md)

```
# This file is read from /etc/default/glastopf
# depending on the base distro
#
# This can be modified to change the default setup of the glastopf unattended installation

DEBUG=false

# CHN Server api to register to
CHN_SERVER="http://<IP.OR.NAME.OF.YOUR.CHNSERVER>"

# Server to stream data to
FEEDS_SERVER="<IP.OR.NAME.OF.YOUR.HPFEEDS"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=

# Registration information file
# If running in a container, this needs to persist
GLASTOPF_JSON="/etc/glastopf/glastopf.json"

GLASTOPF_PORT=8080
```

Build the container images for the Glastopf container:

    $ docker-compose build

When the images are built, start the honeypot with:

    $ docker-compose up -d
    
You can verify the honeypot is running with `docker-compose ps`

    $ docker-compose ps
            Name                       Command               State                    Ports
    ----------------------------------------------------------------------------------------------------------------
    chnserver_glastopf_1     /usr/bin/runsvdir -P /etc/ ...   Up               0.0.0.0:8080->8080/tcp
    
When you're ready, the honeypot can be stopped by running `docker-compose down` from the directory containing the docker-compose.yml file.

Your new honeypot should show up within the web interface of your management server under the `Sensors` tab, with the hostname of the container and the UUID that was stored in the glastopf.json file during registration. As it detects attempts to login to its fake services, it will send this attack info to the management server.

You can now test the honeypot logging by trying to connect to one of the open honeypot ports in your web browser.

Attacks logged to your management server will show up under the `Attacks` section in the web interface.

# Acknowlegements

CommunityHoneyNetwork Glastopf is an adaptation of [@mushorg's Glastopf](https://github.com/mushorg/glastopf/) Glastopf software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Glastopf & HPFeeds work, among other contributors and collaborators.

# License

Glastopf is licensed under the [GNU GENERAL PUBLIC LICENSE Version 3.0](https://github.com/mushorg/glastopf/blob/master/GPL)

The ThreatStream implementation of Glastopf with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Glastopf deployment model and code](https://github.com/CommunityHoneyNetwork/glastopf) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/glastopf/master/LICENSE)

    
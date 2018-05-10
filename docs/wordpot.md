Wordpot Honeypot
================

!!! note "Note"
    Wordpot is currently in alpha. This honeypot has been verified to work under limited test cases. However, all functionality may not be currently implemented.

    Please report any issues or feature requests to the [Wordpot issues page](https://github.com/CommunityHoneyNetwork/wordpot/issues).

The CommunityHoneyNetwork Wordpot Honeypot is an implementation of [@gbrindisi's Wordpot](https://github.com/gbrindisi/wordpot), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Wordpot is a Wordpress honeypot which detects probes for plugins, themes, timthumb and other common files used to fingerprint a wordpress installation."

## Configuring Wordpot to talk to the CHN management server

Prior to starting, Wordpot will parse some options from `/etc/sysconfig/wordpot` for RedHat-based or `/etc/default/wordpot` for Debian-based systems or containers.  The following is an example config file:

```
# This file is read from /etc/sysconfig/wordpot or /etc/default/wordpot
# depending on the base distro
#
# This can be modified to change the default setup of the wordpot unattended installation

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
# WORDPOT_JSON="/etc/wordpot/wordpot.json

# Wordpress options
WORDPRESS_PORT=8080
```

### Configuration Options

The following options are supported in the `/etc/sysconfig/wordpot` or `/etc/default/wordpot` files:

* DEBUG: (boolean) Enable more verbose output to the console
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events. This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* WORDPOT_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* WORDPRESS_PORT: (integer) The web server port for the Wordpot daemon. In containerized applications, this is _inside the container_, and the port can still be mapped to a different port on the host.

# Deploying Wordpot with Docker and docker-compose

This example covers how to build and deploy an example [Wordpot honypot](https://github.com/gbrindisi/wordpot) and connect it to a running CommunityHoneyNetwork server for collection of data.

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, requires the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

## Building and Deploying Wordpot

Copy the following Docker Compose yaml, and save it as `docker-compose.yml`:

```
version: '2'
services:
    wordpot:
        build:
            context: https://github.com/CommunityHoneyNetwork/wordpot.git
            dockerfile: Dockerfile-centos
        image: wordpot:centos
        volumes:
            - ./wordpot.sysconfig:/etc/sysconfig/wordpot
        ports:
            - "8080:8080"
```

This will tell docker-compose to build the Wordpot container image from the files in the [CommunityHoneyNetwork Wordpot repository](https://github.com/CommunityHoneyNetwork/wordpot), and mount the volume:

* ./wordpot.sysconfig as /etc/sysconfig/wordpot - configuration file for Wordpot (see below)

Before starting the container, copy the following and save it as `wordpot.sysconfig`, setting the `FEEDS_SERVER` and `CHN_SERVER` to the ip or hostname of the management server the honeypot will be reporting to, and `DEPLOY_KEY`

If you haven't yet set up a management server, follow the [Quickstart Guide](quickstart.md)

```
# This file is read from /etc/sysconfig/wordpot or /etc/default/wordpot
# depending on the base distro
#
# This can be modified to change the default setup of the wordpot unattended installation

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
# WORDPOT_JSON="/etc/wordpot/wordpot.json

# Wordpress options
WORDPRESS_PORT=8080
```

Build the container images for the Wordpot container:

    $ docker-compose build

When the images are built, start the honeypot with:

    $ docker-compose up -d

You can verify the honeypot is running with `docker-compose ps`

    $ docker-compose ps
            Name                       Command               State                    Ports
    ----------------------------------------------------------------------------------------------------------------
    chnserver_wordpot_1      /usr/bin/runsvdir -P /etc/ ...   Up               0.0.0.0:8080->8080/tcp

When you're ready, the honeypot can be stopped by running `docker-compose down` from the directory containing the docker-compose.yml file.

Your new honeypot should show up within the web interface of your management server under the `Sensors` tab, with the hostname of the container and the UUID that was stored in the wordpot.json file during registration. As it detects attempts to login to its fake services, it will send this attack info to the management server.

You can now test the honeypot logging by trying to connect to one of the open honeypot ports in your web browser.

Attacks logged to your management server will show up under the `Attacks` section in the web interface

# Acknowlegements

CommunityHoneyNetwork Wordpot is an adaptation of [@gbrindisi's Wordpot](https://github.com/gbrindisi/wordpot) Wordpot software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Wordpot & HPFeeds work, among other contributors and collaborators.

# License

Wordpot is licensed under the [ISC License (ISC)](https://github.com/gbrindisi/wordpot/blob/master/README.md#license)

The ThreatStream implementation of Wordpot with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Wordpot deployment model and code](https://github.com/CommunityHoneyNetwork/wordpot) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/wordpot/master/LICENSE)
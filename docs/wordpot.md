Wordpot Honeypot
================
The CommunityHoneyNetwork Wordpot Honeypot is an implementation of [@gbrindisi's Wordpot](https://github.com/gbrindisi/wordpot), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Wordpot is a Wordpress honeypot which detects probes for plugins, themes, timthumb and other common files used to fingerprint a wordpress installation."

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, require the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

**Please ensure the user on the system installing the honeypot is in the local
 docker group**
 
 Please see your system documentation for adding a user to the docker group.

## Important Note!
The sysconfig files, as well as the docker-compose.yml files below are intended 
to help you understand the various options. While they may serve as a basis 
for users with advanced deployment needs, most users should default to the 
configuration files provided by the deployment scripts in the CHN web interface.

## Example wordpot docker-compose.yml
```dockerfile
version: '2'
services:
    wordpot:
        image: stingar/wordpot:1.8
        volumes:
            - ./wordpot.sysconfig:/etc/default/wordpot
            - ./wordpot:/etc/wordpot
        ports:
            - "8080:8080"
```
## Example wordpot.sysconfig file

Prior to starting, Wordpot will parse some options from `/etc/default/wordpot` for Debian-based systems or containers.  The following is an example config file:

```
# This file is read from /etc/default/wordpot
#
# This can be modified to change the default setup of the wordpot unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

# CHN Server api to register to
CHN_SERVER="http://<IP.OR.NAME.OF.YOUR.CHNSERVER>"

# Server to stream data to
FEEDS_SERVER="<IP.OR.NAME.OF.YOUR.HPFEEDS>"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=

# Registration information file
# If running in a container, this needs to persist
WORDPOT_JSON="/etc/wordpot/wordpot.json

# Wordpress options
WORDPRESS_PORT=8080
```

### Configuration Options

The following options are supported in the `/etc/default/wordpot` file:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events. This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* WORDPOT_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* WORDPRESS_PORT: (integer) The web server port for the Wordpot daemon. In containerized applications, this is _inside the container_, and the port can still be mapped to a different port on the host.

# Acknowlegements

CommunityHoneyNetwork Wordpot is an adaptation of [@gbrindisi's Wordpot](https://github.com/gbrindisi/wordpot) Wordpot software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Wordpot & HPFeeds work, among other contributors and collaborators.

# License

Wordpot is licensed under the [ISC License (ISC)](https://github.com/gbrindisi/wordpot/blob/master/README.md#license)

The ThreatStream implementation of Wordpot with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Wordpot deployment model and code](https://github.com/CommunityHoneyNetwork/wordpot) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/wordpot/master/LICENSE)

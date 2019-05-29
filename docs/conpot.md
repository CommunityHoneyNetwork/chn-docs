Conpot Honeypot
===============
The CommunityHoneyNetwork Conpot Honeypot is an implementation of of [@mushorg's Conpot](https://github.com/mushorg/conpot), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Conpot is an ICS honeypot with the goal to collect intelligence about the motives and methods of adversaries targeting industrial control systems."

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

## Example amun docker-compose.yml
```dockerfile
version: '2'
services:
    conpot:
        image: stingar/conpot:1.8-pre
        volumes:
            - ./conpot.sysconfig:/etc/default/conpot
            - ./conpot:/etc/conpot
        ports:
            - 80:80
            - 102:102
            - 502:502
```
## Example conpot.sysconfig file

Prior to starting, Conpot will parse some options from `/etc/sysconfig/conpot` for RedHat-based or `/etc/default/conpot` for Debian-based systems or containers. The following is an example config file:

```
# This file is read from /etc/sysconfig/conpot or /etc/default/conpot
# depending on the base distro
#
# This can be modified to change the default setup of the conpot unattended installation

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
CONPOT_JSON="/etc/conpot/conpot.json"

# Conpot specific configuration options
CONPOT_TEMPLATE=default

# Comma separated tags for honeypot
TAGS=""
```

### Configuration Options

The following options are supported in the `/etc/sysconfig/conpot` or `/etc/default/conpot` files:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events. This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* CONPOT_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* CONPOT_TEMPLATE: (string) The service template to use for the Conpot daemon. Options include **iec104**, **default**, **guardian_ast**, **ipmi**, **kamstrup_382**, and **proxy**.
* TAGS: (string) Comma delimited string for honeypot-specific tags. Tags must be separated by a comma to be parsed properly. **TAGS** string must be enclosed in double quotes if string contains spaces.

# Acknowlegements

CommunityHoneyNetwork Conpot is an adaptation of [@mushorg's Conpot](https://github.com/mushorg/conpot) Conpot software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Conpot & HPFeeds work, among other contributors and collaborators.

# License

Conpot is licensed under the [GNU GENERAL PUBLIC LICENSE Version 2.0](https://raw.githubusercontent.com/mushorg/conpot/master/LICENSE.txt)

The ThreatStream implementation of Conpot with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Conpot deployment model and code](https://github.com/CommunityHoneyNetwork/conpot) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/conpot/master/LICENSE)

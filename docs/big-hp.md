Big-HP Honeypot
=================

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, require the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

**Please ensure the user on the system installing the honeypot is in the local
 docker group**
 
 Please see your system documentation for adding a user to the docker group.

## Important Note!
The env files, as well as the docker-compose.yml files below are intended 
to help you understand the various options. While they may serve as a basis 
for users with advanced deployment needs, most users should default to the 
configuration files provided by the deployment scripts in the CHN web interface.

## Example big-hp docker-compose.yml
```dockerfile
version: '3'
services:
  bighp:
    image: stingar/big-hp:1.9.1            
    volumes:
    - configs:/etc/big-hp
    ports:
      - "443:8000"
    env_file:
      - big-hp.env
volumes:
  configs:
```

## Example big-hp.env file

Prior to starting, Big-HP will parse some options from `big-hp.env`. The following is an example config file:

```
# This can be modified to change the default setup of the unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

# CHN Server api to register to
CHN_SERVER={url}

# Server to stream data to
FEEDS_SERVER={server}
FEEDS_SERVER_PORT=10000

# Variables to set to pass to the honeypot web server for reporting and visibility
REPORTED_IP=
REPORTED_PORT=443
HOSTNAME=

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY={deploy}

# Registration information file
# If running in a container, this needs to persist
BIGHP_JSON=/etc/big-hp/big-hp.json

# Comma separated tags for honeypot
TAGS={tags}
```

### Configuration Options

The following options are supported in the `big-hp.env` file:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events. This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.
* REPORTED_IP: (string) IP address to include in data output from the honeypot
* REPORTED_PORT: (integer) port number to use in data output from the honeypot
* HOSTNAME: (string) Hostname you wish to present to attackers in the HTML template outputs
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* BIGHP_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* TAGS: (string) Comma delimited string for honeypot-specific tags. Tags must be separated by a comma to be parsed properly. 

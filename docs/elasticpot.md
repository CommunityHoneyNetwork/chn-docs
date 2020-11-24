Elasticpot Honeypot
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

## Example elasticpot docker-compose.yml
```dockerfile
version: '3'
services:
  elastipot:
    image: stingar/elasticpot:1.9.1
    restart: always
    volumes:
      - configs:/etc/elastipot
    ports:
      - "9200:9200"
    env_file:
      - elasticpot.env
volumes:
  configs:
```

## Example elasticpot.env file

Prior to starting, Elasticpot will parse some options from `elasticpot.env`. The following is an example config file:

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

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY={deploy}

# Registration information file
# If running in a container, this needs to persist
ELASTICPOT_JSON=/etc/elasticpot/elasticpot.json

# Comma separated tags for honeypot
TAGS={tags}
```

### Configuration Options

The following options are supported in the `elasticpot.env` file:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events. This will likely be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* ELASTICPOT_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* TAGS: (string) Comma delimited string for honeypot-specific tags. Tags must be separated by a comma to be parsed properly. **TAGS** string must be enclosed in double quotes if string contains spaces.


# License

Elasticpot is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/elasticpot/master/LICENSE)

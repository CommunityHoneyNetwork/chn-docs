UHP Honeypot
===============
__** WARNING: This honeypot is currently in ALPHA support for CHN and is not 
likely suitable for production use at this time **__

The CommunityHoneyNetwork UHP Honeypot is an implementation of [@MattCarothers's UHP](https://github.com/MattCarothers/uhp), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "UHP is a medium interaction honeypot that allows defenders to quickly implement line-based TCP protocols with a simple JSON configuration."

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

## Example uhp docker-compose.yml
```
version: '3'
services:
    uhp:
        image: stingar/uhp:1.9
        restart: always
        volumes:
            - configs:/etc/uhp
        ports:
            - "25:2525"
        env_file:
            - uhp.env
volumes:
    configs:
```

## Example uhp.env file

Prior to starting, UHP will parse some options from `/etc/default/uhp` for Debian-based containers.  The following is an example config file:

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
UHP_JSON=/etc/uhp/uhp.json

# Defaults include auto-config-gen.json, avtech-devices.json, generic-listener.json,
# hajime.json, http-log-headers.json, http.json, pop3.json, and smtp.json
UHP_CONFIG=smtp.json

UHP_LISTEN_PORT=2525

# Comma separated tags for honeypot
TAGS={tags}
```

### Configuration Options

The following options are supported in the `/etc/default/uhp` file:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events.  This is likely going to be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port.  Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup.  This key is **required** for registration.
* UHP_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* UHP_CONFIG: (string) The filename for the UHP JSON honeypot configuration
* UHP_LISTEN_PORT: (integer) The port for the UHP daemon to listen on for connections.  In containerized applications, this is _inside the container_, and the port can still be mapped to a different port on the host.
* TAGS: (string) Comma delimited string for honeypot-specific tags. Tags must be separated by a comma to be parsed properly. **TAGS** string must be enclosed in double quotes if string contains spaces.


## Acknowledgements

CommunityHoneyNetwork UHP container is an adaptation of [[@MattCarothers's UHP](https://github.com/MattCarothers/uhp) UHP software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) UHP & HPFeeds work, among other contributors and collaborators.

## License

The ThreatStream implementation of UHP with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork UHP deployment model and code](https://github.com/CommunityHoneyNetwork/uhp) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/uhp/master/LICENSE)

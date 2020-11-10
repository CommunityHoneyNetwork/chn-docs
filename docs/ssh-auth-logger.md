ssh-auth-logger Honeypot
===============

The CommunityHoneyNetwork ssh-auth-logger Honeypot is an implementation of [@justinAzoff's ssh-auth-logger](https://github.com/JustinAzoff/ssh-auth-logger), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "A low/zero interaction ssh authentication logging honeypot"
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

## Example ssh-auth-logger docker-compose.yml
```dockerfile
version: '3'
services:
  ssh-auth-logger:
    image: stingar/ssh-auth-logger:1.9.1
    restart: always
    volumes:
      - configs:/etc/ssh-auth-logger
    ports:
      - "2222:22222"
    env_file:
      - ssh-auth-logger.env
volumes:
    configs:
```
## Example ssh-auth-logger.env file

Prior to starting, ssh-auth-logger will parse options from the environment, passed to the container via the `env_file
` specification in the docker-compose file. The following is an example env file:

```
# This can be modified to change the default setup of the ssh-auth-logger unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

# Internal Docker port ssh-auth-logger should bind to. Don't adjust generally.
SSHD_BIND=:22222

# CHN Server api to register to
CHN_SERVER=https://{fqdn_or_ip_of_chn_server}

# Server to stream data to
FEEDS_SERVER={fqdn_or_ip_of_chn_server}
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY={deploy_key}

# Registration information file
# If running in a container, this needs to persist
SSHAUTHLOGGER_JSON=/etc/ssh-auth-logger/ssh-auth-logger.json

# comma delimited tags may be specified, which will be included
# as a field in the hpfeeds output. Use cases include tagging provider
# infrastructure the sensor lives in, geographic location for the sensor, etc.
TAGS=
```

### Configuration Options

The following options are supported in the `/etc/default/ssh-auth-logger` files:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events.  This is likely going to be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port.  Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup.  This key is **required** for registration.
* SSHAUTHLOGGER_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* SSHD_BIND: (:integer) The port for the ssh-auth-logger daemon to listen on for SSH connections.  In containerized applications, this is _inside the container_, and the port can still be mapped to a different port on the host.
* TAGS: (string) Comma delimited string for honeypot-specific tags. Tags must be separated by a comma to be parsed properly. 
**TAGS** string must be enclosed in double quotes if string contains spaces.


## Running ssh-auth-logger on port 22

By default ssh-auth-logger will run on port 2222, to avoid any conflict with the real SSH or Telnet services on the machine. If you wish to run the honeypot on port 22, you need to move the real SSH service to a new port. This is outside the scope of our documentation, but would look generally like:

* Edit `/etc/ssh/sshd_config` and change the `Port 22` stanza to your desired port, such as `Port 2022`.
* Restart the SSH daemon `sudo systemctl restart ssh.service`
* Ensure the SSH daemon is running `sudo systemctl status ssh.service` and look for "Active: active (running)"
* From a NEW terminal, try to SSH to your new port, to ensure your config is working
* (Optional) Disconnect from your exiting SSH session(s)
* Edit the `docker-compose.yml` file to expose the standard SSH port:
```
version: '3'
services:
  ssh-auth-logger:
    image: stingar/ssh-auth-logger:1.9.1
    restart: always
    volumes:
      - configs:/etc/ssh-auth-logger
    ports:
      - "22:22222"
    env_file:
      - ssh-auth-logger.env
volumes:
    configs:
```
* **DO NOT** edit the `ssh-auth-logger.env` file and change the SSHD_PORT unless absolutely required; let Docker handle the translation
* Restart the container:
```
docker-compose down && docker-compose up -d
```
 
## Acknowledgements

CommunityHoneyNetwork ssh-auth-logger container is an adaptation of [@justinAzoff's ssh-auth-logger]https://github.com/JustinAzoff/ssh-auth-logger) ssh-auth-logger software and Threatstream's Modern Honey Network & HPFeeds work, among other contributors and collaborators.

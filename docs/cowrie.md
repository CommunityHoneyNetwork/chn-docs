Cowrie Honeypot
===============

The CommunityHoneyNetwork Cowrie Honeypot is an implementation of [@micheloosterhof's Cowrie](https://github.com/micheloosterhof/cowrie), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Cowrie is a medium interaction SSH and Telnet honeypot designed to log brute force attacks and the shell interaction performed by the attacker."

## Configuring Cowrie to talk to the CHN management server

Prior to starting, Cowrie will parse some options from `/etc/sysconfig/cowrie` for RedHat-based or `/etc/default/cowrie` for Debian-based systems or containers.  The following is an example config file:

```
# This file is read from /etc/sysconfig/cowrie or /etc/default/cowrie
# depending on the base distro
#
# This can be modified to change the default setup of the cowrie unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

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
# COWRIE_JSON="/etc/cowrie/cowrie.json

# SSH Listen Port
# Can be set to 22 for deployments on real servers
# or left at 2222 and have the port mapped if deployed
# in a container
SSH_LISTEN_PORT=2222

# Telnet Listen Port
# Can be set to 23 for deployments on real servers
# or left at 2223 and have the port mapped if deployed
# in a container
TELNET_LISTEN_PORT=2223
```

### Configuration Options

The following options are supported in the `/etc/sysconfig/cowrie` and `/etc/default/cowrie files`:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events.  This is likely going to be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port.  Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup.  This key is **required** for registration.
* COWRIE_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* SSH_LISTEN_PORT: (integer) The port for the Cowrie daemon to listen on for SSH connections.  In containerized applications, this is _inside the container_, and the port can still be mapped to a different port on the host.
* TELNET_LISTEN_PORT: (integer) The port for the Cowrie daemon to listen on for Telnet connections. In containerized applications, this is _inside the container_, and the port can still be mapped to a different port on the host.

## Running Cowrie on port 22/23

By default Cowrie will run on port 2222/2223, to avoid any conflict with the real SSH or Telnet services on the machine. If you wish to run the honeypot on port 22, you need to move the real SSH service to a new port. This is outside the scope of our documentation, but would look generally like:

* Edit `/etc/ssh/sshd_config` and change the `Port 22` stanza to your desired port, such as `Port 22222`.
* Restart the SSH daemon `sudo systemctl restart ssh.service`
* Ensure the SSH daemon is running `sudo systemctl status ssh.service` and look for "Active: active (running)"
* From a NEW terminal, try to SSH to your new port, to ensure your config is working
* (Optional) Disconnect from your exiting SSH session(s)
* Edit the `docker-compose.yml` file to expose the standard SSH port:
```
version: '2'
services:
  cowrie:
    image: stingar/cowrie:latest
    volumes:
      - ./cowrie.sysconfig:/etc/sysconfig/cowrie
      - ./cowrie:/etc/cowrie
    ports:
      - "22:2222"
      - "23:2223"
```
* **DO NOT** edit the `cowrie.sysconfig` file and change the SSH_LISTEN_PORT or TELNET_LISTEN_PORT; just let Docker handle the translation
* Restart the container:
```
docker-compose down && docker-compose up -d
```

## Deploying Cowrie with Docker and docker-compose

Deploying Cowrie with Docker and docker-compose is covered in the [Your First Honeypot](firstpot.md) documentation.

## Deploying Cowrie without Docker

While deploying Cowrie in a container is the strongly suggested method, it can be deployed directly on a host, without the use of Docker, by running an [Ansible](https://www.ansible.com/) playbook.

_The warnings, prerequisites, supported operating systems and other notes from the overall [Deploying Without Docker](nondocker.md) documentation apply._

To deploy the latest CommunityHoneyNetwork Cowrie honeypot without Docker:

    cd /opt
    git clone https://github.com/CommunityHoneyNetwork/cowrie/
    cd cowrie
    echo "localhost ansible_connection=local" inventory.txt
    ansible-playbook cowrie.yml -i inventory.txt -c local

After installation, adjust the `/etc/sysconfig/cowrie` or `/etc/default/cowrie` file as described above to register the honeypot with the CHN management server.

As with other CommunityHoneyNetwork projects, Cowrie relies on [Runit](http://smarden.org/runit/) as its process manager.   See the [Runit Section](nondocker.md#Runit) section of the Deploying Without Docker documentation for more information.

## Acknowledgements

CommunityHoneyNetwork Cowrie container is an adaptation of [@micheloosterhof's Cowrie](https://github.com/micheloosterhof/cowrie) Cowrie software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Cowrie & HPFeeds work, among other contributors and collaborators.

## License

The Cowrie software is [Copyright (c) 2009 Upi Tamminen](https://raw.githubusercontent.com/micheloosterhof/cowrie/master/LICENSE.md) All rights reserved.

The ThreatStream implementation of Cowrie with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Cowrie deployment model and code](https://github.com/CommunityHoneyNetwork/cowrie) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/cowrie/master/LICENSE)

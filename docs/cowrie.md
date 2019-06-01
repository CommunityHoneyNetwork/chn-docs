Cowrie Honeypot
===============

The CommunityHoneyNetwork Cowrie Honeypot is an implementation of [@micheloosterhof's Cowrie](https://github.com/micheloosterhof/cowrie), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Cowrie is a medium interaction SSH and Telnet honeypot designed to log brute force attacks and the shell interaction performed by the attacker."
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

## Example cowrie docker-compose.yml
```dockerfile
version: '2'
services:
  cowrie:
    image: stingar/cowrie:1.8-pre
    volumes:
      - ./cowrie.sysconfig:/etc/default/cowrie
      - ./cowrie:/etc/cowrie
    ports:
      - "2222:2222"
      - "23:2223"
```
## Example cowrie.sysconfig file

Prior to starting, Cowrie will parse some options from `/etc/default/cowrie` for Debian-based containers.  The following is an example config file:

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
CHN_SERVER="${URL}"

# Server to stream data to
FEEDS_SERVER="${SERVER}"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY="${DEPLOY}"

# Registration information file
# If running in a container, this needs to persist
COWRIE_JSON="/etc/cowrie/cowrie.json"

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

# double quotes, comma delimited tags may be specified, which will be included
# as a field in the hpfeeds output. Use cases include tagging provider
# infrastructure the sensor lives in, geographic location for the sensor, etc.
TAGS=""

# A specific "personality" directory for the Cowrie honeypot may be specified
# here. These directories can include custom fs.pickle, cowrie.cfg, txtcmds and
# userdb.txt files which can influence the attractiveness of the honeypot.
PERSONALITY=default
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
* TAGS: (string) Comma delimited string for honeypot-specific tags. Tags must be separated by a comma to be parsed properly. * TAGS: (string) Comma delimited string for honeypot-specific tags. Tags must be separated by a comma to be parsed properly. **TAGS** string must be enclosed in double quotes if string contains spaces.
* PERSONALITY: (string) a directory name under /opt/personalities containing 
cowrie configuration files such as cowrie.cfg, fs.pickle, userdb.txt, etc. 
See the [upstream project](https://github
.com/cowrie/cowrie#files-of-interest) for details. 

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
    image: stingar/cowrie:1.8-pre
    volumes:
      - ./cowrie.sysconfig:/etc/default/cowrie
      - ./cowrie:/etc/cowrie
    ports:
      - "22:2222"
      - "23:2223"
```
* **DO NOT** edit the `cowrie.sysconfig` file and change the SSH_LISTEN_PORT or TELNET_LISTEN_PORT; let Docker handle the translation
* Restart the container:
```
docker-compose down && docker-compose up -d
```

## Adding a custom cowrie "personality"

You can add files to your cowrie honeypot in order to customize it's behavior. Currently the code supports custom 
versions of `cowrie.cfg`, `userdb.txt`, `fs.pickle`, and custom `txtcmds` via a directory structure. See [here](https://github.com/CommunityHoneyNetwork/cowrie/tree/master/personalities/aws-ubuntu16) for an example personality. 

Once you have the custom files on the honeypot host, volume mount a directory containing these files to the container, 
and specify the directory name in the `PERSONALITY` sysconfig option.

For a more concrete example: let's say I want to include a `userdb.txt` and `cowrie.cfg` file in a personality called 'sneakycowrie'. 

First I'll create a directory called "sneakycowrie" on my honeypot VM with the `userdb.txt` and `cowrie.cfg` files in
 it. It might look like this:
 
```bash
$ ls -l
total 12
drwxr-xr-x 2 root root   25 Apr 25 09:51 cowrie
-rw-r--r-- 1 me  me  1535 Apr 25 10:30 cowrie.sysconfig
-rw-rw-r-- 1 me  me  2115 Apr 25 10:29 deploy.sh
-rw-r--r-- 1 me  me   256 Apr 25 10:30 docker-compose.yml
drwxrwxr-x 2 me  me    42 Apr 25 10:43 sneakycowrie

$ ls -l sneakycowrie/
total 8
-rw-rw-r-- 1 me me 310 Apr 25 10:43 cowrie.cfg
-rw-rw-r-- 1 me me 676 Apr 25 10:06 userdb.txt
```

Then make the following change to the `docker-compose.yml`:

```
<snip>
    volumes:
      - ./cowrie.sysconfig:/etc/default/cowrie
      - ./cowrie:/etc/cowrie
      - ./sneakycowrie:/opt/personalities/sneakycowrie
<snip>
```
and then modify the `cowrie.sysconfig` to specify the directory name in the `PERSONALITY` variable:
```
# A specific "personality" directory for the Cowrie honeypot may be specified
# here. These directories can include custom fs.pickle, cowrie.cfg, txtcmds and
# userdb.txt files which can influence the attractiveness of the honeypot.
PERSONALITY="sneakycowrie"
```
You should then be able to `docker-compose down` and `docker-compose up -d` at this point and the personality should take effect.
 
## Acknowledgements

CommunityHoneyNetwork Cowrie container is an adaptation of [@micheloosterhof's Cowrie](https://github.com/micheloosterhof/cowrie) Cowrie software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Cowrie & HPFeeds work, among other contributors and collaborators.

## License

The Cowrie software is [Copyright (c) 2009 Upi Tamminen](https://raw.githubusercontent.com/micheloosterhof/cowrie/master/LICENSE.md) All rights reserved.

The ThreatStream implementation of Cowrie with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Cowrie deployment model and code](https://github.com/CommunityHoneyNetwork/cowrie) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/cowrie/master/LICENSE)

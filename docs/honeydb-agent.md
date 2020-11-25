honeydb-agent Honeypot
===============

The CommunityHoneyNetwork honeydb-agent Honeypot is an implementation of [@honeydbio's honeydb-agent](https://github.com/honeydbio), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "HoneyDB provides real time data of honeypot activity. This data comes from honeypot sensors deployed globally on the Internet."
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

## Example honeydb-agent docker-compose.yml
```dockerfile
version: '3'
services:
  honeydb:
    image: honeydb-agent:latest
    volumes:
    - configs:/etc/honeydb/
    env_file:
      - honeydb-agent.env
    ports:
      - "389:389"           # LDAP
      - "10001:10001"       # Gas
      - "7000:7000"         # Echo
      - "1883:1883"         # MQQT
      - "8:8"               # MOTD
      - "2100:2100"         # FTP
      - "2222:2222"         # SSH
      - "2323:2323"         # Telnet
      - "25:25"             # SMTP
      - "8081:8081"         # HTTP
      - "502:502"           # Modbus
      - "2000:2000"         # iKettle
      - "2048:2048"         # Random
      - "3306:3306"         # MySQL
      - "4096:4096"         # HashRandomCount
      - "3389:3389"         # RDP
      - "5900:5900"         # VNC
      - "6379:6379"         # Redis
      - "7001:7001"         # WebLogic
      - "9200:9200"         # Elasticsearch
      - "11211:11211"       # Memcached
      - "20547:20547"       # ProConOs

volumes:
    configs:
```
## Example honeydb-agent.env file

Prior to starting, honeydb-agent will parse options from the environment, passed to the container via the `env_file
` specification in the docker-compose file. The following is an example env file:

```
DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

CHN_SERVER={url}
DEPLOY_KEY={deploy}
HONEYDB_JSON=/etc/honeydb/honeydb.json

# Logging options
FEEDS_SERVER={server}
FEEDS_SERVER_PORT=10000
TAGS=

# If you wish to also contribute your data to the Honeydb.io project, enable this option
# and create an account at https://honeydb.io/login to get an HoneyDB API ID and a HoneyDB Agent Secret Key
HONEYDB_ENABLED=No
HONEYDB_APIID=123
HONEYDB_APIKEY=123

# Honeydb-agent services to run. Use "Yes" to turn on a service, and "No" to turn it off.
# You can also remove the corresponding port mapping in the docker-compose file
HONEYDBSERVICE_LDAP=Yes
HONEYDBSERVICE_GAS=Yes
HONEYDBSERVICE_ECHO=Yes
HONEYDBSERVICE_MQTT=Yes
HONEYDBSERVICE_MOTD=Yes
HONEYDBSERVICE_FTP=Yes
HONEYDBSERVICE_SSH=Yes
HONEYDBSERVICE_TELNET=Yes
HONEYDBSERVICE_SMTP=Yes
HONEYDBSERVICE_HTTP=Yes
HONEYDBSERVICE_IKETTLE=Yes
HONEYDBSERVICE_RANDOM=Yes
HONEYDBSERVICE_MYSQL=Yes
HONEYDBSERVICE_HASHRANDOMCOUNT=Yes
HONEYDBSERVICE_RDP=Yes
HONEYDBSERVICE_VNC=Yes
HONEYDBSERVICE_REDIS=Yes
HONEYDBSERVICE_WEBLOGIC=Yes
HONEYDBSERVICE_ELASTICSEARCH=Yes
HONEYDBSERVICE_MEMCACHED=Yes
HONEYDBSERVICE_PROCONOS=Yes
```

### Configuration Options

The following options are supported in the `/etc/default/honeydb-agent` files:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The URL of the CHN Server used to register honeypot.
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events.  This is likely going to be the CHN management server.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port.  Default is 10000.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup.  This key is **required** for registration.
* HONEYDB_JSON: (string) The location to store the registration information returned from the HPFeeds server.
* HONEYDBSERVICE*: (Yes/No) Turn on or off services for HoneyDB-agent.  In containerized applications, this is _inside the container_, and the port can still be mapped to a different port on the host or not mapped in docker-compose to make a service unavailable.
* HONEYDB_ENABLED: (Yes/No) Enable logging of data to honeydb.io. Highly encouraged to support their efforts!
* HONEYDB_APIID: (string) API ID you receive once signing up at https://honeydb.io
* HONEYDB_APIKEY: (string) API Secret you receive once signing up at https://honeydb.io
* TAGS: (string) Comma delimited string for honeypot-specific tags. Tags must be separated by a comma to be parsed properly. 
**TAGS** string must be enclosed in double quotes if string contains spaces.

You can find detailed information on the honeydb-agent, it's configuration, and it's plugins at the [honeydb-agent documentation](https://honeydb-agent-docs.readthedocs.io/en/latest/configuration/) 

## Running honeydb-agent on port 22

By default honeydb-agent will run on port 2222, to avoid any conflict with the real SSH or Telnet services on the machine. If you wish to run the honeypot on port 22, you need to move the real SSH service to a new port. This is outside the scope of our documentation, but would look generally like:

* Edit `/etc/ssh/sshd_config` and change the `Port 22` stanza to your desired port, such as `Port 2022`.
* Restart the SSH daemon `sudo systemctl restart ssh.service`
* Ensure the SSH daemon is running `sudo systemctl status ssh.service` and look for "Active: active (running)"
* From a NEW terminal, try to SSH to your new port, to ensure your config is working
* (Optional) Disconnect from your exiting SSH session(s)
* Edit the `docker-compose.yml` file to expose the standard SSH port:
```
version: '3'
services:
  honeydb-agent:
    image: stingar/honeydb-agent:1.9.2
    restart: always
    volumes:
      - configs:/etc/honeydb-agent
    ports:
      - "22:22222"
    env_file:
      - honeydb-agent.env
volumes:
    configs:
```
* **DO NOT** edit the `honeydb-agent.env` file and change the port unless absolutely required; let Docker handle the
 translation
* Restart the container:
```
docker-compose down && docker-compose up -d
```
 
## Acknowledgements

CommunityHoneyNetwork honeydb-agent container is an integration of [@honeydbio's honeydb-agent](https://github.com/honeydbio) honeydb-agent software and Threatstream's Modern Honey Network & HPFeeds work, among other contributors and collaborators.

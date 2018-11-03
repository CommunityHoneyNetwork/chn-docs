Dionaea Honeypot
================
The CommunityHoneyNetwork dionaea honeypot is an implementation of [@DinoTools's Dionaea](https://github.com/DinoTools/dionaea), configured to report logged attacks to the CommunityHoneyNetwork management server.

> "Dionaea's intention is to trap malware exploiting vulnerabilities exposed by services offerd to a network, the ultimate goal is gaining a copy of the malware."

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

## Example dionaea docker-compose.yml
```dockerfile
version: '2'
services:
  dionaea:
    image: stingar/dionaea:latest
    volumes:
      - ./dionaea.sysconfig:/etc/default/dionaea
      - ./dionaea/services-available/:/opt/dionaea/etc/dionaea/services-enabled/
      - ./dionaea/dionaea:/etc/dionaea/
    ports:
      - "21:21"
      - "23:23"
      - "69:69"
      - "80:80"
      - "123:123"
      - "135:135"
      - "443:443"
      - "445:445"
      - "1433:1433"
      - "1723:1723"
      - "1883:1883"
      - "1900:1900"
      - "3306:3306"
      - "5000:5000"
      - "5060:5060"
      - "5061:5061"
      - "11211:11211"
      - "27017:27017"
```

## Example dionaea.sysconfig file


Prior to starting, Dionaea will parse some options from `/etc/sysconfig/dionaea` for RedHat-based or `/etc/default/dionaea` for Debian-based systems or containers. The following is an example config file:

```
#
# This can be modified to change the default setup of the dionaea unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

CHN_SERVER="http://<IP.OR.NAME.OF.YOUR.CHNSERVER>"
DEPLOY_KEY=
DIONAEA_JSON="/etc/dionaea/dionaea.json"

# Network options
LISTEN_ADDRESSES="0.0.0.0"
LISTEN_INTERFACES="eth0"

# Service options
# blackhole, epmap, ftp, http, memcache, mirror, mongo, mqtt, mssql, mysql, pptp, sip, smb, tftp, upnp
SERVICES=(blackhole epmap ftp http memcache mirror mongo mqtt pptp sip smb tftp upnp)

# Logging options
HPFEEDS_ENABLED=true
FEEDS_SERVER="<IP.OR.NAME.OF.YOUR.HPFEEDS>"
FEEDS_SERVER_PORT=10000
```

### Configuration Options

The following options are supported in the `/etc/sysconfig/dionaea` and `/etc/default/dionaea` files:

* DEBUG: (boolean) Enable more verbose output to the console
* IP_ADDRESS: IP address of the host running the honeypot container
* CHN_SERVER: (string) The hostname or IP address of the CHN Server to register honeypot.
* DEPLOY_KEY: (string; REQUIRED) The deploy key provided by the feeds server administration for registration during the first startup. This key is **required** for registration.
* DIONAEA_JSON: (string) The path to write out the Dionaea registration information.
* LISTEN_ADDRESSES: (string) The IP address of the Dionaea network listener
* LISTEN_INTERFACES: (string) The hardware interfaces to listen on for Dionaea network connectivity
* SERVICES: (array of strings) The network services to enable for the Dionaea honeypot.
* HPFEEDS_ENABLED: (boolean) Enable the hpfeeds handler module
* FEEDS_SERVER: (string) The hostname or IP address of the HPFeeds server to send logged events.
* FEEDS_SERVER_PORT: (integer) The HPFeeds port. Default is 10000.

# Service Configuration

Note: Any time a configuration file is added, removed, or modified, either the dionaea service or the docker container must be restarted.

## Configuring Dionaea services

The honeypot services running on Dionaea are highly configurable. The default configurations can be used to detect that the server is acting as a honeypot. Therefore, modifying these configuration files is recommended.

After Dionaea has been started, these services can be edited by modifying the yaml files in `./dionaea/services-enabled/`

There are many options for each service, so we recommend referencing the official [Dionaea documentation for services](http://dionaea.readthedocs.io/en/latest/service/index.html).

## Enabling Dionaea services

To enable a new service after Dionaea has been built, you can run the following command to enable the service:

    $ docker-compose exec dionaea cp /opt/dionaea/etc/dionaea/services-available/<service_config> /opt/dionaea/etc/dionaea/services-enabled/

For example, to enable FTP:

    $ docker-compose exec dionaea cp /opt/dionaea/etc/dionaea/services-available/ftp.yaml /opt/dionaea/etc/dionaea/services-enabled/

Current Dionaea services available:

* blackhole.yaml
* epmap.yaml
* ftp.yaml
* http.yaml
* memcache.yaml
* mirror.yaml
* mongo.yaml
* mqtt.yaml
* mssql.yaml
* mysql.yaml
* pptp.yaml
* sip.yaml
* smb.yaml
* tftp.yaml
* upnp.yaml


## Disabling Dionaea services

If you wish to remove a service from the dionaea honeypot, you can simply delete the corresponding yaml file from `./dionaea/services-enabled/`, and remove the relevant service from dionaea.sysconfig.

# Acknowlegements

CommunityHoneyNetwork Dionaea is an adaptation of [@DinoTools' Dionaea](https://github.com/DinoTools/dionaea/) Dionaea software and [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) Dionaea & HPFeeds work, among other contributors and collaborators.

# License

Dionaea is licensed under the [GNU GENERAL PUBLIC LICENSE Version 2.0](https://raw.githubusercontent.com/DinoTools/dionaea/master/LICENSE)

The ThreatStream implementation of Dionaea with HPFeeds, upon which CommunityHoneyNetwork is based is licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/threatstream/mhn/master/LICENSE)

The [CommunityHoneyNetwork Dionaea deployment model and code](https://github.com/CommunityHoneyNetwork/dionaea) is therefore also licensed under the [GNU LESSER GENERAL PUBLIC LICENSE Version 2.1](https://raw.githubusercontent.com/CommunityHoneyNetwork/dionaea/master/LICENSE)

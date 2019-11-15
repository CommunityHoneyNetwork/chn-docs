CHN Server Install
=================

Deploy a honeypot management server and sample honeypot in minutes.  

This guide will deploy all the containers for the server on a single host using a default configuration.  The honeypot can be deployed on the same host or a separate host as desired.

If you'd like to deploy the server across multiple servers or modify the default configuration, or do other fun things, check out the [Advanced Configuration Guide](config.md).

## Prerequisites

Please see the [prerequisites](prerequisite.md) page, regardless of which way you choose to install the server!

## Deploying the Server, the quickstart way

To ease installation, you can bootstrap a basic install of CHN using the [quickstart](https://github.com/CommunityHoneyNetwork/chn-quickstart) guide.

First, clone the quickstart repository into an install location; we will presume `/opt/chnserver` will be our install
 location.

```bash
sudo mkdir -p /opt && sudo git clone https://github.com/CommunityHoneyNetwork/chn-quickstart.git /opt/chnserver
```
Enter the Quickstart directory:
```bash
cd /opt/chnserver
```
Run the Quickstart process:
```bash
./guided_docker_compose.py
```

Once the process launches, you will be asked a series of questions. Answer each question to complete the Quickstart
 process.

### Question: Domain for CHN Server ###

```bash
Please enter the domain for your CHN Instance.  Note that this must be a resolvable domain.
Domain:
```
Enter the FQDN for your CHN Server, such as `chn.myorg.com`. The process will attempt to validate that this domain is
 in a valid format. This is the domain that will be later used to spin up the web server for CHN.
 
### Question: Certificate Strategy ###

```bash
Please enter a Certificate Strategy.  This should be one of:

CERTBOT: Signed certificate by an ACME provider such as LetsEncrypt.  Most folks will want to use this.  You must ensure your URL is accessible from the ACME hosts for verification here
BYO: Bring Your Own.  Use this if you already have a signed cert, or if you want a real certificate without CertBot
SELFSIGNED: Generate a simple self-signed certificate
Certificate Strategy:
```
Please see the [section on certificates](certificates.md) for more details on what the different strategies imply
. Using the `CERTBOT` strategy is preferred, followed by `BYO` and finally `SELFSIGNED`.

After this question is complete, an initial `chnserver.sysconfig` file will be written out to disk.

### Question: Days of Honeypot Data
```bash
How many days of honeypot data should be maintained in the database (default 30 days)?
Number of Days:
```
Here you can set how long you'd like to maintain honeypot data in the mongo database. We recommend keeping this
number relatively low (such as 14 or 30 days), and relying on the [logging mechanisms](hpfeeds-logger.md) to create
a long-term archive.

After this question is complete, an initial `mnemosyne.sysconfig` file will be written out to disk.

### Question: Remote CIFv3 logging ###
```bash
Do you wish to enable logging to a remote CIFv3 server? [y/N]: 
```
If you don't know what a [CIF server](https://github.com/csirtgadgets/bearded-avenger) is, or don't have one
 available, answer `n` or hit enter.

If you have a CIF server you wish indicators (IP, hash, url) from your honeypots to be submitted to (such as the
 [STINGAR project](https://stingar.security.duke.edu), answer `y` to this question. 

If you answer `y` to this question, you will be presented with two followup questions:
```bash
Please enter the URL for the remote CIFv3 server:
```
Be sure to include the HTTP scheme (i.e., `https://`) as part of the URL. 
```bash
Please enter the API token for the remote CIFv3 server:
```
This token must have write privileges to the remote CIF instance.

After this question is complete, an initial `hpfeeds-cif.sysconfig` file will be written out to disk. For additional
 information about this container and its configuration, please look at the [CIF documentation](hpfeeds-cif.md).

### Question: local file logging ###
```bash
Do you wish to enable logging to a local file? [y/N]:
```
If you do not want local file logging answer `n` or hit enter. You probably DO want this logging!

If you answer `y` to this question, you will be presented with one followup question:
```bash
splunk: Comma delimited key/value logging format for use with Splunk
json: JSON formatted log format
arcsight: Log format for use with ArcSight SIEM appliances
json_raw: Raw JSON output from hpfeeds. More verbose that other formats, but also not normalized. Can generate a large amount of data.
Logging Format:
```
Here you must enter one of `splunk`, `json`, `arcsight`, or `raw_json`. logging formats. Please consult the [logging
 documentation](hpfeeds-logger.md) for details on this format.

After this question is complete, an initial `hpfeeds-logger.sysconfig` file will be written out to disk.

### Final considerations ###
This will end the `guided_docker_compose.py` process. At this point there should be a valid docker-compose.yml file
 in the current directory (`./docker-compose.yml`), and valid config file in`./config/sysconfig/` for `chnserver.sysconfig` 
 and optionally `hpfeeds-cif.sysconfig`, `mnemosyne.sysconfig`, and `hpfeeds-logger.sysconfig`. 
 
At this point you can either add additional configuration to the sysconfig files in `./config/sysconfig` or start the
 server with:
```bash
docker-compose up -d
```
This command will download the pre-built images from hub.docker.com, and start containers using these images.

Verify your server is running with `docker-compose ps`:

```
$ docker-compose ps
        Name                    Command           State           Ports         
--------------------------------------------------------------------------------
chnserver_chnserver_1   /sbin/runsvdir -P         Up      0.0.0.0:443->443/tcp
                        /etc/service                      , 0.0.0.0:80->80/tcp  
chnserver_hpfeeds_1     /sbin/runsvdir -P         Up      10000/tcp             
                        /etc/service                                            
chnserver_mnemosyne_1   /sbin/runsvdir -P         Up      8181/tcp              
                        /etc/service                                            
chnserver_mongodb_1     /sbin/runsvdir -P         Up      27017/tcp             
                        /etc/service                                            
chnserver_redis_1       /sbin/runsvdir -P         Up      6379/tcp              
                        /etc/service 
```                        

To continue access the CHN Server web interface, you will need the administrator account credentials.

The `guided_docker_compose.py` file will generate a long random password, which is stored in `./config/sysconfig/chnserver.sysconfig` in the SUPERUSER_PASSWORD variable.

Run the following to display the superuser name and password:
```bash
grep SUPERUSER /opt/chnserver/config/sysconfig/chnserver.sysconfig
```

You may log into the web interface for your new honeypot management server.  In a browser, navigate to `http://<your.host.name>`.  

You should be able to login using the `admin@localhost` account and the password you just found. If you need to reset
 the password, simply change the password in the `chnserver.sysconfig` file and re-deploy the images with:
```bash
docker-compose down && docker-compose up -d
```

At this point you have a functioning CommunityHoneyNetwork server, ready to register honeypots and start collecting data.  Next, try [deploying your first honeypot](firstpot.md)...

## Deploying the Server, manually

If you've already done the Quickstart method, please skip this section!

Create a new directory to hold your server deployment:

    $ mkdir -p /opt/chnserver
    $ cd /opt/chnserver
    
Copy the following chnserver.sysconfig variables file, and save it as 
`chnserver.sysconfig`:

_Be sure to set SERVER_BASE_URL appropriately!_ This setting supports custom paths such as `https://www.site.tld/chn` which is helpful if running behind an Application Load Balancer (see [Deploying to Cloud Providers](cloud.md)).

```
# This file is read from /etc/default/chnserver
#
# This can be modified to change the default setup of the chnserver unattended installation

DEBUG=false

EMAIL=admin@localhost
# For TLS support, you MUST set SERVER_BASE_URL to "https://your.site.tld"
SERVER_BASE_URL='https://CHN.SITE.TLD'
HONEYMAP_URL=''
REDIS_URL='redis://redis:6379'
MAIL_SERVER='127.0.0.1'
MAIL_PORT=25
MAIL_TLS='y'
MAIL_SSL='y'
MAIL_USERNAME=''
MAIL_PASSWORD=''
DEFAULT_MAIL_SENDER=''
MONGODB_HOST='mongodb'
MONGODB_PORT=27017
HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000

SUPERUSER_EMAIL=''
SUPERUSER_PASSWORD=''
SECRET_KEY=''
DEPLOY_KEY=''

# See https://communityhoneynetwork.readthedocs.io/en/stable/certificates/
# Options are: 'CERTBOT', 'SELFSIGNED', 'BYO'
CERTIFICATE_STRATEGY='CERTBOT'
```

__Please Note!__

If you cannot or do not want to use LetsEncrypt to get a valid certificate for this instance, please consult the 
documentation on [certificates with CHN](certificates.md) before bringing up your container. It is best to ensure 
your certificates are in place before starting up CHN for the first time when not using Let's Encrypt.

With no additional configuration, the CHN Server will keep only 30 days of data in the mongo database. In order to
 adjust this limit, add a new file called `mnemosyne.sysconfig` with the following contents:
 
```bash
# This file is read from /etc/default/mnemosyne
# This can be modified to change the default setup of the unattended installation
HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000
MONGODB_HOST='mongodb'
MONGODB_PORT=27017

# MONGODB_INDEXTTL sets the number of seconds to keep data in the mongo database
# This default value is 30 days
MONGODB_INDEXTTL=2592000

# Use this setting to 'True' to not log RFC1918 addresses to the mongo database.
IGNORE_RFC1918=False
```

__Please Note!__ The value for the timeout is in *seconds*. 

Copy the following Docker Compose yaml, and save it as `docker-compose.yml`:


```
version: '2'
services:
  mongodb:
    image: stingar/mongodb:1.8
    volumes:
      - ./storage/mongodb:/var/lib/mongo:z
  redis:
    image: stingar/redis:1.8
    volumes:
      - ./storage/redis:/var/lib/redis:z
  hpfeeds:
    image: stingar/hpfeeds:1.8
    links:
      - mongodb:mongodb
    ports:
      - "10000:10000"
  mnemosyne:
    image: stingar/mnemosyne:1.8
    links:
      - mongodb:mongodb
      - hpfeeds:hpfeeds
    volumes:
      - ./mnemosyne.sysconfig:/etc/default/mnemosyne:z
  chnserver:
    image: stingar/chn-server:1.8
    restart: always
    volumes:
      - ./config/collector:/etc/collector:z
      - ./storage/chnserver/sqlite:/opt/sqlite:z
      - ./chnserver.sysconfig:/etc/default/chnserver:z
      - ./certs:/tls:z
    links:
      - mongodb:mongodb
      - redis:redis
      - hpfeeds:hpfeeds
    ports:
      - "80:80"
      - "443:443"
```

Once you have saved your `docker-compose.yml` file, you start up your new server with:

    docker-compose up -d

This command will download the pre-built images from hub.docker.com, and start containers using these images.

Verify your server is running with `docker-compose ps`:

```
$ docker-compose ps
        Name                    Command           State           Ports         
--------------------------------------------------------------------------------
chnserver_chnserver_1   /sbin/runsvdir -P         Up      0.0.0.0:443->443/tcp
                        /etc/service                      , 0.0.0.0:80->80/tcp  
chnserver_hpfeeds_1     /sbin/runsvdir -P         Up      10000/tcp             
                        /etc/service                                            
chnserver_mnemosyne_1   /sbin/runsvdir -P         Up      8181/tcp              
                        /etc/service                                            
chnserver_mongodb_1     /sbin/runsvdir -P         Up      27017/tcp             
                        /etc/service                                            
chnserver_redis_1       /sbin/runsvdir -P         Up      6379/tcp              
                        /etc/service 
```                        

To continue access the CHN Server web interface, you will need the administrator account credentials.

By default, CHN will create a random admin credential. To reset the default admin account (admin@localhost) password
 from the auto-generated one-time password you can reset the password using the command:

    docker-compose exec chnserver python /opt/manual_password_reset.py

For example:

```
$ docker-compose exec chnserver python /opt/manual_password_reset.py
Enter email address: admin@localhost
Enter new password:
Enter new password (again):
user found, updating password
```

You can now log into the web interface for your new honeypot management server.  In a browser, navigate to `http://<your.host.name>`, using the hostname or IP of the host where the Docker containers are running.  

You should be able to login using the `admin@localhost` account and the password you just set.

Please know that this administrator password will be reset every time a container instance is re-deployed from the
 image. If you would like to keep the same administrator password, please populate the `SUPERUSER_EMAIL` and
  `SUPERUSER_PASSWORD` fields in chnserver.sysconfig. Similarly, you can force a static `DEPLOY_KEY`. 

You may also wish to configure logging for your CHN Server instance at this time as well. Please see [this section](hpfeeds-logger.md)
for more information on configuring logging.

At this point you have a functioning CommunityHoneyNetwork server, ready to register honeypots and start collecting data.  Next, try [deploying your first honeypot](firstpot.md)...

QuickStart Guide
=================

Deploy a honeypot management server and sample honeypot in seconds.  This guide will deploy all the containers for the server on a single host using a default configuration.  The honeypot can be deployed on the same host or a separate host as desired.

If you'd like to deploy the server across multiple servers or modify the default configuration, or do other fun things, check out the [Advanced Configuration Guide](config.md).

## Prerequisites

The default deployment model uses Docker and Docker Compose to deploy containers for the project's tools, and so, require the following:

* Docker >= 1.13.1
* Docker Compose >= 1.15.0

## Deploying the Server

Create a new directory to hold your server deployment:

    $ mkdir chnserver
    $ cd chnserver
    
Copy the following chnserver.sysconfig variables file, and save it as 
`chnserver.sysconfig`:

_Be sure to set SERVER_BASE_URL appropriately!_

```
# This file is read from /etc/sysconfig/chnserver or /etc/default/chnserver
# depending on the base distro
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
```
Copy the following Docker Compose yaml, and save it as `docker-compose.yml`:


```
version: '2'
services:
  mongodb:
    image: stingar/mongodb:latest
    volumes:
      - ./storage/mongodb:/var/lib/mongo:z
  redis:
    image: stingar/redis:latest
    volumes:
      - ./storage/redis:/var/lib/redis:z
  hpfeeds:
    image: stingar/hpfeeds:latest
    links:
      - mongodb:mongodb
    ports:
      - "10000:10000"
  mnemosyne:
    image: stingar/mnemosyne:latest
    links:
      - mongodb:mongodb
      - hpfeeds:hpfeeds
  chnserver:
    image: stingar/chn-server:latest
    volumes:
      - ./config/collector:/etc/collector:z
      - ./storage/chnserver/sqlite:/opt/sqlite:z
      - ./chnserver.sysconfig:/etc/default/chnserver:z
      - ./certs:/etc/letsencrypt:z
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

When you're ready, the server can be stopped by running `docker-compose down`.  For now, to continue with the setup, reset the default admin account (admin@localhost) password from the auto-generated one-time password. 

You can reset the password using the command:

    docker-compose exec chnserver python /opt/manual_password_reset.py

For example:

```
$ docker-compose exec chnserver python /opt/manual_password_reset.py
Enter email address: admin@localhost
Enter new password:
Enter new password (again):
user found, updating password
```

You can now log into the web interface for your new honeypot management server.  In a browser, navigate to `http://<your.host.name>`, using the hostname or IP of the host where the Docker containers are running.  You should be able to login using the `admin@localhost` account and the password you just set.

## Next Steps

At this point you have a functioning CommunityHoneyNetwork server, ready to register honeypots and start collecting data.  Next, try [deploying your first honeypot](firstpot.md)...

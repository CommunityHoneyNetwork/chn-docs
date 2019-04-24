Advanced Configuration
======================

Each of the services and honeypots in the CommunityHoneyNetwork project should work together out of the box following
 the [CHN Server Install](serverinstall.md). More advanced configuration options can be configured using an 
 /etc/default/<servicename> file for Ubuntu-based systems.

Services running in Docker containers can be configured this way as well, mounting the configuration files into place using the `--volume` argument for Docker.

Using Docker/docker-compose, each of the containers can share a single sysconfig file, mounted into the appropriate location for each.  Options not appropriate for each particular service are just unused.

The following is an example of a shared configuration file, using default values:

```
# CHN Server options
CHNSERVER_DEBUG=false

EMAIL=admin@localhost
HONEYMAP_URL=''
SERVER_BASE_URL='https://CHN.SITE.TLD'
MAIL_SERVER='127.0.0.1'
MAIL_PORT=25
MAIL_TLS='y'
MAIL_SSL='y'
MAIL_USERNAME=''
MAIL_PASSWORD=''
DEFAULT_MAIL_SENDER=''
CERTIFICATE_STRATEGY='CERTBOT'

# Redis config options
REDIS_URL='redis://redis:6379'

# MongoDB config options
MONGODB_HOST='mongodb'
MONGODB_PORT=27017

# HPfeeds config options
HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000

# Mnemosyne config options
IGNORE_RFC1918=False
```

# Building docker containers from source

We recommend using the pre-built docker images on hub.docker.com for building CHN Server and honeypots. However, there may be circumstances where you wish to build your own docker images from source.

To build from source as opposed to from an image, simply add the following lines before the `image` tag under the service name in your `docker-compose.yml` file:

```
    build:
      dockerfile: ./Dockerfile-centos
      context: https://github.com/CommunityHoneyNetwork/<repo_name>.git#<version_tag>
```

For example, if you wish to build CHN Server from source, your docker-compose file will look like the following:

```
version: '2'
services:
  mongodb:
    build:
      dockerfile: ./Dockerfile-ubuntu
      context: https://github.com/CommunityHoneyNetwork/mongodb.git#v1.5
    image: mongodb:centos
    volumes:
      - ./storage/mongodb:/var/lib/mongo:z
  redis:
    build:
      dockerfile: ./Dockerfile-ubuntu
      context: https://github.com/CommunityHoneyNetwork/redis.git#v1.5
    image: redis:centos
    volumes:
      - ./storage/redis:/var/lib/redis:z
  hpfeeds:
    build:
      dockerfile: ./Dockerfile-ubuntu
      context: https://github.com/CommunityHoneyNetwork/hpfeeds.git#v1.5
    image: hpfeeds:centos
    links:
      - mongodb:mongodb
    ports:
      - "10000:10000"
  mnemosyne:
    build:
      dockerfile: ./Dockerfile-ubuntu
      context: https://github.com/CommunityHoneyNetwork/mnemosyne.git#v1.5
    image: mnemosyne:centos
    links:
      - mongodb:mongodb
      - hpfeeds:hpfeeds
  chnserver:
    build:
      dockerfile: ./Dockerfile-ubuntu
      context: https://github.com/CommunityHoneyNetwork/CHN-Server.git#v1.5
    image: chnserver:centos
    volumes:
      - ./config/collector:/etc/collector:z
    links:
      - mongodb:mongodb
      - redis:redis
      - hpfeeds:hpfeeds
    ports:
      - "80:80"
```

Build the Docker images for the containers that make up the server:

```
$ docker-compose build
```

Once the images are built, you start up your new server with:

```
$ docker-compose up -d
```

# Accepting all traffic from a default route

There are occassions where you would like for your honeypot host to accept
traffic from a large network, instead of just the IP address that has been
assigned to your NIC.  In order to do this, you can use the AnyIP linux kernel
feature.  Once traffic is being routed to your server, create a systemd service
file with the contents below.  This example uses `192.168.1.1/24` as the target
network, and should be changed accordingly

`/etc/systemd/system/anyip-hp.service`

```
[Unit]
Description=Enable AnyIP for my HP
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/ip addr add 192.168.1.1/24 dev lo
ExecStop=/sbin/ip addr del 192.168.1.1/24 dev lo
StandardOutput=journal

[Install]
WantedBy=multi-user.target
```

Enable the service with:
```
$ sudo systemctl enable anyip-hp.service
$ sudo systemctl start anyip-hp.service
```

If this worked correctly, you will see the new network you added in the output of

```
$ sudo ip addr show lo
```

The service can be stopped with:
```
$ sudo systemctl stop anyip-hp.service
```

Advanced Configuration
======================

Each of the services and honeypots in the CommunityHoneyNetwork project should work together out of the box following
 the [CHN Server Install](serverinstall.md). More advanced configuration options can be configured by modifying the
  env file associated with the container.


# Building docker containers from source

We recommend using the pre-built docker images on hub.docker.com for building CHN Server and honeypots. However, there may be circumstances where you wish to build your own docker images from source.

To build from source as opposed to from an image, simply add the following lines before the `image` tag under the service name in your `docker-compose.yml` file:

```
    build:
      dockerfile: ./Dockerfile
      context: https://github.com/CommunityHoneyNetwork/<repo_name>.git#<version_tag>
```

For example, if you wish to build CHN Server from source, your docker-compose file will look like the following:

```
version: '3'
services:
  mongodb:
    image: mongo:3.4.24-xenial
    volumes:
      - ./storage/mongodb:/data/db:z

  redis:
    image: redis:alpine
    volumes:
      - ./storage/redis:/data:z

  hpfeeds3:
    build:
      dockerfile: ./Dockerfile
      context: https://github.com/CommunityHoneyNetwork/hpfeeds3.git#v1.9.1
    image: hpfeeds:latest
    links:
      - mongodb:mongodb
    ports:
      - "10000:10000"
  mnemosyne:
    build:
      dockerfile: ./Dockerfile
      context: https://github.com/CommunityHoneyNetwork/mnemosyne.git#v1.9.1
    image: mnemosyne:latest
    env_file:
      - ./mnemosyne.env
    links:
      - mongodb:mongodb
      - hpfeeds3:hpfeeds3
  chnserver:
    build:
      dockerfile: ./Dockerfile
      context: https://github.com/CommunityHoneyNetwork/CHN-Server.git#v1.9.1
    image: chnserver:latest
    volumes:
      - ./config/collector:/etc/collector:z
      - ./storage/chnserver/sqlite:/opt/sqlite:z
      - ./certs:/etc/letsencrypt:z
    env_file:
      - ./chnserver.env
    ports:
      - "80:80"
      - "443:443"
```
The above config will build docker images from the v1.9.1 tagged version of CHN. You can change the URL to point to
 specific tagged releases or even specific commits to build from those instead. 
 
If you wish to make code changes, you can either fork the projects to your own repos and specify those URLs in the
 context, or download the repos locally and specify their location. 
 
Build the Docker images for the containers that make up the server:

```
$ docker-compose build
```

Once the images are built, you start up your new server with:

```
$ docker-compose up -d
```

# Accepting all traffic from a default route

There are occasions where you would like for your honeypot host to accept
traffic from a large network, instead of just the IP address that has been
assigned to your NIC. One way to do this is to use the AnyIP linux kernel
feature.  Once traffic is being routed to your server, create a systemd service
file with the contents below.  This example uses `192.168.1.1/24` as the target
network you wish the host to accept traffic for, and should be changed accordingly:

`/etc/systemd/system/anyip-hp.service`

```
[Unit]
Description=Enable AnyIP for my Honeypots
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

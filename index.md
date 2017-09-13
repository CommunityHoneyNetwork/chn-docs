CommunityHoneyNetwork
=====================

Honeypot deployment and management automation

## Simple management server deployment for your platform

```
curl -sSL https://gist.github.com/clcollins/452bca577bbcd2f9436843239f57179d -o docker-compose.yml && sudo docker-compose up
```

Ok, ok, that's scary.  How about a docker-compose file instead:

```
version: '2'
services:
  mongodb:
    build:
      dockerfile: ./Dockerfile-centos
      context: https://github.com/CommunityHoneyNetwork/mongodb.git
    image: mongodb:centos
    ports:
      - "127.0.0.1:27017:27017"
    volumes:
      - /srv/chn/db/centos:/var/lib/mongo:z
  redis:
    build:
      dockerfile: ./Dockerfile-centos
      context: https://github.com/CommunityHoneyNetwork/redis.git
    image: redis:centos
    ports:
      - "127.0.0.1:6379:6379"
    volumes:
      - /srv/chn/redis/centos:/var/lib/redis:z
  hpfeeds:
    build:
      dockerfile: ./Dockerfile-centos
      context: https://github.com/CommunityHoneyNetwork/hpfeeds.git
    image: hpfeeds:centos
    links:
      - mongodb:mongodb
    ports:
      - "10000:10000"
  mnemosyne:
    build:
      dockerfile: ./Dockerfile-centos
      context: https://github.com/CommunityHoneyNetwork/mnemosyne.git
    image: mnemosyne:centos
    links:
      - mongodb:mongodb
      - hpfeeds:hpfeeds
    ports:
      - "127.0.0.1:8181:8181"
  chnserver:
    build:
      dockerfile: ./Dockerfile-centos
      context: https://github.com/CommunityHoneyNetwork/CHN-Server.git
    image: chnserver:centos
    links:
      - mongodb:mongodb
      - redis:redis
      - hpfeeds:hpfeeds
    ports:
      - "80:80"
      - "127.0.0.1:443:443"
```

Save this file, and run "docker-compose up" from the same directory.


Or, if you prefer, check out more [Advanced Deployment Options](), including running on multiple hosts, installing and running without Docker, and running in Amazon Webservices.

## Easy honeypot deployment and threat reporting

Get your first honeypot up and running!  

Insert cowrie here

## Contributing

How to contribute to this project!

## Acknologements

CommunityHoneyNetwork is an adaptation of [Threatstream's Modern Honey Network](https://threatstream.github.io/mhn/) project, and several other excellent projects by the [Honeynet Project](https://www.honeynet.org/).

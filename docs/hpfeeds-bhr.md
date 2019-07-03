hpfeeeds-bhr
=============
The hpfeeeds-bhr container, when added to a CHN-Server instance, will forward 
an "observation" of the malicious activity to a specified instance of NCSA BHR. You can read more about BHR [here](https://github.com/ncsa/bhr-site).

# Adding hpfeeeds-bhr to CHN-Server
The simplest way to integrate CHN reporting to BHR is to:

First, include this stanza in the docker-compose.yml file for CHN-server:
```dockerfile
  hpfeeds-bhr:
    image: stingar/hpfeeds-bhr:1.8
    volumes:
      - ./hpfeeds-bhr.sysconfig:/etc/default/hpfeeds-bhr:z
    links:
      - redis:redis
```
Next, add the following hpfeeeds-bhr.sysconfig configuration file:
```bash
# This file is read from /etc/default/hpfeeds-bhr
#
# Defaults here are for containers, but can be adjusted
# to customize the containers

HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000
IDENT=hpfeeds-bhr-${RANDOM}

MONGODB_HOST='mongodb'
MONGODB_PORT=27017

BHR_HOST='https://bhr'
BHR_TOKEN=''
BHR_VERIFY_SSL=False
BHR_TAGS=''

# Specify CIDR networks for which we should NOT submit to BHR
# Useful for not reporting any locally compromised hosts and prepopulated with RFC1918 addresses
IGNORE_CIDR="192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"

# Include the honeypot specific tags in the comment for BHR
INCLUDE_HP_TAGS=False
```
The `IGNORE_CIDR` option allow you to specify a set of ranges for which you wish hpfeeeds-bhr to ignore and NOT submit
 to the configured BHR server. This option comes pre-populated with RFC1918 addresses, and can be modified provided 
 the entry is quoted. 

Once the docker-compose.yml is updated and the hpfeeeds-bhr.sysconfig file is 
present, you can simply:

```bash
docker-compose down && docker-compose up -d
```
To examine logs of the transactions with the BHR instance, run:

```bash
docker-compose logs hpfeeeds-bhr
```

hpfeeeds-bhr
=============
The hpfeeeds-bhr container, when added to a CHN-Server instance, will forward 
an "observation" of the malicious activity to a specified instance of NCSA BHR. You can read more about BHR [here](https://github.com/ncsa/bhr-site).

# Adding hpfeeeds-bhr to CHN-Server
The simplest way to integrate CHN reporting to BHR is to:

First, include this stanza in the docker-compose.yml file for CHN-server:
```dockerfile
  hpfeeds-bhr:
    image: stingar/hpfeeds-bhr:1.9
    env_file:
      - hpfeeds-bhr.env
    links:
      - redis:redis
      - hpfeeds3:hpfeeds3
      - mongodb:mongodb
```
Next, add the following hpfeeeds-bhr.sysconfig configuration file:
```bash
 Defaults here are for containers, but can be adjusted to customize the containers
DEBUG=false

HPFEEDS_HOST=hpfeeds3
HPFEEDS_PORT=10000
IDENT=hpfeeds-bhr

MONGODB_HOST=mongodb
MONGODB_PORT=27017

BHR_HOST=https://bhr.edu
BHR_TOKEN={api-token}
BHR_VERIFY_SSL=True
BHR_TAGS=stingar-chn

# Specify CIDR networks for which we should NOT submit to BHR
# Useful for not reporting any locally compromised hosts and prepopulated with RFC1918 addresses
IGNORE_CIDR=192.168.0.0/16,172.16.0.0/12,10.0.0.0/8

# Include the honeypot specific tags in the comment for BHR
INCLUDE_HP_TAGS=False

# ADVANCED: Specify the Redis database number to use for caching BHR submissions. This is only necessary when
# running multiple BHR containers on the same host submitting to different instances. Note that hpfeeds-bhr defaults
# to using database 1 and hpfeeds-cif defaults to using database 2, so generally safe choices are in the range of 3-15.
BHR_CACHE_DB=1
```
The `IGNORE_CIDR` option allow you to specify a set of ranges for which you wish hpfeeeds-bhr to ignore and NOT submit
 to the configured BHR server. This option comes pre-populated with RFC1918 addresses, and can be modified to include
  your local IP ranges and sensitive external services. 

Once the docker-compose.yml is updated and the hpfeeeds-bhr.sysconfig file is 
present, you can simply:

```bash
docker-compose down && docker-compose up -d
```
To examine logs of the transactions with the BHR instance, run:

```bash
docker-compose logs hpfeeeds-bhr
```

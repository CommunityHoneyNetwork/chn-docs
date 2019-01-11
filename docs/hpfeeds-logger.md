hpfeeds-logger
=============
The hpfeeds-logger container, when added to a CHN-Server instance, will log a 
Splunk-friendly record of all attacks to a local log file.


# Adding hpfeeds-logger to CHN-Server
The simplest way to integrate CHN logging to a local file is to:

First, include this stanza in the docker-compose.yml file for CHN-server:
```dockerfile
  hpfeeds-logger:
    image: stingar/hpfeeds-logger:latest
    volumes:
      - ./hpfeeds-logger.sysconfig:/etc/default/hpfeeds-logger
      - ./hpfeeds-logs:/var/log/hpfeeds-logger:z
    links:
      - hpfeeds:hpfeeds
      - mongodb:mongodb
```
Next, add the following hpfeeds-logger.sysconfig configuration file:
```bash
# This file is read from /etc/sysconfig/hpfeeds-logger
# or /etc/default/hpfeeds-logger, depending on the distro version
#
# Defaults here are for containers, but can be adjusted
# after install for a regular server or to customize the containers

HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000

MONGODB_HOST='mongodb'
MONGODB_PORT=27017

# Log to local file
FILELOG_ENABLED=true
LOG_FILE=/var/log/hpfeeds-logger/chn-splunk.log

# Log to syslog
SYSLOG_ENABLED=false
SYSLOG_HOST=localhost
SYSLOG_PORT=514
SYSLOG_FACILITY=user

# Options are arcsight, json_formatter, raw_json, splunk
# This option will change all enabled output formats (file or syslog)
FORMATTER_NAME=splunk

```
Once the docker-compose.yml is updated and the hpfeeds-logger.sysconfig file is 
present, start logging with:

```bash
docker-compose down && docker-compose up -d
```
Note that the first half of the volume mount directive in docker-compose.yml 
determines where the log file will live on the host system. 

After startup (with the example configuration) you should see a new log file:

```bash
$ ls -l hpfeeds-logs
total 0
-rw-r--r-- 1 root root 0 Nov  2 22:15 chn-splunk.log
``` 

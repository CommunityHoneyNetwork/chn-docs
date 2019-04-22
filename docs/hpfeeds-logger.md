hpfeeds-logger
=============
The hpfeeds-logger container, when added to a CHN-Server instance, will log a 
Splunk-friendly record of all attacks to a local log file.


# Adding hpfeeds-logger to CHN-Server
The simplest way to integrate CHN logging to a local file is to:

First, include this stanza in the docker-compose.yml file for CHN-server:
```dockerfile
  hpfeeds-logger:
    image: stingar/hpfeeds-logger:1.7
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

MONGODB_HOST="mongodb"
MONGODB_PORT=27017

# Log to local file; the path is internal to the container and the host filesystem
# location is controlled by volume mapping in the docker-compose.yml
FILELOG_ENABLED="true"
LOG_FILE="/var/log/hpfeeds-logger/chn-splunk.log"

# Choose to rotate the log file based on 'size'(default) or 'time'
ROTATION_STRATEGY="size"

# If rotating by 'size', the number of MB to rotate at
ROTATION_SIZE_MAX=100

# If rotating by 'time', the number of hours to rotate at
ROTATION_TIME_MAX=24

# Log to syslog
SYSLOG_ENABLED=false
SYSLOG_HOST=localhost
SYSLOG_PORT=514
SYSLOG_FACILITY=user

# Options are arcsight, json, raw_json, splunk
FORMATTER_NAME=splunk

# To log data from an external HPFeeds stream, uncomment and fill out these
# variables. Additionally, change the HPFEEDS_* variables to point to the
# remote service.

IDENT=hpfeeds-logger-${RANDOM}
# SECRET=
# CHANNELS=

HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000
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
# Adding an external hpfeeds source for logging
This is a more advanced option, for those wishing to consume data from 
another hpfeeds instance (whether CHN-based or not). This example will step 
through the requirements for enabling this feature.

## On the sending side
The hpfeeds protocol requires 5 pieces of information in order to generate or
 share information: host, port, ident, secret, and channel listing. On the 
 sending side, we must provision an ident, secret, and channels that may be 
 subscribed to. We use the "add_user.py" script to do this. If we wanted to 
 provision an ident of "ident" with a secret of "secret" (this is a bad idea 
 btw), we would run:

```bash
docker-compose exec hpfeeds python /opt/hpfeeds/broker/add_user.py "ident" "secret" "" "amun.events,conpot.events,thug.events,beeswarm.hive,dionaea.capture,dionaea.connections,thug.files,beeswarn.feeder,cuckoo.analysis,kippo.sessions,cowrie.sessions,glastopf.events,glastopf.files,mwbinary.dionaea.sensorunique,snort.alerts,wordpot.events,p0f.events,suricata.events,shockpot.events,elastichoney.events,rdphoney.sessions,uhp.events"
```
Please note that the empty double quotes are necessary to indicate that the 
identity may not publish to any channels (unless that's something you want), 
and the last quoted text is all the channels that a CHN instance of hpfeeds 
will provision. Other instances may not have these channels available, or may
 not wish to share data in those channels. 
 
The sending side should now share the host, hpfeeds port, ident, secret, and 
channel listing with the side which wishes to consume the data.

## On the receiving side
One one has the host, hpfeeds port, ident, secret, and channel listing, 
create a new hpfeeds-logger container in your docker-compose and fill out the
 fields in a new hpfeeds-logger.sysconfig. for example if our friend made 
 the cowrie.sessions channel available to us from their host 10.0.0.10 with an 
 ident of "myfriend" and 
 secret of "p0nyf!3nds4lyfe", our sysconfig file would look like:

```bash
# This file is read from /etc/sysconfig/hpfeeds-cif
# or /etc/default/hpfeeds-logger, depending on the distro version
#
# Defaults here are for containers, but can be adjusted
# after install for a regular server or to customize the containers

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
FORMATTER_NAME=splunk

# To log data from an external HPFeeds stream, uncomment and fill out these
# variables. Additionally, change the HPFEEDS_* variables to point to the
# remote service.

IDENT="myfriend"
SECRET="p0nyf!3nds4lyfe"
CHANNELS="cowrie.sessions"

HPFEEDS_HOST='10.0.0.10'
HPFEEDS_PORT=10000
```
**Please Note:** Configuring channels that are not available, or not allowed 
for the user will cause the hpfeeds-logger container to die (repeatedly). 
The current code does not account for a failure to authenticate to a single 
channel, and simply fails the entire transaction.

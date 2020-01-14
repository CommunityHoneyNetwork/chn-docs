chn-intel-feeds
=============
The chn-intel-feeds container will automatically download indicators from a specified Collective 
Intelligence Framework (CIF) instance. You can read more about CIF [here](https://csirtgadgets.com/collective-intelligence-framework/). 

The downloaded indicators will be formatted to a 'single indicator per line' format, and served up over HTTP on 
(default) port 9000. These feeds will be refreshed automatically, and are in a format easily consumed by protection 
devices such as Palo Alto EDL's or Cisco Firepower SI Lists. 

# Adding chn-intel-feeds to CHN-Server
The simplest way to integrate feeds is:

First, include this stanza in the `docker-compose.yml` file for CHN-server:
```dockerfile
  chn-intel-feeds:
    image: stingar/chn-intel-feeds:1.8
    ports:
      - 9000:9000
    env_file:
      - chn-intel-feeds.env
```
Next, add the following `chn-intel-feeds.env` configuration file:
```bash
# Turn on additional logging
DEBUG=false

# Number of minutes between each refresh of the feeds
SLEEP=60

# Change the port the web server listens on in the container
# You must also adjust the docker-compose ports stanza to match
PORT=9000

# Specify feeds by prefacing each variable with "CHNFEEDX" where "X" is the feed number
# A minimal configuration includes: FILENAME, REMOTE, TOKEN, ITYPE, TAGS, and DAYS or HOURS
# You are limited to 30 feed specifications; this limit can be changed in code
# Any of the VALID_FILTERS may be used as part of the specification
# VALID_FILTERS = ['indicator', 'itype', 'confidence', 'provider', 'limit', 'application', 'nolog', 'tags', 'days',
#                 'hours', 'groups', 'reporttime', 'cc', 'asn', 'asn_desc', 'rdata', 'firsttime', 'lasttime',
#                 'region', 'id']

CHNFEED1_FILENAME="stingar_ip.txt"
CHNFEED1_REMOTE="https://cif.site"
CHNFEED1_TOKEN="bigrandomtokenhere"
CHNFEED1_TLS_VERIFY="False"
CHNFEED1_ITYPE="ipv4"
CHNFEED1_LIMIT="150000"
CHNFEED1_HOURS="96"
CHNFEED1_CONFIDENCE="8"
CHNFEED1_TAGS="honeypot"

CHNFEED2_FILENAME="stingar_sha256.txt"
CHNFEED2_REMOTE="https://cif.site"
CHNFEED2_TOKEN="bigrandomtokenhere"
CHNFEED2_TLS_VERIFY="False"
CHNFEED2_ITYPE="sha256"
CHNFEED2_LIMIT="1000"
CHNFEED2_DAYS="4"
CHNFEED2_CONFIDENCE="8"
CHNFEED2_TAGS="honeypot"

CHNFEED3_FILENAME="stingar_url.txt"
CHNFEED3_REMOTE="https://cif.site"
CHNFEED3_TOKEN="bigrandomtokenhere"
CHNFEED3_TLS_VERIFY="False"
CHNFEED3_ITYPE="url"
CHNFEED3_LIMIT="1000"
CHNFEED3_DAYS="4"
CHNFEED3_CONFIDENCE="8"
CHNFEED3_TAGS="honeypot"
```
The .env file may contain up to 30 feed specifications. 

The `FILENAME`, `REMOTE`, `TOKEN`, `ITYPE`, `TAGS`, and a time specification (such as `DAYS` or `HOURS`) are required 
for all feed specifications. Other items may be specified, and will otherwise default to the values as defined in the 
upstream [CIF Python SDK](https://github.com/csirtgadgets/bearded-avenger-sdk-py/wiki).

It is worth noting that **there is NO safelisting** for feeds performed by this container; any safelisting must be 
done on the upstream CIF server or post-processed by any clients pullling from this container. 

Once the docker-compose.yml is updated and the chn-intel-feeds.env file is 
present, you can simply:

```bash
docker-compose down && docker-compose up -d
```
To examine logs of the chn-intel-feeds instance, run:

```bash
docker-compose logs chn-intel-feeds
```


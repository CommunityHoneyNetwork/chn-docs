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
    image: stingar/chn-intel-feeds:1.9
    env_file:
      - chn-intel-feeds.env
    volumes:
      - ./safelists:/var/www/safelists
    ports:
      - 9000:9000
```
Next, add the following `chn-intel-feeds.env` configuration file:
```bash
# Turn on additional logging
DEBUG=false

# Number of minutes between each refresh of the feeds
SLEEP=5

# Number of hours between each refresh of the safelist
SAFELIST_SLEEP=24

# Change the port the web server listens on in the container
# You must also adjust the docker-compose ports stanza to match
PORT=9000

# Specify feeds by prefacing each variable with "CHNFEEDX" where "X" is the feed number
# A minimal configuration includes: FILENAME, REMOTE, TOKEN, ITYPE, TAGS, and DAYS or HOURS
# You are limited to 10 feed specifications; this limit can be changed in code
# Any of the VALID_FILTERS may be used as part of the specification
# VALID_FILTERS = ['indicator', 'itype', 'confidence', 'provider', 'limit', 'application', 'nolog', 'tags', 'days',
#                 'hours', 'groups', 'reporttime', 'cc', 'asn', 'asn_desc', 'rdata', 'firsttime', 'lasttime',
#                 'region', 'id']

CHNFEED1_FILENAME=stingar_ip.txt
CHNFEED1_REMOTE={cif_server_url}
CHNFEED1_TOKEN={cif_read_token}
CHNFEED1_TLS_VERIFY=True
CHNFEED1_ITYPE=ipv4
CHNFEED1_LIMIT=10
CHNFEED1_HOURS=24
CHNFEED1_CONFIDENCE=8
CHNFEED1_TAGS=honeypot

CHNFEED2_FILENAME=stingar_sha256.txt
CHNFEED2_REMOTE={cif_server_url}
CHNFEED2_TOKEN={cif_read_token}
CHNFEED2_TLS_VERIFY=True
CHNFEED2_ITYPE=sha256
CHNFEED2_LIMIT=10
CHNFEED2_DAYS=1
CHNFEED2_CONFIDENCE=8
CHNFEED2_TAGS=honeypot

CHNFEED3_FILENAME=stingar_url.txt
CHNFEED3_REMOTE={cif_server_url}
CHNFEED3_TOKEN={cif_read_token}
CHNFEED3_TLS_VERIFY=True
CHNFEED3_ITYPE=url
CHNFEED3_LIMIT=10
CHNFEED3_DAYS=1
CHNFEED3_CONFIDENCE=8
CHNFEED3_TAGS=honeypot

# Specify safelists by prefacing each variable with "CHNSAFELISTX" where "X" is the safelist number
# A minimal configuration includes: FILENAME, REMOTE, TOKEN, PROVIDER, and ITYPE
# You are limited to 5 feed specifications; this limit can be changed in code
# The FILENAME should be a file available in the container path /var/www/safelists
# A PROVIDER variable is required and corresponds to a CIF group to write the safelist to
# The ITYPE is used to validate entries found in the FILENAME. YMMV.

CHNSAFELIST1_FILENAME=ipv4_safelist.txt
CHNSAFELIST1_REMOTE={cif_server_url}
CHNSAFELIST1_TOKEN={cif_write_token}
CHNSAFELIST1_TLS_VERIFY=True
CHNSAFELIST1_ITYPE=ipv4
CHNSAFELIST1_PROVIDER={cif_org}
```
The .env file may contain up to 10 feed specifications. Please be sure to substitute the variables inside the braces
 `{}`! 

The `FILENAME`, `REMOTE`, `TOKEN`, `ITYPE`, `TAGS`, and a time specification (such as `DAYS` or `HOURS`) are required 
for all feed specifications. Other items may be specified, and will otherwise default to the values as defined in the 
upstream [CIF Python SDK](https://github.com/csirtgadgets/bearded-avenger-sdk-py/wiki).

# Adding safelisting to feed pulls

It is worth noting that **there is NO default safelisting** for feeds performed by this container.

To add safelisting entries to your partner id, create a one-indicator-per-line file for each type of indicator you
 wish to safelist for. Place the file in the volume specified in your `docker-compose.yml` (in this case ./safelists
 ), and specify the filename, remote CIF server, provider id, and CIF token (with write permissions) in the `CHNSAFELIST
 ` variables. 
 
Upon startup these safelist files will be read by the container and uploaded to the specified CIF server with a tag
 of `whitelist` and a group permission of only your `PROVIDER` as specified. 
 
If you do not wish to perform any safelisting, you may leave the safelisting section out of your env file.

Once the docker-compose.yml is updated and the chn-intel-feeds.env file is 
present, you can simply:

```bash
docker-compose down && docker-compose up -d
```
To examine logs of the chn-intel-feeds instance, run:

```bash
docker-compose logs chn-intel-feeds
```


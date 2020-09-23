chn-intel-feeds
=============
The chn-intel-feeds container will automatically download indicators from a specified Collective 
Intelligence Framework (CIF) instance, a local CHN instance, or upload safelist entries (tag:whitelist) items to a CIF
 instance. You can read more about CIF [here](https://csirtgadgets.com/collective-intelligence-framework/). 

The downloaded feed indicators will be formatted to a 'single indicator per line' format, and served up over HTTP on 
(default) port 9000. These feeds will be refreshed automatically every 5 minutes (default), and are in a format easily
 consumed by protection devices such as Palo Alto EDL's or Cisco Firepower SI Lists. 

There is also support for generating a feed from the local CHN server, for those without access to a CIF server, that
 works similarly. This eases the process of getting data out of the CHN Server and into protection devices.

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

Next, add the following (minimal) `chn-intel-feeds.env` configuration file:
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
```
The above config will simply allow the container to start, but won't do anything useful yet...For that you'll need to
 configure some sort of feed!

The `chn-intel-feeds.env` file may contain up to five CHNFEED specifications, one CHNAPIFEED specificaton, and one
 CIFSAFELIST specification. Please be sure to substitute appropriate values for the variables inside the braces `{}`! 

# Adding feeds from a CIF instance

The `FILENAME`, `REMOTE`, `TOKEN`, `ITYPE`, `TAGS`, and a time specification (such as `DAYS` or `HOURS`) are required 
for all feed specifications. Other items may be specified, and will otherwise default to the values as defined in the 
upstream [CIF Python SDK](https://github.com/csirtgadgets/bearded-avenger-sdk-py/wiki).

Here's an example config to add to the `chn-intel-feeds.env` file to pull CIF feeds for IP, URL, and hashes:
```bash
# Enable the process to retrieve feeds from a remote CIF instance
CIF_FEED_ENABLED=true

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
```

# Adding safelisting to CIF feed pulls

It is worth noting that **there is NO default safelisting** for feeds performed by this container, though the remote
 CIF instance may include safelisting (ask your CIF admin!).

To add safelisting entries associated with your partner id in CIF, create a one-indicator-per-line file for each type of
 indicator you wish to safelist for. Place the file in the volume specified in your `docker-compose.yml` (in this
  case ./safelists), and specify the filename, remote CIF server, provider id, and CIF token (with write permissions
  ) in the `CHNSAFELIST` variables. 
 
Upon startup these safelist files will be read by the container and uploaded to the specified CIF server with a tag
 of `whitelist` and a group permission of only your `PROVIDER` as specified. 
 
You will need a specification like this added to your `chn-intel-feeds.env` file:

```bash

# Enable the uploading of local safelist items to CIF
# Currently supports IPv4 only
CIF_SAFELIST_ENABLED=true

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
If you do not wish to perform any safelisting, you may leave the safelisting section out of your env file.

# Adding feeds from a local CHN-Server

You will need to add a section to your `chn-intel-feeds.env` file like so:

```bash
# Specify that the local CHN-Server API should be queried for a feed
CHN_FEED_ENABLED=true

# Similar configuration to a CIF feed, but for CHN servers direct queries
# The number of hours queried is the biggest factor in performance, the limit
# is applied AFTER retrieval of the feed

CHNAPIFEED_FILENAME=chn_ip.txt
CHNAPIFEED_REMOTE={chn_server_url}
CHNAPIFEED_TOKEN={chn_server_api_token}
CHNAPIFEED_TLS_VERIFY=True
CHNAPIFEED_HOURS=72
CHNAPIFEED_LIMIT=10000
```
Using the API does put database load on the CHN-Server, primarily influenced by the number of hours requested
for the feed window. This is normally ok but may impact busier CHN servers (10,000 unique IP's per day or higher).

If you are generating feeds from a CIF instance you are also submitting to (using [hpfeeds-cif](hpfeeds-cif.md)) then
 you likely do NOT need to configure a feed from your local CHN-Server. 

# Starting chn-intel-feeds
Once the docker-compose.yml is updated and the chn-intel-feeds.env file is 
present, you can simply:

```bash
docker-compose down && docker-compose up -d
```
To examine logs of the chn-intel-feeds instance, run:

```bash
docker-compose logs chn-intel-feeds
```


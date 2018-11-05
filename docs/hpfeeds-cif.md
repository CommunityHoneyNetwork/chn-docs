hpfeeds-cif
=============
The hpfeeds-cif container, when added to a CHN-Server instance, will forward 
an "observation" of the malicious activity to a specified Collective 
Intelligence Framework (CIF) instance. You can read more about CIF [here](https://csirtgadgets.com/collective-intelligence-framework/) 


# Adding hpfeeds-cif to CHN-Server
The simplest way to integrate CHN reporting to CIF is to:

First, include this stanza in the docker-compose.yml file for CHN-server:
```dockerfile
  hpfeeds-cif:
    image: stingar/hpfeeds-cif:latest
    privileged: true
    volumes:
      - ./hpfeeds-cif.sysconfig:/etc/default/hpfeeds-cif
    links:
      - hpfeeds:hpfeeds
      - mongodb:mongodb
```
Next, add the following hpfeeds-cif.sysconfig configuration file:
```bash
HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000

MONGODB_HOST='mongodb'
MONGODB_PORT=27017

CIF_HOST='https://YOUR.CIF.SERVER'
CIF_TOKEN='YOUR_API_TOKEN_WITH_WRITE_PRIVILEGES'
CIF_PROVIDER='org-chn'
CIF_TLP='green'
CIF_CONFIDENCE='8'
CIF_TAGS='honeypot'
CIF_GROUP='everyone'
# Set the below value to True if your CIF instance uses a valid, CA-signed, certificate
CIF_VERIFY_SSL=False

```
Once the docker-compose.yml is updated and the hpfeeds-cif.sysconfig file is 
present, you can simply:

```bash
docker-compose down && docker-compose up -d
```
To examine logs of the transactions with the CIF instance, run:

```bash
docker-compose logs hpfeeds-cif
```
# Warnings
As troubleshooting a remote CIF instance can prove difficult, a high level of
 debugging logs are turned on by default. __*Warning*: The host and API key 
 will be present in the container logs!__
 
 There is currently no option for turning this logging off; if this presents 
 an issue for you, please file an issue with the [repo](https://github.com/CommunityHoneyNetwork/hpfeeds-cif/issues)


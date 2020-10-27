Upgrading Versions
=================
Typically upgrading is as simple as updating the tags associated with your images, however on occasion we do
 introduce new features which require additional configuration options, or very rarely we change more fundamental
  items such as how the docker-compose.yml files are organized, etc. 

Generally speaking you will upgrade your server instance first and once it's up and running, re-reploy your honeypots
. You can either use the scripts included with the new version of CHN-Server, or you can manually update your
 honeypot docker-compose.yml and ${honeypot}.env files.
 
## Upgrading from 1.9 to 1.9.1
This minor release provides a few bug fixes, two new honeypot types, and adds a feature for creating a feed in chn
-intel-feeds containers using a local CHN API (as opposed to using a remote CIF server). As part of adding in the new
 CHN API feature, the chn-intel-feeds container requires some new environmental variables to be passed in in order to
  ensure all of it features continue to run as expected.
  
* Upgrade the tag version from `1.9` to `1.9.1` on all server components.
* Edit the `chn-intel-feeds.env` file and ensure that each feature you wish to use also has an `_ENABLED` variable
 defined to `true`. See [the docs](https://communityhoneynetwork.readthedocs.io/en/v1.9.1/chnintelfeed/#chn-intel-feeds)
  for examples of this. For instance, users of CIF feeds will want to include `CIF_FEED_ENABLED=true`.
* Perform a `docker-compose pull` to get the latest images, then `docker-compose down && docker-compose up -d` to
 restart on the new images.
* After the CHN-Server components are updated, either re-deploy all honeypots using the new scripts
* Alterntively, update the honeypots by updating the tags from `1.9` to `1.9.1`, then a pull and restart.

## Upgrading from 1.8 to 1.9

This major release has so many changes that we highly recommend upgrading by standing up a new instance (either a new
 host, or using a new directory for the configs) rather than trying to upgrade in place. 
 
Using the chn-quickstart script should make it easy to get the latest versions. Make sure you pull the version
 associated with the release [you want to upgrade to](https://github.com/CommunityHoneyNetwork/chn-quickstart/releases/tag/v1.9)! 

For those that really want to upgrade in place, there are quite a few changes to accommodate.

### Upgrading CHN-Server components

In the [docker-compose.yml](https://communityhoneynetwork.readthedocs.io/en/v1.9/serverinstall/#deploying-the-server-manually)
* Remove STINGAR-specific images for mongodb and redis, in favor of upstream vanilla images
* Move from `hpfeeds` to `hpfeeds3` in your images
* Remove all `volumes` for `image.sysconfig` in favor of the new `env_file` for `image.env` format
* Ensure that all the `links` sections match the new example. Some containers have changed to remove connectivity
 requirements.

In the [chnserver.env](https://communityhoneynetwork.readthedocs.io/en/v1.9/serverinstall/#deploying-the-server-manually) you must:
* Ensure you remove all quotes around variable assignments (single or double)
* Make sure you're not using the example `SUPERUSER_PASSWORD`!

Create a [mnemosyne.env](https://communityhoneynetwork.readthedocs.io/en/v1.9/serverinstall/#deploying-the-server-manually) file in order to specify how long mnemosyne data is kept in the mongo database.
* We recommend 7 days (604800 seconds) and for longer retention use [hpfeeds-logger](https://communityhoneynetwork.readthedocs.io/en/v1.9/hpfeeds-logger/)   
 and export the logs elsewhere
 
Perform a `docker-compose pull` to get the latest images, then `docker-compose down && docker-compose up -d` to
 restart on the new images. This should bring you up running 1.9.

### Upgrading the Honeypots
Once the 1.9 server is up and running, it's recommended that you re-deploy your honeypots using the scripts included
 in your new 1.9 server. If you wish to upgrade manually:

* Modify the `docker-compose.yml` file to accommodate the [new Docker volume format](https://communityhoneynetwork.readthedocs.io/en/v1.9/cowrie/#example-cowrie-docker-composeyml)
* Remove all `volumes` for `image.sysconfig` in favor of the new `env_file` for `image.env` format
* __remove old registration files__. This is important because the new hpfeeds
 authentication requires an additional field (owner) that is not present in old authentication entries. Re
 -registering with the deploy key is required for data to flow to the server correctly.
* For instance: for cowrie, remove the `./cowrie/cowrie.json` file. 
* Convert the `honeypot.sysconfig` to a `honeypot.env` file and remove all quotes (single or double) from variable
 declarations.

Once this is complete you should perform a `docker-compose pull` to get the latest images, then `docker-compose down
 && docker-compose up -d` to restart on the new images. This should bring you up running 1.9.

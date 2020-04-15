# Production Considerations
Docker is wonderful when everything is working, but when things aren't 
working as you expect, it can be a challenge for new users to figure 
out what's happening. Here are two approaches that can help you to understand
 what's happening inside the container.
## Introspection commands
### docker-compose logs
The [docker-compose logs](https://docs.docker.com/compose/reference/logs/) command will dump out all the logs written to 
console since the container started. 

```commandline
$ docker-compose logs
<snip>
hpfeeds_1      | INFO:root:Auth success by mnemosyne.
hpfeeds_1      | INFO:root:Auth success by mnemosyne.
hpfeeds_1      | INFO:root:Auth success by mnemosyne.
mongodb_1      | + '[' -f /etc/default/mongod ']'
mongodb_1      | + . /etc/default/mongod
mongodb_1      | ++ mongod=/usr/bin/mongod
mongodb_1      | ++ CONFIGFILE=/etc/mongod.conf
mongodb_1      | ++ OPTIONS=' -f /etc/mongod.conf'
mongodb_1      | ++ MONGO_USER=mongod
mongodb_1      | ++ MONGO_GROUP=mongod
mongodb_1      | ++ NUMACTL='/usr/bin/numactl '
mongodb_1      | ++ PIDFILEPATH='/var/run/mongodb/mongod.pid '
mongodb_1      | +++ dirname /var/run/mongodb/mongod.pid
mongodb_1      | ++ PIDDIR=/var/run/mongodb
mongodb_1      | ++ SYSTEM_LOG=/var/log/mongodb/mongod.log
mongodb_1      | +++ dirname /var/log/mongodb/mongod.log
mongodb_1      | ++ LOGDIR=/var/log/mongodb
mongodb_1      | ++ STORAGE_DIR=/var/lib/mongo
mongodb_1      | + '[' '!' -d /var/run/mongodb ']'
mongodb_1      | + ulimit -f unlimited
mongodb_1      | + ulimit -t unlimited
mongodb_1      | + ulimit -v unlimited
chnserver_1    | *** uWSGI is running in multiple interpreter mode ***
chnserver_1    | spawned uWSGI worker 1 (and the only) (pid: 13, cores: 1)
chnserver_1    | Database already initialized
<snip>
```
As you can see above, there are logs from several containers, all in this 
view. If you know there's a particular container you want to see, you can 
specify the name and it will filter to only that container:

```commandline
$ docker-compose logs mongodb |head
Attaching to chnserver_mongodb_1
mongodb_1      | + '[' -f /etc/default/mongod ']'
mongodb_1      | + . /etc/default/mongod
mongodb_1      | ++ mongod=/usr/bin/mongod
mongodb_1      | ++ CONFIGFILE=/etc/mongod.conf
mongodb_1      | ++ OPTIONS=' -f /etc/mongod.conf'
mongodb_1      | ++ MONGO_USER=mongod
mongodb_1      | ++ MONGO_GROUP=mongod
mongodb_1      | ++ NUMACTL='/usr/bin/numactl '
mongodb_1      | ++ PIDFILEPATH='/var/run/mongodb/mongod.pid '
$
```
Two more handy options for the _logs_ command are:

|option|meaning |
|---|---|
|_-f, --follow_|Follow log output|
|_-t,--timestamps_|Show timestamps|

### docker-compose exec
What if the problem you're encountering doesn't generate a log, or you want 
to verify the environment inside the container? The [docker-compose exec](https://docs.docker.com/compose/reference/exec/) 
command allows you to verify items directly in the container.

This is handy when you may need to "explore" the container, and running commands manually every time may
 get old. Simply exec bash, and you'll be in a bash session in the container:
 
```commandline
$ docker-compose exec chnserver bash
root@a60116039800:/# vim /opt/config.py 
bash: vim: command not found
root@a60116039800:/# 
```

Notice how vim isn't installed on this container? MANY of the things you might
 normally expect to be present won't be. You can always install the package 
 you need in the container using apt:
 
```commandline
root@a60116039800:/# apt update && apt install -y vim                                                                                                                                                                                                 
Reading package lists... Done                                                                                                                                                                                                           
Building dependency tree                                                                                                                                                                                                                
Reading state information... Done                                                                                                                                                                                                       
The following additional packages will be installed:                                                                                                                                                                                    
  libgpm2 libpython3.6 vim-common vim-runtime xxd                                                                                                                                                                                       
Suggested packages:                                                                                                                                                                                                                     
  gpm ctags vim-doc vim-scripts                                                                                                                                                                                                         
The following NEW packages will be installed:                                                                                                                                                                                           
  libgpm2 libpython3.6 vim vim-common vim-runtime xxd                                                                                                                                                                                   
0 upgraded, 6 newly installed, 0 to remove and 1 not upgraded. 
<snip>
```
_PLEASE NOTE:_ This package will _stay_ installed in the INSTANCE of the 
container, but it will not be in the IMAGE that the instance is based on. 
This means the next time the instance is destroyed (i.e., docker-compose 
down), the changes you made will be removed. 

## Restart on boot
Once you're running honeypots in production, you'll likely want them to 
restart automatically on boot, for instance, after a patching reboot on the 
host server. This can be accomplished in a number of ways, but on modern 
systems a systemd integration is ideal. 

Let's presume that you used the quickstart process to build your server, and your `docker-compose.yml` file is located in
 `./chnserver`. Given this, you should move the contents of chnserver directory into it's permanent location, like this:

```bash
$ mkdir -p /opt/chnserver
$ cp -R ./chnserver/* /opt/chnserver
```
*Note:* If you originally cloned the `chn-quickstart` repository into `/opt/chnserver`, you can skip the step above.

Add a general purpose systemd configuration file to `/etc/systemd/system/chnserver.service`. 

```yaml
[Unit]
Description=CHN-Server service with docker compose
Requires=docker.service
After=docker.service

[Service]
Restart=always

WorkingDirectory=/opt/chnserver

# Remove old containers
ExecStartPre=/usr/bin/docker-compose down
ExecStartPre=/usr/bin/docker-compose rm -fv

# Compose up
ExecStart=/usr/bin/docker-compose up

# Compose down, remove containers
ExecStop=/usr/bin/docker-compose down

[Install]
WantedBy=multi-user.target
```

Now that we have the systemd file and our docker-compose files in place, 
enable the service:
```bash
$ systemctl enable --now chnserver.service
```
You can now use standard systemd commands to stop, start and restart your 
containers.

## Using custom deployment scripts

As of version 1.8, you can provide a directory of custom deployment scripts that will automatically be imported into 
the CHN database on start. In order to provide these scripts to the container, you must volume mount a local 
directory into the container at `/opt/custom_scripts`. For instance, the following stanza mounts a local directory 
called `./custom_scripts` into the appropriate location:

```yaml
  chnserver:
    image: stingar/chn-server:1.9
    volumes:
      - ./storage/chnserver/sqlite:/opt/sqlite:z
      - ./certs:/etc/letsencrypt:z
      - ./custom_scripts:/opt/custom_scripts:z
    env_file:
      - ./config/sysconfig/chnserver.env
    links:
      - mongodb:mongodb
    ports:
      - "80:80"
      - "443:443"
    restart: always
```
Once the container is restarted, the script(s) will be loaded into the database. You can also force a refresh with 
the following command:

```bash
docker-compose exec chnserver bash
```

This puts you inside the container. Now run:

```bash
cd /opt && python /opt/initdatabase.py
```

This will ensure your custom scripts are loaded into the database. Now you can type `exit` to leave the container 
bash prompt.

**WARNING**: This will load the script(s), as they exist in the filesystem, on each restart. This means if you change
 the script in the WebUI, you're changing the script as it exists in the database. Upon restart, these changes will 
 be LOST, unless you either remove the volume mount, or make changes to the scripts in the filesystem. Both have pros
  and cons, but this authors preference would be to only make changes to the filesystem versions and restart the 
  server when required (and also keep those scripts in a code repository).

## Administrivia

You may find yourself in need to recovering the current DEPLOY_KEY in cases 
where the server storage is lost or the container fully rebuilt (and the 
honeypots already deployed need the new key to connect). Simply run the 
following command on the server command line to recover the key:

    docker-compose exec chnserver awk '/DEPLOY_KEY/' /opt/config.py

# Security

## Use of HTTPS
By customizing the SERVER_BASE_URL variable in the chnserver.sysconfig file 
with the FQDN of the server (including the https:// stem), CHN can and will use
 TLS encryption for communications over port 443. We make use of [EFF Certbot](https://certbot.eff.org/)
  to provision a valid TLS certificate during startup.
  
For example:
```bash
SERVER_BASE_URL='https://chn.my.org'
``` 
Please note that using https with 'localhost' or an IP address will result in
 a self-signed cert, as Certbot will not issue certificates for IP addresses 
 or localhost.
 
Consult the [section](certificates.md) on certificates for details on options
 for providing your own certificates or using self-signed certs.
 
## Firewall

In order for honeypots to register and log data to the management server, the following inbound ports need to be open on the server and reachable by the honeypots:

* **TCP port 80 or 443** - required for registration of new honeypots to the CHN server
* **TCP port 10000** - required for transmission of honeypot data to the hpfeeds message queue

If you find that your honeypots are not showing up in the CHN Server “Sensors” panel, make sure they can reach the server on port 80/443. If your honeypots are showing up in the “Sensors” panel, but no attacks are being logged, make sure the honeypots are able to communicate on port 10000.

Connecting to port 10000 with a tool such as netcat should return binary output beginning with *“@hp2”* if this port is accessible.

We recommend restricting these ports to honeypots and any host that needs access to this data.

**Be Warned:** On some systems, in default configurations, docker-compose stanzas will automatically override
 firewall restrictions and expose ports without restriction. It is always advisable to test your access controls once
  deployed.
  
## Dealing with large mongo collections

It may be desirable or necessary for users to clear out the voluminous session data in the mongo database. When this
 is required, there is a script existing in the mnemosyne container which will clear out all existing sessions from
  the database. This script can take a while to run on larger databases, so you may wish to execute this command in a
   screen or tmux session.
   
```bash
docker-compose exec mnemosyne mongo mongodb/mnemosyne /opt/clear_database.js
```

This will remove all data in the mongo database, including raw sessions data from honeypots, attack data for the UI
, statistical counts, etc. This will *not* remove sensor registration information. 

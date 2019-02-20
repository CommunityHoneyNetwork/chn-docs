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
mongodb_1      | + '[' -f /etc/sysconfig/mongod ']'
mongodb_1      | + . /etc/sysconfig/mongod
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
mongodb_1      | + '[' -f /etc/sysconfig/mongod ']'
mongodb_1      | + . /etc/sysconfig/mongod
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
command allows you to verify items directly; a good use case would be 
verifying that the sysconfig file you provided actually got picked up inside 
the container: 

```commandline
$ docker-compose exec chnserver cat /etc/default/chnserver
# This file is read from /etc/sysconfig/chnserver or /etc/default/chnserver
# depending on the base distro
#
# This can be modified to change the default setup of the chnserver unattended installation

DEBUG=false

EMAIL=admin@localhost
SERVER_BASE_URL=''
HONEYMAP_URL=''
REDIS_URL='redis://redis:6379'
MAIL_SERVER='127.0.0.1'
MAIL_PORT=25
MAIL_TLS='y'
MAIL_SSL='y'
MAIL_USERNAME=''
MAIL_PASSWORD=''
DEFAULT_MAIL_SENDER=''
MONGODB_HOST='mongodb'
MONGODB_PORT=27017
HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000

SUPERUSER_EMAIL=''
SUPERUSER_PASSWORD=''
SECRET_KEY=''
DEPLOY_KEY=''
```

This is handy if you know exactly what you want. Sometimes, however, you may 
need to "explore" the container, and running commands manually every time may
 get old. Simply exec bash, and you'll be in a bash session in the container:
 
```commandline
$ docker-compose exec chnserver bash
root@a60116039800:/# vim /etc/default/chnserver 
bash: vim: command not found
root@a60116039800:/# 
```

Notice how vi isn't installed on this container? MANY of the things you might
 normally expect to be present won't be. You can always install the package 
 you need in the container using apt:
 
```commandline
root@a60116039800:/# apt install -y vim                                                                                                                                                                                                 
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

Let's presume that we'll put the docker-compose.yml and sysconfig files in a 
directory we'll dedicate to the service in question.

```bash
$ mkdir -p /srv/docker-compose/chnserver
$ cp docker-compose.yml chnserver.sysconfig /srv/docker-compose/chnserver
```

Add a general purpose systemd configuration file to `/etc/systemd/system/`. 

```yaml
[Unit]
Description=%i service with docker compose
Requires=docker.service
After=docker.service

[Service]
Restart=always

WorkingDirectory=/srv/docker-compose/%i

# Remove old containers
ExecStartPre=/usr/bin/docker-compose down -v
ExecStartPre=/usr/bin/docker-compose rm -fv

# Compose up
ExecStart=/usr/bin/docker-compose up

# Compose down, remove containers and volumes
ExecStop=/usr/bin/docker-compose down -v

[Install]
WantedBy=multi-user.target
```

Now that we have the systemd file and our docker-compose files in place, 
enable the service:
```bash
$ systemctl enable --now docker-compose@chnserver
```
You can now use standard systemd commands to stop, start and restart your 
containers.



## Administrivia

You may find yourself in need to recovering the current DEPLOY_KEY in cases 
where the server storage is lost or the container fully rebuilt (and the 
honeypots already deployed need the new key to connect). Simply run the 
following command on the server VM to recover the key:

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

Advanced Configuration
======================

Each of the services and honeypots in the CommunityHoneyNetwork project should work together out of the box following the [Quickstart Guide](quickstart.md). More advanced configuration options can be configured using an /etc/sysconfig/<servicename> or /etc/default/<servicename> file for CentOS-based or Ubuntu-based systems, respectively.

Services running in Docker containers can be configured this way as well, mounting the configuration files into place using the `--volume` argument for Docker.

Using Docker/docker-compose, each of the containers can share a single sysconfig file, mounted into the appropriate location for each.  Options not appropriate for each particular service are just unused.

The following is an example of a shared configuration file, using default values:

```
# CHN Server options
CHNSERVER_DEBUG=false

EMAIL=admin@localhost
SERVER_BASE_URL='http://127.0.0.1'
HONEYMAP_URL=''

MAIL_SERVER='127.0.0.1'
MAIL_PORT=25
MAIL_TLS='y'
MAIL_SSL='y'
MAIL_USERNAME=''
MAIL_PASSWORD=''
DEFAULT_MAIL_SENDER=''

# Redis config options
REDIS_URL='redis://redis:6379'

# MongoDB config options
MONGODB_HOST='mongodb'
MONGODB_PORT=27017

# HPfeeds config options
HPFEEDS_HOST='hpfeeds'
HPFEEDS_PORT=10000

# Mnemosyne config options
IGNORE_RFC1918=False
```

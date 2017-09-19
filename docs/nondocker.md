Deploying without Docker
========================

In addition to running within Docker, you can also deploy each of the CHN Server services and honeypots as regular services on a host (or many hosts).  The container images are all built using [Ansible](https://www.ansible.com/) playbooks.  These playbooks can be run on regular hosts to install the services as normal services, without running as Docker containers.

**Note:** BETA STATUS - The ability to install directly to regular hosts _should_ work, but is still in development and _might_ break something.  Use at your own risk.  You're most likely to be successful installing on a freshly installed system, rather than a shared host.

## Prerequesites

The non-containerized deployment model uses Ansible to install and setup hosts.  
* Ansible >= 2.3.2.0

## Example Deployment

As an example of a non-container deployment, to install the [MongoDB service](https://github.com/CommunityHoneyNetwork/mongodb/) on the current host:

    cd /opt
    git clone https://github.com/CommunityHoneyNetwork/mongodb/
    cd mongodb
    echo "localhost ansible_connection=local" inventory.txt
    ansible-playbook mongodb.yml -i inventory.txt -c local

The inventory file can be modified to deploy to remote hosts, as well.  In fact, [Ansible is incredibly configurable](http://docs.ansible.com/ansible/latest/playbooks.html), and all of the playbooks could be combined with an appropriate inventory file to manage all of the hosts with a single Ansible setup.

## Supported Operating Systems

The CommunityHoneyNetwork projects are developed and tested to work with:

* CentOS 7
* Ubuntu 17.10

They *should* also work with the following, but are currently untested and unsupported:

* Fedora 26
* Red Hat Enterprise Linux 7
* Debian Stretch

## Requires Advanced Configuration

The out-of-the-box configuration of each service is designed for use inside a container and by default, when installed without contianers, the services need additional information to know how to talk with one another.  Read the [Advanced Configuration](config.md) documentation for more information.

## Runit

Each of the projects use [Runit](http://smarden.org/runit/) as the process manager for their respective services, whether in containers or not.  The Ansible playbooks will install Runit along with the services.  This should not impact systems using SysVinit or Systemd.  Since Ansible will install the services using packages provided by the OS maintainer, there will be appropriate configuration files for the init system of that OS, but without the Runit configs, the services will not be setup correctly to talk to one another.

Runit services can be controlled directly using the [Runit sv command](http://smarden.org/runit/sv.8.html).  All CNH services on the host can be started at once by using the [Runit runsvdir command](http://smarden.org/runit/runsvdir.8.html): `runsvdir -P /etc/service`.

Startup scripts for each service exist in /etc/service/<service name>/run.

## Installation Locations

Most of the services will use the upstream packages for your OS or Python PIP packages, and install in the standard locations for those packages.

Services that are not available as upstream packages or PIP packages will install to /opt on your host.

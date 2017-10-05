
Deploying to Cloud Providers
============================

The CommunityHoneyNetwork [cloud-deploy repository](https://github.com/CommunityHoneyNetwork/cloud-deploy.git) contains tools to provision and configure infrastructure for [CommunityHoneyNetwork](https://communityhoneynetwork.github.io/) honeypots and management servers in cloud hosting services like Amazon Webservices.

## Prerequesites

Infrastructure is described and created using a [Terraform](https://www.terraform.io/) _configuration_, and the resulting instances/servers are setup with [Ansible](https://www.ansible.com/) _playbooks_.

  * Terraform >= v0.10.6
  * Ansible >= 2.4.0.0
  * A cloud provider account

Currently only AWS is supported, but support for other providers is comming.

## Credentials

There are a number of ways to provide your AWS account credentials for Terraform to use: specified statically in the .tf config in the `provider "aws"` object, as environment variables, in a shared credentials file, etc.  See the [Terraform AWS Provider Credentials documentation](https://www.terraform.io/docs/providers/aws/) for more info. It is generally recommended to create an IAM user and credentials specifically for this use case.

In addition to credentials for your cloud provider, you will need to be able to SSH to the created hosts in order to run Ansible to configure them.  The only required setup is the addition of your SSH Authorized Keys for the root user on the EC2 instances.  AWS uses cloud-init to initialize hosts during provisioning. Create a file named `userdata.txt` with the following, substituting your authorized key(s).

```
#cloud-config
users:
  - gecos: root
    lock-passwd: true
    name: root
    primary-group: root
    ssh-authorized-keys:
      - your.key.here
      - second.optional.key
```

Alternatively, you can create a user using cloud-init and setup sudo privileges.  There will need to be a few minor changes to the Ansible configuration to use the new user.

## Deployment

If you have a greenfield (no existing AWS infrastructure), just hit go (see below). Otherwise, customize the default.tfvars to fit within your environment.  Special care should be taken with the VPC CIDR (making sure it doesn't overlap with any existing AWS infrastructure you may have) and traffic ingress rules.  Most importantly, set the `ssh_ingress_blocks` variable to be an array containing the IPs or Subnets (in CIDR notation) from which your hosts should allow SSH connections.  This *must* include the host that will perform the Ansible configuration.

An example default.tfvars file:

```
# tfvars
#
# Variables listed here are defaults, 
# but can be changed to customize your deployment

# The AWS region to deploy to
region = "us-east-1"

# The VPC CIDR to use for the CHN project
vpc_cidr = "10.99.0.0/26"

# Individual subnets to deploy to
#
# Subnets are automatically allocated to 
# availability zones by index, so if only one
# availability zone is used, only the first subnet
# will be allocated
public_subnet_cidr = [
  "10.99.0.16/28",
  "10.99.0.32/28",
  "10.99.0.48/28",
]

# The Instance Type maps host jobs to 
# AWS instance types
instance_type = { honeypot = "t2.micro", server = "t2.micro", bastion = "t2.micro"}

# The Instance Count variable is a map of host type
# to number of desired instances
instance_count = { honeypot = 3, server = 1 }

# The Root Volume size variable is a map of host type
# to disk size
root_volume_size = { honeypot = 50, server = 50 }

# List of CIDR blocks to allow ssh access to the instances
ssh_ingress_blocks = [ "127.0.0.1/32" ]

# List of CIDR blocks to allow HTTP and HTTPS access to 
# the CHN management server
http_ingress_blocks = [ "127.0.0.1/32" ]
https_ingress_blocks = [ "127.0.0.1/32" ]

```

Once your `.tfvars` file is setup, build the infrastructure by running:

    terraform apply -var-file=default.tfvars

This will run through the process of creating the VPC, Subnets, Security groups and EC2 instances described in the Terraform configuration files.

When the Terraform process is complete, you can finish the configuration of the EC2 instances by running the Ansible playbook.  By default, Ansible will try to connect to the instances as root, using SSH keys you have available to your user.  One of these should be the SSH key provided in the `userdata.txt` file, above.

    ansible-playbook site.yml

Ansible will use the ansible.cfg in the root of the repository and the inventory.py script to generate the inventory of AWS instances to configure based on the Terraform `terraform.tfstate` file.  The tfstate file is _cached data_ and may get out-of-sync if you are working with others or make changes to the AWS resources manually.  [Read more about the .tfstate file and alternatives](https://www.terraform.io/docs/state/) before using this in production.

## Next Steps

After running through the Terraform and Ansible setup steps, you should be left with a number of instances.  In the default configuration, these will be CentOS Atomic hosts with Docker, Git and Docker Compose installed and configured.  You should be able to continue on with [Deploying the Server](https://communityhoneynetwork.github.io/quickstart/#deploying-the-server) or deploying [Your First Honeypot](https://communityhoneynetwork.github.io/firstpot/).

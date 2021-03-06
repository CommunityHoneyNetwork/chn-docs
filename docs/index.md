CommunityHoneyNetwork
=====================

Honeypot deployment and management automation

## Simple deployments for your platform

CHN aims to make deployment of honeypots and honeypot management tools easy 
and flexible. The default deployment method uses Docker Compose and Docker to deploy with a few simple commands
.  Want to jump right in and get started?  Deploy a honeypot management server and sample honeypot in minutes with the [CHN Server Install](serverinstall.md).


## Getting the correct versions
When installing CHN Server and Honeypots, it is important to make sure versions of each component are compatible with the others.  We recommend using release tags to maintain compatibility between projects.  CHN maintains stable release tags that are tested to work across the different CHN projects.

The master branches from each project track current work **in development**, and are not guaranteed to be stable.

**Getting the latest releases**

The releases pages for each project - for example, the [CHN-Server release page](https://github.com/CommunityHoneyNetwork/CHN-Server/releases) - for each project list the available releases.  We recommend using the latest stable release. GitHub will direct you to the latest release for any project by adding `/latest` to the URL for that project's releases page.  Using the CHN-Server repository as an example: [github.com/CommunityHoneyNetwork/CHN-Server/releases/latest](https://github.com/CommunityHoneyNetwork/CHN-Server/releases/latest)

## Contributing

Contributions to the CommunityHoneyNetwork project are welcome!  After all, it's not much of a community without your
 help.  Documentation always needs help, individual projects each have their own issues or bugs that need to be addressed, and test coverage can always be improved.

To contribute, submit a pull request to one of the [CommunityhoneyNetwork projects](https://github.com/CommunityHoneyNetwork) you'd like to work with. 

In order to merge the pull request, it'll have to take the following steps:

* Create the PR
* Pass the automated Gitlab builds
* Get an `LGTM` (looks good to me) from a reviewer
* Get approval from an owner

## Acknowledgements

CommunityHoneyNetwork was forked from Threatstream's Modern Honey Network project, and uses several excellent
 projects by the [Honeynet Project](https://www.honeynet.org/). 

Security Considerations
=======================


##Configuration
### "Which ports should have global access and what ip addresses and ports should have access from management?"

In order for honeypots to register and log data to the management server, the following inbound ports need to be open on the server and reachable by the honeypots:

* **TCP port 80 or 443** - required for registration of new honeypots to the CHN server
* **TCP port 10000** - required for transmission of honeypot data to the hpfeeds message queue

If you find that your honeypots are not showing up in the CHN Server “Sensors” panel, make sure they can reach the server on port 80/443. If your honeypots are showing up in the “Sensors” panel, but no attacks are being logged, make sure the honeypots are able to communicate on port 10000.

Connecting to port 10000 with a tool such as netcat should return binary output beginning with *“@hp2”* if this port is accessible.

We recommend restricting these ports to honeypots and any host that needs access to this data.
CHN Server REST API
===================

Useful API calls for querying honeypot data.

**Intel Feed**
----

_Returns honeypot intel data from CHN Server_

**Resource URL**

_http://127.0.0.1/api/intel_feed/_

**Resource Information**

* Response formats: JSON
* Requires authentication: Yes

**Parameters**

| Name      | Required | Description                                            | Default Value | Example                               |
| --------- | -------- | ------------------------------------------------------ | ------------- | ------------------------------------- |
| api_key   | Yes      | API authentication key                                 | None          | a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6      |
| hours_ago | No       | Retrieve all elements from x hours ago to current time | 4             | 24                                    |
| limit     | No       | Maximum number of elements to retrieve                 | 1000          | 100                                   |
| honeypot  | No       | Honeypot name to query for                             | None          | cowrie                                |
| protocol  | No       | Protocol to query for                                  | None          | ssh                                   |

**Example Request**

_curl http://127.0.0.1/api/intel_feed/?api_key=xxxxx&hours_ago=24&limit=100_

**Example Response**

```
{
  "data": [
    {
      "count": 2,
      "destination_port": 2222,
      "honeypot": "cowrie",
      "meta": [],
      "protocol": "ssh",
      "source_ip": "172.18.0.1"
    }
  ],
  "meta": {
    "options": {
      "hours_ago": "24",
      "limit": "100"
    },
    "query": "intel_feed",
    "size": 1
  }
}
```

---

** Intel Feed CSV **
----

_Returns honeypot intel data from CHN Server as CSV_

**Resource URL**

_http://127.0.0.1/api/intel_feed.csv/_

**Resource Information**

* Response formats: CSV
* Requires authentication: Yes

**Parameters**

| Name      | Required | Description                                            | Default Value | Example                               |
| --------- | -------- | ------------------------------------------------------ | ------------- | ------------------------------------- |
| api_key   | Yes      | API authentication key                                 | None          | a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6      |
| hours_ago | No       | Retrieve all elements from x hours ago to current time | 4             | 24                                    |
| limit     | No       | Maximum number of elements to retrieve                 | 1000          | 100                                   |
| honeypot  | No       | Honeypot name to query for                             | None          | cowrie                                |
| protocol  | No       | Protocol to query for                                  | None          | ssh                                   |

**Example Request**

_curl http://127.0.0.1/api/intel_feed.csv/?api_key=xxxxx&hours_ago=24&limit=100_

**Example Response**

```
source_ip	count	tags
172.18.0.1	2	cowrie,ssh,port-2222
```


---

** Attacker Stats **
----

_Returns detailed attacker statistics by IP address_

**Resource URL**

_http://127.0.0.1/api/attacker_stats/< ip >_

**Resource Information**

* Response format: JSON
* Requires authentication: Yes

**Parameters**

| Name      | Required | Description                                            | Default Value | Example                               |
| --------- | -------- | ------------------------------------------------------ | ------------- | ------------------------------------- |
| api_key   | Yes      | API authentication key                                 | None          | a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6      |
| hours_ago | No       | Retrieve all elements from x hours ago to current time | 720           | 24                                    |


** Example Request **

_curl http://127.0.0.1/api/attacker_stats/172.18.0.1/?api_key=xxxxx&hours_ago=24_

** Example Response **

```
{
  "data": {
    "count": 2,
    "first_seen": "2017-10-12T19:06:53.856000",
    "honeypots": [
      "cowrie"
    ],
    "last_seen": "2017-10-12T19:07:15.196000",
    "num_sensors": 1,
    "ports": [
      2222
    ]
  },
  "meta": {
    "options": {
      "hours_ago": "24"
    },
    "query": "attacker_stats"
  }
}
```

---

**Top Attackers**
----

_Returns information regarding top attacking hosts_

**Resource URL**

_http://127.0.0.1/api/top_attackers_

**Resource Information**

* Response format: JSON
* Requires authentication: Yes

**Parameters**

| Name      | Required | Description                                            | Default Value | Example                               |
| --------- | -------- | ------------------------------------------------------ | ------------- | ------------------------------------- |
| api_key   | Yes      | API authentication key                                 | None          | a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6      |
| hours_ago | No       | Retrieve all elements from x hours ago to current time | 4             | 24                                    |
| limit     | No       | Maximum number of elements to retrieve                 | 1000          | 100                                   |
| honeypot  | No       | Honeypot name to query for                             | None          | cowrie                                |
| source_ip | No       | Source IP to query for                                 | None          | 172.18.0.1                            |

**Example Request**

_curl http://127.0.0.1/api/top_attackers/?api_key=xxxxx&hours_ago=24_

**Example Response**

```
{
  "data": [
    {
      "count": 2,
      "honeypot": "cowrie",
      "source_ip": "172.18.0.1"
    }
  ],
  "meta": {
    "options": {
      "hours_ago": "24"
    },
    "query": "top_attackers",
    "size": 1
  }
}
```

---

**Feed**
----

CAUTION: This request can put heavy load on server / database if run with no parameters. Be sure to run with parameters to limit output

_Returns full feed information for attacks._

**Resource URL**

_http://127.0.0.1/api/feed_

**Resource Information**

* Response format: JSON
* Requires authentication: Yes

**Parameters**

| Name      | Required | Description                                            | Default Value | Example                               |
| --------- | -------- | ------------------------------------------------------ | ------------- | ------------------------------------- |
| api_key   | Yes      | API authentication key                                 | None          | a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6      |
| hours_ago | No       | Retrieve all elements from x hours ago to current time | None          | 24                                    |
| limit     | No       | Maximum number of elements to retrieve                 | None          | 100                                   |
| channel   | No       | Specific channel to query for                          | None          | cowrie.sessions                       |

**Example Requests**

_curl http://127.0.0.1/api/feed/?api_key=xxxxx&hours_ago=24_

**Example Response**

```
{
  "data": [
    {
      "_id": "59dfbd4dd0c73600080c0c78",
      "channel": "cowrie.sessions",
      "ident": "3ab9eafe-e4ea-4576-a8f6-bb8018e446ed",
      "payload": {
        "commands": [],
        "credentials": [],
        "endTime": "2017-10-12T19:06:53.855064Z",
        "hostIP": "172.18.0.8",
        "hostPort": 2222,
        "loggedin": null,
        "peerIP": "172.18.0.1",
        "peerPort": 39858,
        "session": "6c8e36afc9d2",
        "startTime": "2017-10-12T19:06:53.841022Z",
        "ttylog": null,
        "unknownCommands": [],
        "urls": [],
        "version": "SSH-2.0-OpenSSH_6.9"
      },
      "timestamp": "2017-10-12T19:06:53.856000"
    },
    {
      "_id": "59dfbd63d0c73600080c0c7a",
      "channel": "cowrie.sessions",
      "ident": "3ab9eafe-e4ea-4576-a8f6-bb8018e446ed",
      "payload": {
        "commands": [],
        "credentials": [
          [
            "test",
            "test"
          ]
        ],
        "endTime": "2017-10-12T19:07:15.194759Z",
        "hostIP": "172.18.0.8",
        "hostPort": 2222,
        "loggedin": null,
        "peerIP": "172.18.0.1",
        "peerPort": 39864,
        "session": "d910e3b31bac",
        "startTime": "2017-10-12T19:07:12.240443Z",
        "ttylog": null,
        "unknownCommands": [],
        "urls": [],
        "version": "SSH-2.0-OpenSSH_6.9"
      },
      "timestamp": "2017-10-12T19:07:15.196000"
    }
  ],
  "meta": {
    "options": {},
    "query": {
      "hours_ago": "24"
    },
    "size": 2
  }
}
```

---

**Session**
----

CAUTION: This request can put heavy load on server / database if run with no parameters. Be sure to run with parameters to limit output

_Returns full session information for attacks._

**Resource URL**

_http://127.0.0.1/api/session_

**Resource Information**

* Response format: JSON
* Requires authentication: Yes

**Parameters**

| Name             | Required | Description                                                   | Default Value | Example                               |
| ---------------- | -------- | ------------------------------------------------------------- | ------------- | ------------------------------------- |
| api_key          | Yes      | API authentication key                                        | None          | a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6      |
| hours_ago        | No       | Retrieve all elements from x hours ago to current time        | None          | 24                                    |
| limit            | No       | Maximum number of elements to retrieve                        | None          | 100                                   |
| honeypot         | No       | Honeypot name to query for                                    | None          | cowrie                                |
| protocol         | No       | Protocol to query for                                         | None          | ssh                                   |
| source_ip        | No       | Source IP address to query for                                | None          | 172.18.0.1                            |
| destination_ip   | No       | Destination IP address to query for                           | None          | 172.18.0.2                            |
| destination_port | No       | Destination port address to query for                         | None          | 2222                                  |

**Example Requests**

_curl http://127.0.0.1/api/session/?api_key=xxxxx&hours_ago=24_

**Example Response**

```
{
  "data": [
    {
      "_id": "59dfbd50d0c73600080c0c79",
      "destination_ip": null,
      "destination_port": 2222,
      "honeypot": "cowrie",
      "identifier": "3ab9eafe-e4ea-4576-a8f6-bb8018e446ed",
      "protocol": "ssh",
      "source_ip": "172.18.0.1",
      "source_port": 39858,
      "timestamp": "2017-10-12T19:06:53.856000"
    },
    {
      "_id": "59dfbd65d0c73600080c0c7b",
      "destination_ip": null,
      "destination_port": 2222,
      "honeypot": "cowrie",
      "identifier": "3ab9eafe-e4ea-4576-a8f6-bb8018e446ed",
      "protocol": "ssh",
      "source_ip": "172.18.0.1",
      "source_port": 39864,
      "timestamp": "2017-10-12T19:07:15.196000"
    }
  ],
  "meta": {
    "options": {},
    "query": {
      "destination_port": "2222"
    },
    "size": 2
  }
}
```
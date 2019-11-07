To customize your TLS certificate for CHN-Server, there is an environment
variable you can optionally pass to the container called
`CERTIFICATE_STRATEGY`.  This variable can be set to one of the following:

`CERTBOT` - Use the certbot package to install a real certificate from
[LetsEncrypt](https://letsencrypt.org/), using the
[ACME](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment)
protocol.  If you have your own ACME server, you can pass an additional
environment variable to your container to use it: `ACME_SERVER`. Additionally, see the [prerequisites](prerequisite
.md) section on *Network Connectivity* for additional requirements for using `CERTBOT`

`SELFSIGNED` - Use OpenSSL to generate a self signed certificate

`BYO` - Bring Your Own.  This is useful if you have a CA that does not support
ACME.  To use this, mount your own directory containing cert.pem and key.pem in
to the /tls volume of the container.  To ensure you can see the certs in your
conatiner, use `docker-compose exec ls /tls` from within your docker-compose
directory

For example, volume mount a local directory to the `/tls` directory via your docker-compose.yml in the 
`volumes` section for the chnserver container:

```yaml
  chnserver:
    image: stingar/chn-server:1.8
    volumes:
      - ./config/collector:/etc/collector:z
      - ./storage/chnserver/sqlite:/opt/sqlite:z
      - ./chnserver.sysconfig:/etc/default/chnserver:z
      - ./certs:/tls:z
    links:
      - mongodb:mongodb
      - redis:redis
      - hpfeeds:hpfeeds
    ports:
      - "80:80"
      - "443:443"
```
Then ensure that you place your certificate files in the `./certs` directory, and that the private key is named `key.pem` and the public key is named `cert.pem`.

If the SERVER variable is set to an IP address, `SELFSIGNED` is the default
value.  If a real name is given, `CERTBOT` is the default value. 

As Certbot relies on a challenge-response protocol using the webserver, the `CERTBOT` strategy will not work with 
NAT'ed or non-publicly accessible servers.

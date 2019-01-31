To customize your TLS certificate for CHN-Server, there is an environment
variable you can optionally pass to the container called
`CERTIFICATE_STRATEGY`.  This variable can be set to one of the following:

`CERTBOT` - Use the certbot package to install a real certificate from
[LetsEncrypt](https://letsencrypt.org/), using the
[ACME](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment)
protocol.  If you have your own ACME server, you can pass an additional
environment variable to your container to use it: `ACME_SERVER`

`SELFSIGNED` - Use OpenSSL to generate a self signed certificate

`BYO` - Mount your own directory containing cert.pem and key.pem in to the /tls
volume of the container

If the SERVER variable is set to an IP address, `SELFSIGNED` is the default
value.  If a real name is given, `CERTBOT` is the default value.

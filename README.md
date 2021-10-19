## ungleich-certbot

This container is made for getting **real world** certificates
for your kubernetes cluster.

The assumption is that you can point the DNS name to the container
from outside. This is by default given for **IPv6 only kubernetes
services**.


## Usage

* Set the environment variable DOMAIN to specify the domain for which
  to get a certificate
* Set the environment variable EMAIL (this is where letsencrypt sends
  warnings to)
* Set the environment variable STAGING to "no" if you want to have
  proper certificates - this is to prevent you from asking the real
  letsencrypt service accidently by default
* By default the container allows world read access to the
  certificates, so that non-root users can access the certificates.
  Set the LEAVE_PERMISSIONS_AS_IS environment variable to instruct the
  container not to change permissions
* If you setup the variable NGINX to any value, the container will
  start nginx and reload after trying to renew the certificate

```
docker run -e DOMAIN=example.com \
           -e EMAIL=root@example.com \
              ungleich/ungleich-certbot
```

### Nginx support

Using

```
docker run -e DOMAIN=example.com \
           -e EMAIL=root@example.com \
           -e NGINX=yes \
           -e STAGING=no \
              ungleich/ungleich-certbot
```

you will get a proper, real world usable nginx server. Inject the
nginx configuration by meains of a volume to /etc/nginx/conf.d

### Exiting after getting the certificate

By default, the container will stay alive and try to renew the
certificate every 86400 seconds. If you set the environment variable
`ONLYGETCERT`, then it will only get the certificates and exit.

### Only renewing the certificate

If you only want to trigger renewing existing certificates and skip
getting the certificates initially, you can set the variable
`RENEWCERTSONCE`, then it will only renew all certificates and exit.

* If `ONLYRENEWCERTS` is set, only the reguler renew loop will run.
* If `ONLYRENEWCERTSONCE` is set, renew will be run once and then the
  container exits

## Volumes

If you want to keep / use your certificates, you are advised to create
a volume below /etc/letsencrypt.

## Changelog

* 0.1.0: usable with automatic renewal
* 0.2.0: added support for nginx webserver (based on official nginx
  image)

## Kubernetes

See https://code.ungleich.ch/ungleich-public/ungleich-k8s/.

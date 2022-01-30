## ungleich-certbot

This container is made for getting **real world** certificates
for your kubernetes cluster.

The assumption is that you can point the DNS name to the container
from outside. This is by default given for **IPv6 only kubernetes
services**.

The source of this image can be found on
[code.ungleich.ch](https://code.ungleich.ch/ungleich-public/ungleich-certbot).

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
* If you setup the variable NO_NGINX to any value, the container will
  NOT start nginx and use certbot in standalone mode


```
docker run -e DOMAIN=example.com \
           -e EMAIL=root@example.com \
              ungleich/ungleich-certbot:1.1.1
```

### Production certificate

Use

```
docker run -e DOMAIN=example.com \
           -e EMAIL=root@example.com \
           -e STAGING=no \
              ungleich/ungleich-certbot:1.1.1
```

you will get a proper, real world usable nginx server. Inject the
nginx configuration by meains of a volume to /etc/nginx/conf.d

### Adding or overriding nginx configurations

To add your own nginx configurations, create the directory
/nginx-configs and add your configurations in there:

```
docker run -e DOMAIN=example.com \
           -e EMAIL=root@example.com \
           -v /path/to/config:/nginx-configs \
              ungleich/ungleich-certbot:1.1.1
```

By default this image is deploying the *default.conf*. If you want to
override the default image nginx configuration, you can supply your
own default.conf.

### Exiting after getting the certificate

By default, the container will stay alive and try to renew the
certificate every day. If you set the environment variable
`ONLYGETCERT`, then it will only get the certificates and exit.

This mode can be used
as a [kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/).

### Only renewing the certificate once

If you only want to trigger renewing existing certificates and skip
getting the certificates initially, you can set the variable
`RENEWCERTSONCE`, then it will only renew all certificates and exit.

* If `ONLYRENEWCERTSONCE` is set, renew will be run once and then the
  container exits

This mode can be used
as a [kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/).

## Volumes

If you want to keep / use your certificates, you are advised to create
a volume below /etc/letsencrypt.

## Changelog

### 0.1.0


Usable with automatic renewal

### 0.2.0

Added support for nginx webserver, based on official nginx image

### 1.0.0

- Start nginx in foreground, if not opted out
  - Nicely shows erros of nginx starting, which is what we need
- Starting nginx by default on port 80
- Removed variable NGINX to start nginx
- Introducted variable NO_NGINX to prevent nginx from starting
- Changed the wait time for domain resolution test to every 2 seconds
  - helps to startup faster
- Added directory /nginx from which configuration files are sourced
  - can be used to overwrite built-in configurations
- Create file /tmp/last_renew for checking when
- Dropped support for NGINX_HTTP_REDIRECT (always enabled with nginx
  now) -- can be overwritten by overriding /nginx directory
- Dropped support for ONLYRENEWCERTS - this is covered by NO_NGINX already

### 1.1.0

- Allow better way to inject configurations

### 1.1.1

- Fix incorrect configuration sourcing

### 1.1.2

- Add missing crond invocation


## Kubernetes

See https://code.ungleich.ch/ungleich-public/ungleich-k8s/.

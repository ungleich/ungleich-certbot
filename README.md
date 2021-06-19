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
* ungleich-certbot gets your certificate

## Volumes

If you want to keep / use your certificates, you are advised to create
a volume below /etc/letsencrypt.

## Kubernetes

Sample kubernetes usage: (TBD)

#!/bin/sh

set -e

docker build -t ungleich-certbot .

while [ $# -ge 1 ]; do
    tag=$1; shift
    git tag -a -m "Version $tag" $tag
    git push --tags
    docker tag ungleich-certbot:latest ungleich/ungleich-certbot:${tag}
    docker push ungleich/ungleich-certbot:${tag}

    # ungleich registry, slowly superseeding hub.docker.com
    url=harbor.ungleich.svc.p10.k8s.ooo/ungleich-public/ungleich-certbot
    docker tag ungleich-certbot:latest ${url}:${tag}
    docker push ${url}:${tag}
done

#!/bin/sh

if [ -z "$DOMAIN" -o -z "$EMAIL" ]; then
    echo Missing DOMAIN or EMAIL parameter - aborting. >&2
    exit 1
fi

if [ "$STAGING" = no ]; then
    STAGING=""
else
    STAGING="--staging"
fi

certbot certonly --agree-tos --cert-name "${DOMAIN}" \
        --email "$EMAIL" --expand --non-interactive \
        --domain "$DOMAIN" --standalone $STAGING

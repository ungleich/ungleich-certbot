#!/bin/sh

while [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; do
    certbot certonly --agree-tos --cert-name "${DOMAIN}" \
            --email "$EMAIL" --expand --non-interactive \
            --domain "$DOMAIN" --standalone $STAGING

    # If it failed, sleep before next try
    if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
        sleep 30
    fi

    # Correct permissions for multi user container/pod deployments
    # if not indicated otherwise
    if [ -z "$LEAVE_PERMISSIONS_AS_IS" ]; then
        find /etc/letsencrypt -type d -exec chmod 0755 {} \;
        find /etc/letsencrypt -type f -exec chmod 0644 {} \;
    fi
done

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

# Skip getting certs if requested
if [ -z "$ONLYRENEWCERTS" -a -z "$ONLYRENEWCERTSONCE" ]; then
    # Try to get a certificate, accept failures
    while [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; do
        certbot certonly --agree-tos --cert-name "${DOMAIN}" \
                --email "$EMAIL" --expand --non-interactive \
                --domain "$DOMAIN" --standalone $STAGING
        sleep 30

        # Correct permissions for multi user container/pod deployments
        # if not indicated otherwise
        if [ -z "$LEAVE_PERMISSIONS_AS_IS" ]; then
            find /etc/letsencrypt -type d -exec chmod 0755 {} \;
            find /etc/letsencrypt -type f -exec chmod 0644 {} \;
        fi
    done
fi

if [ "$ONLYGETCERT" ]; then
    exit 0
fi

# Try to renew once per day
while true; do
    /usr/bin/certbot renew


    # And again, correct permissions if not told otherwise
    if [ -z "$LEAVE_PERMISSIONS_AS_IS" ]; then
        find /etc/letsencrypt -type d -exec chmod 0755 {} \;
        find /etc/letsencrypt -type f -exec chmod 0644 {} \;
    fi

    [ "$ONLYRENEWCERTSONCE" ] && exit 0

    sleep 86400
done

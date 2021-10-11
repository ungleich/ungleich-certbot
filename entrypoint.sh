#!/bin/sh

if [ -z "$DOMAIN" -o -z "$EMAIL" ]; then
    echo Missing DOMAIN or EMAIL parameter - aborting. >&2
    exit 1
fi

# Check that the domain exists, if not wait for it
ipv6_addr=""
ipv4_addr=""

while [ -z "$ipv6_addr" -a -z "$ipv4_addr"  ]; do
    echo "Trying to resolve $DOMAIN via DNS ..."
    # Resolve for IPv6 and for IPv6
    ipv6_addr=$(dig +short "$DOMAIN" aaaa)
    ipv4_addr=$(dig +short "$DOMAIN" a)

    if [ "$ipv6_addr" -o "$ipv4_addr" ]; then
        echo "Resolved domain $DOMAIN: ipv6: $ipv6_addr ipv4: $ipv4_addr"
    else
        echo "Resolving $DOMAIN failed, waiting 5 seconds before retrying ..."
        sleep 5
    fi
done

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

# Still there? Start nginx if requested

if [ "$NGINX" ]; then
    nginx
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

    # reload nginx if we are running it
    [ "$NGINX" ] && pkill -1 nginx

    sleep 86400
done

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
        echo "Resolving $DOMAIN failed, waiting 2 seconds before retrying ..."
        sleep 2
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
fi

if [ "$ONLYGETCERT" ]; then
    exit 0
fi

# Before starting nginx, try to renew to ensure we are up-to-date
# This is necessary for container restarts not to delay a needed renew
/usr/bin/certbot renew --standalone

# If it requested to renew once only we are done here
[ "$ONLYRENEWCERTSONCE" ] && exit 0

if [ "$NO_NGINX" ]; then
    sleep infinity
else
    # First builtin
    cp /nginx/* /etc/nginx/conf.d

    # Then user provided
    if [ -d /nginx-configs ]; then
        cp /nginx-configs/* /etc/nginx/conf.d
    fi

    nginx -g "daemon off;"
fi

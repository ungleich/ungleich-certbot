#!/bin/sh

if [ "$NO_NGINX" ]; then
    /usr/bin/certbot renew --standalone
else
    /usr/bin/certbot renew --webroot --webroot-path /var/www/html
    # Reload nginx
    pkill -1 nginx
fi

# Correct permissions if not told otherwise
if [ -z "$LEAVE_PERMISSIONS_AS_IS" ]; then
    find /etc/letsencrypt -type d -exec chmod 0755 {} \;
    find /etc/letsencrypt -type f -exec chmod 0644 {} \;
fi

echo "Last renew: $(date)" > /tmp/last_renew

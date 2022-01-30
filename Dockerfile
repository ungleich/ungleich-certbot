FROM nginx:1.21.4-alpine

RUN mkdir -p /nginx /www_http
COPY nginx-http-redir.conf /nginx/default.conf

# For renewing the certificates
COPY renew_cert.sh /etc/periodic/daily/

RUN apk update && apk add certbot bind-tools

COPY entrypoint.sh  /
CMD ["/entrypoint.sh"]

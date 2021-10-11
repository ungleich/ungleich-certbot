FROM nginx:1.21.3-alpine

RUN apk update && apk add certbot bind-tools

COPY entrypoint.sh /
CMD ["/entrypoint.sh"]

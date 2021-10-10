FROM nginx:1.21.3-alpine

RUN apk update
RUN apk add certbot

COPY entrypoint.sh /
CMD ["/entrypoint.sh"]

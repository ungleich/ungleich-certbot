FROM alpine:3.14

RUN apk update
RUN apk add certbot

COPY entrypoint.sh /
CMD ["/entrypoint.sh"]

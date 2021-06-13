FROM alpine:3.13

RUN apk update
RUN apk add certbot

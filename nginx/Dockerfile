FROM debian:stable-slim

RUN apt update && apt install -y nginx tor && apt clean

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD nginx -g 'daemon off;'
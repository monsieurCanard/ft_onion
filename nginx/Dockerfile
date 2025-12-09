FROM debian:stable-slim

RUN apt update && apt install -y nginx tor tini && apt clean

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["tini", "--", "nginx", "-g", "daemon off;"]
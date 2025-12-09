FROM debian:stable-slim

RUN apt update && apt install -y tor curl && apt clean

COPY torrc /etc/tor/torrc

USER root

RUN mkdir -p /var/lib/tor/hidden_service
RUN chown -R 101:101 /var/lib/tor/hidden_service
RUN chmod 700 /var/lib/tor/hidden_service

USER debian-tor


CMD ["tor", "-f", "/etc/tor/torrc"]
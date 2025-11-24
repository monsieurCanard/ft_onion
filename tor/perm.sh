sudo chown -R 101:101 /var/lib/tor/hidden_service
sudo chmod 700 /var/lib/tor/hidden_service

exec "$@
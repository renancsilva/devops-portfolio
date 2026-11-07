#!/usr/bin/env bash
# First-time HTTPS: start Nginx with a temporary self-signed cert, request the real
# Let's Encrypt cert through the webroot, then reload Nginx. Run once, from the stack folder.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
: "${DOMAIN:?DOMAIN must be set in .env}"

live="/etc/letsencrypt/live/${DOMAIN}"
echo "==> Creating temporary certificate for ${DOMAIN}"
docker compose run --rm --entrypoint sh certbot -c "
  mkdir -p '${live}' &&
  openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout '${live}/privkey.pem' -out '${live}/fullchain.pem' -subj '/CN=localhost'"

echo "==> Starting Nginx"
docker compose up -d nginx

echo "==> Removing temporary certificate files"
docker compose run --rm --entrypoint sh certbot -c "
  rm -f '${live}/privkey.pem' '${live}/fullchain.pem' && rmdir '${live}'"

echo "==> Requesting Let's Encrypt certificate"
docker compose run --rm --entrypoint certbot certbot certonly --webroot -w /var/www/certbot \
  -d "${DOMAIN}" --email "${LETSENCRYPT_EMAIL}" --agree-tos --no-eff-email --rsa-key-size 4096

echo "==> Reloading Nginx"
docker compose exec nginx nginx -s reload
echo "Done: https://${DOMAIN}"

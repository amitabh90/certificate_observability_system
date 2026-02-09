#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-demo-app}"
HTTPS_PORT="${HTTPS_PORT:-8443}"
CERT_CN="${CERT_CN:-demo-app}"
CERT_DIR="/etc/nginx/certs"

# Create a simple page so each container looks different
cat > /var/www/html/index.html <<EOF
<html>
  <body style="font-family: Arial, sans-serif;">
    <h1>${APP_NAME}</h1>
    <p>HTTPS demo app with self-signed certificate</p>
  </body>
</html>
EOF

# Generate self-signed certificate (persist inside container FS; recreated on rebuild)
if [[ ! -f "${CERT_DIR}/tls.crt" || ! -f "${CERT_DIR}/tls.key" ]]; then
  echo "Generating self-signed certificate for CN=${CERT_CN} ..."
  openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes \
    -keyout "${CERT_DIR}/tls.key" \
    -out "${CERT_DIR}/tls.crt" \
    -subj "/CN=${CERT_CN}"
fi

# Run nginx (foreground disabled; we background it)
nginx -g "daemon off;" &

# Run telegraf in foreground (so container stays up)
exec telegraf --config /etc/telegraf/telegraf.conf

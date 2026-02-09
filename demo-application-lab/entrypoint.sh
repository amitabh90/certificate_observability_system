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

# Set certificate expiration days based on app name
case "${APP_NAME}" in
  "demo-app-1")
    CERT_DAYS=1
    ;;
  "demo-app-2")
    CERT_DAYS=10
    ;;
  "demo-app-3")
    CERT_DAYS=20
    ;;
  "demo-app-4")
    CERT_DAYS=30
    ;;
  *)
    CERT_DAYS=365  # Default fallback
    ;;
esac

# Generate self-signed certificate (persist inside container FS; recreated on rebuild)
if [[ ! -f "${CERT_DIR}/tls.crt" || ! -f "${CERT_DIR}/tls.key" ]]; then
  echo "Generating self-signed certificate for CN=${CERT_CN} with ${CERT_DAYS} days expiration..."
  
  # Create a config file for the certificate with IP SAN
  cat > /tmp/cert.conf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = ${CERT_CN}

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${CERT_CN}
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF

  openssl req -x509 -newkey rsa:2048 -sha256 -days ${CERT_DAYS} -nodes \
    -keyout "${CERT_DIR}/tls.key" \
    -out "${CERT_DIR}/tls.crt" \
    -config /tmp/cert.conf \
    -extensions v3_req
fi

# Run nginx (foreground disabled; we background it)
nginx -g "daemon off;" &

# Run telegraf in foreground (so container stays up)
exec telegraf --config /etc/telegraf/telegraf.conf

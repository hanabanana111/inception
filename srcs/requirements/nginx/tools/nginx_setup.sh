#!/bin/bash

set -eu

SSL_DIR="/etc/nginx/ssl"
ENV_FILE="/etc/nginx/.env"

if [ -z "${DOMAIN_NAME:-}" ]; then
	if [ -f "$ENV_FILE" ]; then
		set -a
		. "$ENV_FILE"
		set +a
	fi
fi

: "${DOMAIN_NAME:?DOMAIN_NAME is not set}"

mkdir -p "$SSL_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout "$SSL_DIR/inception.key" \
	-out "$SSL_DIR/inception.crt" \
	-subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}" \
	-addext "subjectAltName=DNS:${DOMAIN_NAME}"

echo "Generated a self-signed certificate for ${DOMAIN_NAME} in ${SSL_DIR}."

exec nginx -g "daemon off;"

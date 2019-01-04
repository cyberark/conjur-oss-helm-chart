#!/bin/bash -e

CERT_DIR="$PWD/certs"
DOMAIN="example.com"

mkdir -p "$CERT_DIR"

echo "Generating key..."
openssl genrsa -out "$CERT_DIR/example.key" 2048

echo "Generating crt from key..."
openssl req -new \
            -x509 \
            -key "$CERT_DIR/example.key" \
            -out "$CERT_DIR/example.crt" \
            -config openssl.conf

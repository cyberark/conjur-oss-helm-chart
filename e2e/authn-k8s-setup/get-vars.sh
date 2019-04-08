#!/bin/bash -e

set -o pipefail

if [ $# -lt 1 ]; then
  echo "ERROR: Service account name is required!"
  echo "Usage: $0 <service_account>"
  exit 1
fi

CURRENT_DIR=$(dirname $0)

echo "Getting API URL..."
API_URL="$($CURRENT_DIR/get-api-url.sh "$@")"

echo "Getting K8S CA cert..."
K8S_CA_CERT="$($CURRENT_DIR/get-k8s-ca.sh "$@")"

echo "Getting service account token..."
SERVICE_ACCOUNT_TOKEN="$($CURRENT_DIR/get-svc-acct-token.sh "$@")"

echo "Variables:"
echo "API_URL: $API_URL"
echo "K8S_CA_CERT: $K8S_CA_CERT"
echo "SERVICE_ACCOUNT_TOKEN: <redacted>"

echo "API_URL=\"$API_URL\"" > "$CURRENT_DIR/.env"
echo "K8S_CA_CERT=\"$K8S_CA_CERT\"" >> "$CURRENT_DIR/.env"
echo "SERVICE_ACCOUNT_TOKEN=\"$SERVICE_ACCOUNT_TOKEN\"" >> "$CURRENT_DIR/.env"

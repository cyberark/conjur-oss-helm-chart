#!/bin/bash -e

if [ $# -lt 1 ]; then
  echo "ERROR: Conjur authenticator path not specified!"
  echo "Usage: $0 <conjur_variable_prefix>"
  exit 1
fi

if [ ! -f .env ]; then
  echo "ERROR: '.env' file missing!"
  exit 1
fi

VARIABLE_PREFIX="$1"
echo "Using $VARIABLE_PREFIX as the prefix"

SEARCH_PATTERN="kubernetes/service-account-token"

echo "Checking that the prefix is valid..."
matching=$(conjur list -k variable -s="$SEARCH_PATTERN" | grep ":$VARIABLE_PREFIX/$SEARCH_PATTERN" | wc -l)

echo
echo "Found $matching result(s)"

if [ $matching -ne 1 ]; then
  echo "ERROR! Did not find a unique matching path!"
  exit 1
fi

source .env

echo
echo "Variables:"
echo "- API_URL: $API_URL"
echo "- K8S_CA_CERT: $K8S_CA_CERT"
echo "- SERVICE_ACCOUNT_TOKEN: <redacted>"

conjur variable values add "$VARIABLE_PREFIX/kubernetes/service-account-token" "$SERVICE_ACCOUNT_TOKEN"
conjur variable values add "$VARIABLE_PREFIX/kubernetes/ca-cert" "$K8S_CA_CERT"
conjur variable values add "$VARIABLE_PREFIX/kubernetes/api-url" "$API_URL"

echo "Done!"

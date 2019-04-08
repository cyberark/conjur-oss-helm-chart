#!/bin/bash -e

if [[ $# -lt 2 ]]; then
  echo "ERROR: Usage: $0 <hostname> <cert_dest>"
  exit 1
fi

HOSTNAME="$1"
SERVER_CERT_DEST="$2"

if [[ "${HOSTNAME}" =~ ^https?:// ]]; then
  echo "ERROR: Hostname should not be specified with scheme prefix!"
  exit 1
fi

echo "Saving cert from server ${HOSTNAME}:443 to ${SERVER_CERT_DEST}"
mkdir -p "$(dirname $SERVER_CERT_DEST)"
echo -n | openssl s_client -showcerts -connect $HOSTNAME:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $SERVER_CERT_DEST

if [ ! -f "$SERVER_CERT_DEST" ]; then
  echo "ERROR: Could not save server cert!"
  exit 1
fi

echo "Server cert was saved."

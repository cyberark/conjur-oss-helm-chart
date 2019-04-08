#!/bin/bash -e

# Parameter parsing and validation
if [ $# -lt 3 ]; then
  echo "ERROR! All args are required!"
  echo "Usage: $0 <seed_service_host> <seed_service_account> <seed_service_authn_id>"
  exit 1
fi

echo "* Building images..."
./build-oc-images.sh "$@"

echo "* Tagging and pushing images..."
./push-oc-images.sh "$@"

echo "* Deploying to OpenShift..."
./install-conjur-oc.sh "$@"

echo "*** DONE ***"

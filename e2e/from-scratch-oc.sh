#!/bin/bash -e

# Parameter parsing and validation
if [ $# -lt 1 ]; then
  echo "ERROR! Seedfile arg is required!"
  echo "Usage: $0 <seed_file>"
  exit 1
fi

echo "* Building images..."
./build-oc-images.sh "$@"

echo "* Tagging and pushing images..."
./push-oc-images.sh "$@"

echo "* Deploying to OpenShift..."
./install-conjur-oc.sh "$@"

echo "*** DONE ***"

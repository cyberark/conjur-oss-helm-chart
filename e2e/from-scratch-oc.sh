#!/bin/bash -e

echo "* Building images..."
./build-oc-images.sh

echo "* Tagging and pushing images..."
./push-oc-images.sh

echo "* Deploying to OpenShift..."
./install-conjur-oc.sh

echo "*** DONE ***"

#!/bin/bash -e

# This script runs the minimal helm test, without relies on external load balancers
# or persistent volumes. This is suitable for environment where these resources aren't
# available.

# Run helm test
# Any arguments passed to this script will be passed to `helm test`.

HELM_TEST_ARGS="${@:---cleanup}"  # cleanup test pod by default

RELEASE_NAME="helm-chart-test-$(date -u +%Y%m%d-%H%M%S)"

function finish() {
  echo "> Deleting release $RELEASE_NAME"
  helm del --purge $RELEASE_NAME
}
trap finish EXIT

echo "> Installing helm chart, waiting until app is ready..."
dataKey="$(docker run --rm cyberark/conjur data-key generate)"

# External load balancers and persistent volumes are not always available
# so they are turned off.
helm install --wait \
             --timeout 180 \
             --name $RELEASE_NAME \
             --set "dataKey=$dataKey" \
             --set "service.external.enabled=false" \
             --set "postgres.persistentVolume.create=false" \
             ./conjur-oss

echo "> Running helm tests with arguments: $HELM_TEST_ARGS"
helm test --logs $HELM_TEST_ARGS $RELEASE_NAME

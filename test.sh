#!/bin/bash -e

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
helm install --wait \
             --timeout 900 \
             --name $RELEASE_NAME \
             --set "dataKey=$dataKey" ./conjur-oss

echo "> Running helm tests with arguments: $HELM_TEST_ARGS"
helm test $HELM_TEST_ARGS $RELEASE_NAME

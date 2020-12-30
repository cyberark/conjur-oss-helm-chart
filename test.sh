#!/bin/bash

set -eo pipefail

source ./utils.sh

# Validate our schema before running tests
./ci/validate_schema.sh 

# Run Helm test
#
# This script does the following in sequence:
# - Runs a Helm install of a Conjur server
# - Runs a Helm test that deploys a test container that runs a
#   Bash Automated Test System (a.k.a. "Bats") test script that
#   confirms that the Conjur server's status page is active.
#
# Syntax:
#       ./test.sh <your-helm-test-args>
#
# Optional Environment Variables:
#   CONJUR_NAMESPACE:     Namespace to use for Conjur deployment. The
#                         namespace is created if it doesn't exist.
#   HELM_INSTALL_ARGS:    Additional arguments to pass to the `helm install`
#                         command beyond the standard arguments used below:
#                             --wait
#                             --timeout $HELM_INSTALL_TIMEOUT
#                             --set "dataKey=$dataKey"
#                         Defaults to empty string.
#   HELM_INSTALL_TIMEOUT: Helm install timeout. Defaults to `900` for
#                         Helm V2 and `900s` for newer versions of Helm.
#   HELM_TEST_LOGGING:    Set to true to enable Helm test log collection.
#                         Defaults to false.
#   RELEASE_NAME:         Name of Helm release to use for testing
#                         Defaults to "helm-chart-test-<date>-<time>"

# Command line arguments for this script are passed to `helm test`.
HELM_TEST_ARGS="$@"
HELM_INSTALL_ARGS=${HELM_INSTALL_ARGS:-""}
HELM_TEST_LOGGING=${HELM_TEST_LOGGING:-false}
if is_helm_v2; then
  HELM_INSTALL_TIMEOUT=${HELM_INSTALL_TIMEOUT:-900}
else
  HELM_INSTALL_TIMEOUT=${HELM_INSTALL_TIMEOUT:-900s}
fi
RELEASE_NAME=${RELEASE_NAME:-"helm-chart-test-$(date -u +%Y%m%d-%H%M%S)"}

# If Helm test logging is to be enabled, then we want to ensure that the
# test pod is not deleted until after Helm test has had a chance to display
# its logs.
if [ "$HELM_TEST_LOGGING" = "true" ]; then
  HELM_INSTALL_ARGS="${HELM_INSTALL_ARGS} --set test.deleteOnSuccess=false"
  HELM_TEST_ARGS="${HELM_TEST_ARGS} --logs"
fi

# For Helm version 2, test pods can be automatically deleted at the end
# of the helm test.
if is_helm_v2; then
  HELM_TEST_ARGS="${HELM_TEST_ARGS} --cleanup"
  HELM_DEL_ARGS="${HELM_DEL_ARGS} --purge"
fi

if [ ! -z "$CONJUR_NAMESPACE" ]; then
  if ! kubectl get namespace "$CONJUR_NAMESPACE" 2>/dev/null; then
    kubectl create namespace "$CONJUR_NAMESPACE"
  fi
  HELM_INSTALL_ARGS="${HELM_INSTALL_ARGS} --namespace $CONJUR_NAMESPACE"
  if ! is_helm_v2; then
    HELM_TEST_ARGS="${HELM_TEST_ARGS} --namespace $CONJUR_NAMESPACE"
    HELM_DEL_ARGS="${HELM_DEL_ARGS} --namespace $CONJUR_NAMESPACE"
  fi
fi

DATABASE_USER="postgres"
DATABASE_PASSWORD="postgres-password"

function delete_release() {
  announce "Deleting Conjur Helm release $RELEASE_NAME"
  echo "HELM_DEL_ARGS: $HELM_DEL_ARGS"
  if [ ! -z "$HELM_DEL_ARGS" ]; then
    helm del $HELM_DEL_ARGS "$RELEASE_NAME"
  else
    helm del "$RELEASE_NAME"
  fi
  if [ -z "$CONJUR_NAMESPACE" ]; then
    kubectl delete secrets --selector=release=$RELEASE_NAME
  else
    kubectl delete secrets -n "$CONJUR_NAMESPACE" --selector=release=$RELEASE_NAME
  fi
}

announce "Installing Conjur OSS, waiting until server is ready..."
data_key="$(docker run --rm cyberark/conjur data-key generate)"
echo "RELEASE_NAME: $RELEASE_NAME"
if is_helm_v2; then
  RELEASE_ARG="--name $RELEASE_NAME"
else
  RELEASE_ARG="$RELEASE_NAME"
fi
echo "RELEASE_ARG: $RELEASE_ARG"
echo "HELM_INSTALL_ARGS: $HELM_INSTALL_ARGS"
echo "HELM_INSTALL_TIMEOUT: $HELM_INSTALL_TIMEOUT"
echo "Helm Version: $(helm version)"
echo "Kubernetes Version: $(kubectl version)"
helm install --wait \
             --timeout $HELM_INSTALL_TIMEOUT \
             --set "dataKey=$data_key" \
             $HELM_INSTALL_ARGS \
             $RELEASE_ARG \
             ./conjur-oss
trap delete_release EXIT

announce "Running helm tests"
echo "HELM_TEST_ARGS: $HELM_TEST_ARGS"
helm test $HELM_TEST_ARGS "$RELEASE_NAME"

if  [[ (! is_helm_v2) && ("$HELM_TEST_LOGGING" == true) ]]; then
  # Test pod log has been displayed, so it's safe to delete the test pod.
  if [ -z "$CONJUR_NAMESPACE" ]; then
    kubectl delete pod -l release="$RELEASE_NAME"
  else
    kubectl delete pod -n "$CONJUR_NAMESPACE" -l release="$RELEASE_NAME"
  fi
fi

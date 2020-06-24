#!/bin/bash -e

source ./utils.sh

# This script runs the minimal helm test, without relies on external load
# balancers or persistent volumes. This is suitable for environment where
# these resources aren't available.
#
# This test also enables Helm test logging by default.

export HELM_INSTALL_ARGS="--set service.external.enabled=false \
                   --set postgres.persistentVolume.create=false"

export HELM_INSTALL_TIMEOUT="180"
if ! is_helm_v2; then
  # Helm v3 requires units for timeout values
  HELM_INSTALL_TIMEOUT+="s"
fi

export HELM_TEST_LOGGING=${HELM_TEST_LOGGING:-true}

./test.sh


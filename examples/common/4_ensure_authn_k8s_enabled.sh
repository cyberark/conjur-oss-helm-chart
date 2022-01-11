#!/bin/bash

set -euo pipefail

. utils.sh

# Ensure that $AUTHENTICATOR_ID is enabled for authn-k8s
authenticators="$(kubectl get secret \
                  -n $CONJUR_NAMESPACE \
                  $HELM_RELEASE-conjur-authenticators \
                  --template={{.data.key}} | base64 -d)"
if grep -q "$authenticators" <<< "$AUTHENTICATOR_ID"; then
  echo "Enabling authenticator ID $AUTHENTICATOR_ID for $AUTHN_STRATEGY"
  helm upgrade \
       -n "$CONJUR_NAMESPACE" \
       --reuse-values \
       --set authenticators="authn\,$AUTHN_STRATEGY/$AUTHENTICATOR_ID" \
       --set logLevel="$CONJUR_LOG_LEVEL" \
       --wait \
       --timeout 300s \
       "$HELM_RELEASE" \
       ../../conjur-oss

  # Wait for Conjur pods become ready
  wait_for_conjur_ready

else
  echo "Authenticator ID $AUTHENTICATOR_ID is already enabled for $AUTHN_STRATEGY"
fi

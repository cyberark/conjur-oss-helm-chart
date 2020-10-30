#!/bin/bash

set -euo pipefail

. utils.sh

# Ensure that $AUTHENTICATOR_ID is enabled for authn-k8s
authenticators="$(kubectl get secret \
                  -n $CONJUR_NAMESPACE \
                  $HELM_RELEASE-conjur-authenticators \
                  --template={{.data.key}} | base64 -d)"
if grep -q "$authenticators" <<< "$AUTHENTICATOR_ID"; then
  echo "Enabling authenticator ID $AUTHENTICATOR_ID for authn-k8s"
  helm upgrade \
       -n "$CONJUR_NAMESPACE" \
       --reuse-values \
       --set authenticators="authn\,authn-k8s/$AUTHENTICATOR_ID" \
       --set logLevel="$CONJUR_LOG_LEVEL" \
       "$HELM_RELEASE" \
       ../../conjur-oss

  # Pause to let Helm begin to terminate existing pods as a result
  # of Helm upgrade
  sleep 5

  # Wait for Conjur master pod to have both containers ready
  wait_for_conjur_ready

else
  echo "Authenticator ID $AUTHENTICATOR_ID is already enabled for authn-k8s"
fi

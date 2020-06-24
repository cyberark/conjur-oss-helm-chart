#!/bin/bash

set -eo pipefail

source ./utils.sh

HELM_RELEASE=${HELM_RELEASE:-conjur-oss}

if [ -z "$HELM_ARGS" ]; then
  # Generate database data-key
  data_key="$(docker run --rm cyberark/conjur data-key generate)"
  HELM_ARGS="$@ --set dataKey=$data_key"

  if is_helm_v2; then
    echo "Helm version is 2"
    HELM_ARGS="$HELM_ARGS --name $HELM_RELEASE"
  else
    echo "Helm version is 3 or newer"
    HELM_ARGS="$HELM_ARGS $HELM_RELEASE"
  fi
fi

if [ ! -z "$CONJUR_NAMESPACE" ]; then
  if ! kubectl get namespace "$CONJUR_NAMESPACE" 2>/dev/null; then
    kubectl create namespace "$CONJUR_NAMESPACE"
  fi
  HELM_ARGS="$HELM_ARGS --namespace $CONJUR_NAMESPACE"
fi

helm install $HELM_ARGS ./conjur-oss

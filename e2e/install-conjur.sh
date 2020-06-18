#!/bin/bash -e

data_key="$(docker run --rm cyberark/conjur data-key generate)"
helm_args="--set dataKey=$data_key"

if [ ! -z "$CONJUR_NAMESPACE" ]; then
  if ! kubectl get namespace "$CONJUR_NAMESPACE" 2>/dev/null; then
    kubectl create namespace "$CONJUR_NAMESPACE"
  fi
  helm_args="$helm_args -n $CONJUR_NAMESPACE"
fi

helm install $helm_args conjur-e2e ../conjur-oss

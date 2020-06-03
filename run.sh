#!/bin/bash -e

source ./is_helm_v2.sh

HELM_ARGS="$@"

if [ -z "$HELM_ARGS" ]; then
  data_key="$(docker run --rm cyberark/conjur data-key generate)"
  HELM_ARGS="--set dataKey=$data_key"
fi

if is_helm_v2; then
    HELM_ARGS="$HELM_ARGS --name conjur-oss"
else
    HELM_ARGS="$HELM_ARGS conjur-oss"
fi

helm install $HELM_ARGS ./conjur-oss

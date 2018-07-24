#!/bin/bash -e

HELM_ARGS="$@"

if [ -z "$HELM_ARGS" ]; then
  data_key="$(docker run --rm cyberark/conjur data-key generate)"
  HELM_ARGS="--set dataKey=$data_key"
fi

helm install $HELM_ARGS ./conjur-oss

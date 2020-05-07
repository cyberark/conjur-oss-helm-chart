#!/usr/bin/env bash

set -eo pipefail

source ../is-helm-v2.sh

if [ "$(which jq)" == "" ]; then
  echo "ERROR: Could not find jq utility!"
  exit 1
fi

helm_list_args="--output=json"
if [ ! -z "$CONJUR_NAMESPACE" ]; then
  helm_list_args="$helm_list_args -n $CONJUR_NAMESPACE"
fi
conjur_releases=$(helm list $helm_list_args | jq -r '.[] | select(.chart | match("conjur-oss-.*")) | .name')

if [ "${conjur_releases}" == "" ]; then
  echo "ERROR: Could not find any deployed Conjur releases!"
  exit 1
fi

for conjur_release in ${conjur_releases}; do
  echo "Deleting Conjur release '${conjur_release}'..."
  if is_helm_v2; then
    helm_del_args="$helm_del_args --purge"
  fi
  if [ ! -z "$CONJUR_NAMESPACE" ]; then
    helm_del_args="$helm_del_args -n $CONJUR_NAMESPACE"
  fi
  if [ -z "$helm_del_args" ]; then
    helm delete "${conjur_release}"
  else
    helm delete $helm_del_args "${conjur_release}"
  fi
  
  if [ -z "$CONJUR_NAMESPACE" ]; then
    kubectl delete secrets --selector="release=${conjur_release}"
  else
    kubectl delete secrets \
        -n "$CONJUR_NAMESPACE" \
        --selector="release=${conjur_release}"
  fi
done

echo "Done!"

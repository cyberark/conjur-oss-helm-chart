#!/bin/bash

set -euo pipefail

. utils.sh

check_env_var "KIND_CLUSTER_NAME"
min_kind_version="0.7.0"

# Confirm that 'kind' binary is installed.
if ! command -v kind &> /dev/null; then
  echo "kind binary not found. See https://kind.sigs.k8s.io/docs/user/quick-start/"
  echo "for installation instructions."
  exit 1
fi

# Check version of 'kind' binary.
kind_version="$(kind version -q)"
if ! meets_min_version $kind_version $min_kind_version; then
  echo "kind version $kind_version is invalid. Version must be $min_kind_version or newer"
  exit 1
fi

# Check if KinD cluster has already been created
if [ "$(kind get clusters | grep "^$KIND_CLUSTER_NAME$")" = "$KIND_CLUSTER_NAME" ]; then
  echo "KinD cluster '$KIND_CLUSTER_NAME' already exists. Skipping cluster creation."
else
  kind create cluster --name "$KIND_CLUSTER_NAME"
fi

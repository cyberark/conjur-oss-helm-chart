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
elif [[ $CREATE_DOCKER_INTERNAL_REGISTRY == "true" ]]; then 
  announce "Creating KinD Cluster with local registry"
  
  reg_name='kind-registry'
  reg_port='5000'
    
  # create registry container unless it already exists
  running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
  if [ "${running}" != 'true' ]; then
    docker run \
      -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" --net=kind \
      registry:2
  fi
  reg_ip="$(docker inspect -f '{{.NetworkSettings.Networks.kind.IPAddress}}' "${reg_name}")"
  echo "Registry IP: ${reg_ip}"

  # create a cluster with the local registry enabled in containerd
  cat <<EOF | kind create cluster --name "${KIND_CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches: 
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_ip}:${reg_port}"]
EOF

  export DOCKER_REGISTRY_URL="${reg_ip}:${reg_port}"
else
  kind create cluster --name "$KIND_CLUSTER_NAME"
fi

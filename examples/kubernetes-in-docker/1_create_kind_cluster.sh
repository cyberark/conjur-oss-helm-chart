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

registry_container_is_running() {
  "$(docker inspect -f '{{.State.Running}}' $DOCKER_LOCAL_REGISTRY_NAME 2>/dev/null || true)"
}
 
# Check if KinD cluster has already been created
if [ "$(kind get clusters | grep "^$KIND_CLUSTER_NAME$")" = "$KIND_CLUSTER_NAME" ]; then
  echo "KinD cluster '$KIND_CLUSTER_NAME' already exists. Skipping cluster creation."
  if [[ $USE_DOCKER_LOCAL_REGISTRY == "true" ]]; then
    if ! registry_container_is_running; then 
      echo "KinD cluster '$KIND_CLUSTER_NAME' does not have an internal Docker registry running"
      echo "and 'USE_DOCKER_LOCAL_REGISTRY' is set to 'true'. To use an"
      echo "internal Docker registry, please delete the KinD cluster:"
      echo "    kind delete cluster --name $KIND_CLUSTER_NAME"
      echo "and restart the demo scripts to create a new KinD cluster."
      exit 1
    fi
  fi
elif [[ $USE_DOCKER_LOCAL_REGISTRY == "true" ]]; then 
  announce "Creating KinD Cluster with local registry"
  
  reg_name="$DOCKER_LOCAL_REGISTRY_NAME"
  reg_port="$DOCKER_LOCAL_REGISTRY_PORT"
    
  # create registry container unless it already exists
  if ! registry_container_is_running; then
    docker run \
      -d --restart=always -p "${reg_port}:${reg_port}" --name "${reg_name}" --net=kind \
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

else
  kind create cluster --name "$KIND_CLUSTER_NAME"
fi

#!/bin/bash
set -euo pipefail

source ../utils.sh

# This script does the following in sequence:
# - Runs a Helm install of a Conjur OSS server
# - Runs a Helm test that deploys a test container that runs a
#   Bash Automated Test System (a.k.a. "Bats") test script that
#   confirms that the Conjur server's status page is active.
#
# Optional Environment Variables:
#   CONJUR_NAMESPACE:     Namespace to use for Conjur deployment. The
#                         namespace is created if it doesn't exist.
#   HELM_INSTALL_TIMEOUT: Helm install timeout in seconds.
#                         Defaults to `180`.
#   HELM_TEST_LOGGING:    Set to true to enable Helm test log collection.
#                         Defaults to false.
#   HELM_VERSION:         Helm client version to use for the test.
#                         Defaults to '3.1.3'.
#   KUBECTL_VERSION:      Kubectl client version to use for the test.
#                         Defaults to '1.16.9'.
#   SKIP_GCLOUD_LOGIN:    If set to 'true', then skip Gcloud authentication.
#                         This is useful for local testing whereby you've
#                         already authenticated with GCP and/or have 'kubectl'
#                         access to a cluster. Defaults to 'false'.

test_id="$(random_string)"

export CONJUR_NAMESPACE="${CONJUR_NAMESPACE:-conjur-oss-test-$test_id}"
export HELM_INSTALL_TIMEOUT="${HELM_INSTALL_TIMEOUT:-180}"
export HELM_TEST_LOGGING="${HELM_TEST_LOGGING:-true}"
export HELM_VERSION="${HELM_VERSION:-3.1.3}"
export KUBECTL_VERSION="${KUBECTL_VERSION:-1.16.9}"
export RELEASE_NAME="$CONJUR_NAMESPACE"
export SKIP_GCLOUD_LOGIN="${SKIP_GCLOUD_LOGIN:-false}"

announce "Building gcloud/kubectl/helm client image..."
# Build the gcloud/kubectl/helm client container image
tools_image_name="conjur-oss-helm-kubectl"
docker build -t "${tools_image_name}" \
             --quiet \
             --build-arg HELM_VERSION="$HELM_VERSION" \
             --build-arg KUBECTL_VERSION="$KUBECTL_VERSION" \
             -f Dockerfile \
             .

tmp_dir="$(pwd)/.tmp"
tmp_bin_dir="${tmp_dir}/bin"
mkdir -p "${tmp_bin_dir}" \
         "${tmp_dir}/.kube" \
         "${tmp_dir}/.config"
export PATH="${tmp_bin_dir}:${PATH}"

# Create a local alias for running 'gcloud' in client container
cat > "${tmp_bin_dir}/gcloud" <<EOF
  docker run --rm \
    --ipc="host" \
    -v "${tmp_dir}/.kube:/root/.kube" \
    -v "${tmp_dir}/.config:/root/.config" \
    --entrypoint /usr/bin/gcloud \
    "${tools_image_name}" \
    "\$@"
EOF
chmod +x "${tmp_bin_dir}/gcloud"

# Create a local alias for running 'helm' in client container
cat > "${tmp_bin_dir}/helm" <<EOF
  docker run --rm \
    -v "${tmp_dir}/.kube:/root/.kube" \
    -v "${tmp_dir}/.config:/root/.config" \
    -v "$(cd ../conjur-oss; pwd):/src/conjur-oss:ro" \
    --entrypoint /usr/local/bin/helm \
    "${tools_image_name}" \
    "\$@"
EOF
chmod +x "${tmp_bin_dir}/helm"

# Create a local alias for running 'kubectl' in client container
cat > "${tmp_bin_dir}/kubectl" <<EOF
  docker run --rm \
    -v "${tmp_dir}/.kube:/root/.kube" \
    -v "${tmp_dir}/.config:/root/.config" \
    --entrypoint /usr/local/bin/kubectl \
    "${tools_image_name}" \
    "\$@"
EOF
chmod +x "${tmp_bin_dir}/kubectl"

if [ "$SKIP_GCLOUD_LOGIN" = true ]; then
  cp "$HOME/.kube/config" "$tmp_dir/.kube/config"
  cp -r "$HOME/.config/gcloud" "$tmp_dir/.config/gcloud"
else
  announce "Logging in to GCP..."
  # It is assumed that the environment variables below are set by summon.
  docker run --rm \
             -e GCLOUD_CLUSTER_NAME \
             -e GCLOUD_PROJECT_NAME \
             -e GCLOUD_SERVICE_KEY="/tmp${GCLOUD_SERVICE_KEY}" \
             -e GCLOUD_ZONE \
             -e DOCKER_REGISTRY_URL \
             -e DOCKER_REGISTRY_PATH \
             -v "${tmp_dir}/.kube:/root/.kube" \
             -v "${tmp_dir}/.config:/root/.config" \
             -v "${GCLOUD_SERVICE_KEY}:/tmp${GCLOUD_SERVICE_KEY}" \
             -v "$(pwd):/src:ro" \
             "${tools_image_name}" \
             bash -c "./platform_login.sh"
fi

# Fix permissions on files created within Docker
docker run --rm \
           -v "${tmp_dir}/.kube:/root/.kube" \
           -v "${tmp_dir}/.config:/root/.config" \
           "${tools_image_name}" \
           bash -c "chown ${UID} -R /root/.kube/config /root/.config/*"

function delete_namespace {
  announce "Deleting namespace $CONJUR_NAMESPACE"
  kubectl delete namespace --ignore-not-found=true "$CONJUR_NAMESPACE"
}

if ! is_helm_v2; then
  # Helm v3 requires units for timeout values
  HELM_INSTALL_TIMEOUT+="s"
else
  helm init --upgrade
fi

announce "Deploying and testing Conjur OSS"
cd ..
trap delete_namespace EXIT
if ! ./test.sh; then
  announce "                 FAILED"
  exit 1
fi
announce "                 SUCCESS"

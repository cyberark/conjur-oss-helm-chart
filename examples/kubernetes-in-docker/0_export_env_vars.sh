# KinD install options
export CREATE_KIND_CLUSTER="${CREATE_KIND_CLUSTER:-true}"
export KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-kind}"

# Helm install options
export HELM_INSTALL_CONJUR="${HELM_INSTALL_CONJUR:-true}"
export HELM_RELEASE="${HELM_RELEASE:-conjur-oss}"
# The Conjur namespace name might be set with CONJUR_NAMESPACE_NAME in other
# projects so look for both. Use CONJUR_NAMESPACE_NAME if both are set.
export CONJUR_NAMESPACE="${CONJUR_NAMESPACE:-conjur-oss}"
export CONJUR_NAMESPACE="${CONJUR_NAMESPACE_NAME:-$CONJUR_NAMESPACE}"
export CONJUR_ACCOUNT="${CONJUR_ACCOUNT:-myConjurAccount}"
export CONJUR_LOG_LEVEL="${CONJUR_LOG_LEVEL:-info}"

# Basic demo config
export TEST_APP_DATABASE="${TEST_APP_DATABASE:-postgres}"
export TEST_APP_NAMESPACE_NAME="${TEST_APP_NAMESPACE_NAME:-app-test}"

# Configuration for Conjur authn-k8s
export ANNOTATION_BASED_AUTHN="${ANNOTATION_BASED_AUTHN:-true}"
export AUTHENTICATOR_ID="${AUTHENTICATOR_ID:-my-authenticator-id}"

# Conjur OSS Helm chart specific setting for demo scripts
export CONJUR_OSS_HELM_INSTALLED="${CONJUR_OSS_HELM_INSTALLED:-true}"

# KinD specific specific setting for demo scripts
export CONJUR_LOADBALANCER_SVCS="${CONJUR_LOADBALANCER_SVCS:-false}"
export TEST_APP_LOADBALANCER_SVCS="${TEST_APP_LOADBALANCER_SVCS:-false}"

# You can choose to have the scripts create a local, insecure Docker registry
# for pushing/pulling pod images by exporting the following:
#     export USE_DOCKER_LOCAL_REGISTRY=true
# Or you can use a public Docker registry (e.g. DockerHub) by exporting
# your Docker credentials.
#
# These can be configured/customized in customize.env
export USE_DOCKER_LOCAL_REGISTRY="${USE_DOCKER_LOCAL_REGISTRY:-true}"
export DOCKER_LOCAL_REGISTRY_NAME="${DOCKER_LOCAL_REGISTRY_NAME:-kind-registry}"
export DOCKER_LOCAL_REGISTRY_PORT="${DOCKER_LOCAL_REGISTRY_PORT:-5000}"
export DOCKER_REGISTRY_URL="${DOCKER_REGISTRY_URL:-localhost:${DOCKER_LOCAL_REGISTRY_PORT}}"
export DOCKER_REGISTRY_PATH="${DOCKER_REGISTRY_PATH:-${DOCKER_REGISTRY_URL}}"
if [[ "USE_DOCKER_LOCAL_REGISTRY" == "false" ]]; then
  check_env_var "DOCKER_USERNAME"
  check_env_var "DOCKER_PASSWORD"
  check_env_var "DOCKER_EMAIL"
fi

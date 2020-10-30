# KinD and Helm install options
export CREATE_KIND_CLUSTER="${CREATE_KIND_CLUSTER:-true}"
export KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-kind}"
export HELM_INSTALL_CONJUR="${HELM_INSTALL_CONJUR:-true}"
export HELM_RELEASE="${HELM_RELEASE:-conjur-oss}"
export CONJUR_NAMESPACE="${CONJUR_NAMESPACE:-conjur-oss}"
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
export TEST_APP_LOADBALANCER_SVCS="${TEST_APP_LOADBALANCER_SVCS:-false}"

# DockerHub account credentials are required since the demo scripts need to
# build and push demo images to a registry so that the images can then be
# pulled by KinD.
#
# These should be configured/customized in customize.env
export USE_DOCKER_LOCAL_REGISTRY="${USE_DOCKER_LOCAL_REGISTRY:-true}"
export DOCKER_REGISTRY_URL="${DOCKER_REGISTRY_URL:-localhost:5000}"
if [[ "USE_DOCKER_LOCAL_REGISTRY" == "false" ]]; then
  check_env_var "DOCKER_REGISTRY_URL"
  check_env_var "DOCKER_REGISTRY_PATH"
  check_env_var "DOCKER_USERNAME"
  check_env_var "DOCKER_PASSWORD"
  check_env_var "DOCKER_EMAIL"
fi

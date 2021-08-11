#!/bin/bash

. utils.sh

min_helm_version="3.1"

# Confirm that 'helm' binary is installed.
if ! command -v helm &> /dev/null; then
  echo "helm binary not found. See https://helm.sh/docs/intro/install/"
  echo "for installation instructions."
  exit 1
fi

# Check version of 'helm' binary.
helm_version="$(helm version --template {{.Version}} | sed 's/^v//')"
if ! meets_min_version $helm_version $min_helm_version; then
  echo "helm version $helm_version is invalid. Version must be $min_helm_version or newer"
  exit 1
fi

# Create the namespace for the Conjur cluster if necessary
if has_namespace "$CONJUR_NAMESPACE"; then
  echo "Namespace '$CONJUR_NAMESPACE' exists, not going to create it."
else
  kubectl create ns "$CONJUR_NAMESPACE"
fi

# Check if the Conjur cluster release has already been installed. If so, run
# Helm upgrade. Otherwise, do a Helm install of the Conjur cluster.
if [ "$(helm list -q -n $CONJUR_NAMESPACE | grep "^$HELM_RELEASE$")" = "$HELM_RELEASE" ]; then
  echo "Helm upgrading existing Conjur cluster. Waiting for upgrade to complete."
  args=("upgrade" "--reuse-values" )
else
  # Helm install a Conjur cluster and create a Conjur account
  echo "Helm installing a Conjur cluster. Waiting for install to complete."
  data_key="$(docker run --rm cyberark/conjur data-key generate)"
  args=("install" "--set" "dataKey=$data_key" )
fi

args+=("-n" "$CONJUR_NAMESPACE" \
      "--set" "account.name=$CONJUR_ACCOUNT" \
      "--set" "account.create=true" \
      "--set" "authenticators=authn\,authn-k8s/$AUTHENTICATOR_ID" \
      "--set" "logLevel=$CONJUR_LOG_LEVEL" \
      "--set" "service.external.enabled=$CONJUR_LOADBALANCER_SVCS" \
      "--wait" \
      "--timeout" "300s" )

if [[ "$PLATFORM" == "openshift" ]]; then
  args+=("--set" "image.repository=$IMAGE_REPOSITORY" \
         "--set" "image.tag=$IMAGE_TAG" \
         "--set" "fullnameOverride=conjur-oss" \
         "--set" "nginx.image.repository=$NGINX_REPOSITORY" \
         "--set" "nginx.image.tag=$NGINX_TAG" \
         "--set" "postgres.image.repository=$POSTGRES_REPOSITORY" \
         "--set" "postgres.image.tag=$POSTGRES_TAG" \
         "--set" "postgres.persistentVolume.create=$POSTGRES_PV_CREATE" \
         "--set" "rbac.create=true" \
         "--set" "openshift.enabled=$OPENSHIFT_ENABLED" )
fi

args+=("$HELM_RELEASE" \
      "../../conjur-oss")

echo "helm" "${args[@]}"

helm "${args[@]}"

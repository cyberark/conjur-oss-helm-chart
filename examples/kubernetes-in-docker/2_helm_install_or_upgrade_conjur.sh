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
  helm upgrade \
      -n "$CONJUR_NAMESPACE" \
      --set account.name="$CONJUR_ACCOUNT" \
      --set account.create="true" \
      --set authenticators="authn\,authn-k8s/$AUTHENTICATOR_ID" \
      --set logLevel="$CONJUR_LOG_LEVEL" \
      --reuse-values \
      "$HELM_RELEASE" \
      "../../conjur-oss"
else
  # Helm install a Conjur cluster and create a Conjur account
  data_key="$(docker run --rm cyberark/conjur data-key generate)"
  helm install \
      -n "$CONJUR_NAMESPACE" \
      --set dataKey="$data_key" \
      --set account.name="$CONJUR_ACCOUNT" \
      --set account.create="true" \
      --set authenticators="authn\,authn-k8s/$AUTHENTICATOR_ID" \
      --set logLevel="$CONJUR_LOG_LEVEL" \
      "$HELM_RELEASE" \
      "../../conjur-oss"
fi

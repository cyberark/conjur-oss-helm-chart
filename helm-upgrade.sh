#!/bin/bash

set -eo pipefail

# USAGE:
#      ./helm_upgrade.sh [set-chart-values-arguments]
#
# Note that for helm upgrades, any settings for the following chart values
# will be ignored:
#      dataKey
#      database.password
#      database.url
# since these values (and their Kubernetes respective secrets) will remain
# unchanged across Helm upgrades.

# For Helm upgrade operations, the --reuse-values command line flag must
# be used in order to preserve any non-default values that were used
# during helm install.
#
# Also, force the recreation of pods, since Helm isn't aware that pods need
# to be started e.g. for when configmaps or secrets are changed.
HELM_ARGS="$@ --reuse-values"

if [ ! -z "$CONJUR_NAMESPACE" ]; then
  HELM_ARGS="$HELM_ARGS -n $CONJUR_NAMESPACE"
fi

# Find the helm release (it will contain 'conjur-oss-' in its chart name)
helm_release=$(helm list --output=json | jq -r '.[] | select(.chart | match("conjur-oss-.*")) | .name')

helm upgrade $HELM_ARGS $helm_release ./conjur-oss

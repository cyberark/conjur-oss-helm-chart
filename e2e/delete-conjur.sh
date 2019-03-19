#!/usr/bin/env bash -e

set -o pipefail

if [ "$(which jq)" == "" ]; then
  echo "ERROR: Could not find jq utility!"
  exit 1
fi

CURRENT_CONTEXT="$(kubectl config current-context)"
CURRENT_CONTEXT="${CURRENT_CONTEXT%%\/*}"
if [ "$CURRENT_CONTEXT" == "" ]; then
  echo "ERROR: Could not find current kubectl context!"
  exit 1
fi

echo "WARN: Deleting all charts in '$CURRENT_CONTEXT' context..."

conjur_releases=$(helm list -c --namespace "$CURRENT_CONTEXT" --output=json | jq -r '.Releases[] | select(.Chart | match("conjur-oss-.*")) | .Name')

if [ "${conjur_releases}" == "" ]; then
  echo "ERROR: Could not find any deployed Conjur releases!"
  exit 1
fi

for conjur_release in ${conjur_releases}; do
  echo "Deleting Conjur release '${conjur_release}'..."
  helm delete --purge "${conjur_release}"
done

echo "Done!"

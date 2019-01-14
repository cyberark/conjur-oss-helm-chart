#!/usr/bin/env bash -e

set -o pipefail

if [ "$(which jq)" == "" ]; then
  echo "ERROR: Could not find jq utility!"
  exit 1
fi

conjur_releases=$(helm list -c --output=json | jq -r '.Releases[] | select(.Chart | match("conjur-oss-.*")) | .Name')

if [ "${conjur_releases}" == "" ]; then
  echo "ERROR: Could not find any deployed Conjur releases!"
  exit 1
fi

for conjur_release in ${conjur_releases}; do
  echo "Deleting Conjur release '${conjur_release}'..."
  helm delete --purge "${conjur_release}"
done

echo "Done!"

#!/bin/bash

set -euo pipefail

function log_in() {
  gcloud auth activate-service-account \
    --key-file "${GCLOUD_SERVICE_KEY}"
  gcloud container clusters get-credentials \
    "${GCLOUD_CLUSTER_NAME}" \
    --zone "${GCLOUD_ZONE}" \
    --project "${GCLOUD_PROJECT_NAME}"
  docker login "${DOCKER_REGISTRY_URL}" \
    -u oauth2accesstoken \
    -p "$(gcloud auth print-access-token)"
}

echo "Logging into GKE and Docker registry..."

attempt=0

log_in
until [[ "$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null)" != "" ]]; do
  echo -n '.'
  sleep 2

  attempt=$(( attempt + 1 ))
  if [ $attempt -gt 10 ]; then
    echo
    echo "ERROR: Could not log into Gcloud!"
    exit 1
  fi

  log_in
done

echo "Logged into remote resources."

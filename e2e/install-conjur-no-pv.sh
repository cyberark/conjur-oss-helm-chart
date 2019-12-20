#!/bin/bash -e

helm install conjur-e2e \
  --set dataKey="$(docker run --rm cyberark/conjur data-key generate)" \
  --set postgres.persistentVolume.create="false" \
  ../conjur-oss

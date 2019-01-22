#!/bin/bash -e

helm install \
  --set dataKey="$(docker run --rm cyberark/conjur data-key generate)" \
  --set postgres.persistentVolume.create="false" \
  ../conjur-oss

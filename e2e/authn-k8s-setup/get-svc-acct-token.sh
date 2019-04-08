#!/bin/bash -e

if [ $# -lt 1 ]; then
  echo "ERROR: Service account name is required!"
  echo "Usage: $0 <service_account>"
  exit 1
fi

kubectl get secret $(kubectl get serviceaccount "$1" -o json | jq -r ".secrets[1].name") -o json | jq -r '.data.token' | base64 -D

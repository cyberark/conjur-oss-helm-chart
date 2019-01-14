#!/bin/bash -e

kubectl create -f rbac-config.yaml

helm init --service-account tiller

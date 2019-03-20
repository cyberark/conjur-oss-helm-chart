#!/bin/bash -e

# Parameter parsing and validation
if [ $# -lt 1 ]; then
  echo "ERROR! Seedfile arg is required!"
  echo "Usage: $0 <seed_file>"
  exit 1
fi

SEED_FILE="$1"

if [ ! -f "$SEED_FILE" ]; then
  echo "ERROR! Seedfile path '$SEED_FILE' cannot be found!"
  exit 1
fi

# Meat of the deployment
echo "Gathering OpenShift configuration..."
OC_NAMESPACE="$(oc project -q)"
if [ "$OC_NAMESPACE" == "" ]; then
  echo "ERROR: Cannot detect OpenShift namespace/project!"
  exit 1
fi

OC_REPOSITORY="docker-registry.default.svc:5000/$OC_NAMESPACE"
TAG_NAME="oc-test"

./delete-conjur.sh || true

EXTRA_IMAGES=( "postgres"
         "nginx" )

IMAGE_PARAMS=""
for image_name in ${EXTRA_IMAGES[@]}; do
  IMAGE_PARAMS+=",$image_name.image.repository=$OC_REPOSITORY/$image_name"
  IMAGE_PARAMS+=",$image_name.image.tag=$TAG_NAME"
  IMAGE_PARAMS+=",$image_name.image.pullPolicy=Always"
done

IMAGE_PARAMS+=",image.repository=$OC_REPOSITORY/conjur"
IMAGE_PARAMS+=",image.tag=$TAG_NAME"
IMAGE_PARAMS+=",image.pullPolicy=Always"

HELM_VALUES="dataKey=\"$(docker run --rm cyberark/conjur data-key generate)\","
HELM_VALUES+="postgres.persistentVolume.create=false"
HELM_VALUES+="$IMAGE_PARAMS"

HELM_COMMAND="install"
if [ "$DEBUG" != "" ]; then
  HELM_COMMAND="template"
fi

set -x
helm "$HELM_COMMAND" -n "$USER-oc-testing" \
  --set $HELM_VALUES \
  --set-file "seedfile=$SEED_FILE" \
  ../conjur-oss

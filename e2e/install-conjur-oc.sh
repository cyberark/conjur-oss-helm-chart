#!/bin/bash -e

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

set -x
helm install -n "$USER-oc-testing" \
  --set dataKey="$(docker run --rm cyberark/conjur data-key generate)",postgres.persistentVolume.create="false"$IMAGE_PARAMS \
  ../conjur-oss

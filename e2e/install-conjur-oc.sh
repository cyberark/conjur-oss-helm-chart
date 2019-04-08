#!/bin/bash -e

# Parameter parsing and validation
if [ $# -lt 3 ]; then
  echo "ERROR! Seed arg is required!"
  echo "Usage: $0 <seed_service_host> <seed_service_account> <seed_service_authn_id>"
  exit 1
fi

SEED_SERVICE_HOST="$1"
SEED_SERVICE_ACCOUNT="$2"
SEED_SERVICE_AUTHENTICATOR_ID="$3"

# Meat of the deployment
echo "Gathering OpenShift configuration..."
OC_NAMESPACE="$(oc project -q)"
if [ "$OC_NAMESPACE" == "" ]; then
  echo "ERROR: Cannot detect OpenShift namespace/project!"
  exit 1
fi

OC_REPOSITORY="docker-registry.default.svc:5000/$OC_NAMESPACE"
TAG_NAME="oc-test"

HELM_DEPLOYMENT_NAME="$USER-oc-testing"
SERVICE_ACCOUNT_NAME="$HELM_DEPLOYMENT_NAME-conjur-oss"

./delete-conjur.sh || true

echo "Checking that we're logged in..."
if ! oc whoami >/dev/null; then
  echo "We're not logged in. Logging into $OC_REPOSITORY..."
  oc login
fi

echo "Saving server cert for seed-fetcher config..."
./save_server_cert.sh "$SEED_SERVICE_HOST" "./tmp/server.crt"

echo "Composing HELM command..."
EXTRA_IMAGES=( "nginx"
               "postgres"
               "seedfetcher"
               "syslogng" )

EXTRA_IMAGES_VALUES_NAME=( "nginx"
                           "postgres"
                           "seedService"
                           "syslogng" )

IMAGE_PARAMS=""
for image_index in ${!EXTRA_IMAGES[@]}; do
  image_name="${EXTRA_IMAGES[$image_index]}"
  value_name="${EXTRA_IMAGES_VALUES_NAME[$image_index]}"
  IMAGE_PARAMS+=",$value_name.image.repository=$OC_REPOSITORY/$image_name"
  IMAGE_PARAMS+=",$value_name.image.tag=$TAG_NAME"
  IMAGE_PARAMS+=",$value_name.image.pullPolicy=Always"
done

IMAGE_PARAMS+=",image.repository=$OC_REPOSITORY/conjur"
IMAGE_PARAMS+=",image.tag=$TAG_NAME"
IMAGE_PARAMS+=",image.pullPolicy=Always"

HELM_VALUES="account=$SEED_SERVICE_ACCOUNT,"
HELM_VALUES+="seedService.authenticatorId=$SEED_SERVICE_AUTHENTICATOR_ID,"
HELM_VALUES+="seedService.host=$SEED_SERVICE_HOST,"

HELM_VALUES+="dataKey=\"$(docker run --rm cyberark/conjur data-key generate)\","
HELM_VALUES+="postgres.persistentVolume.create=false,"
HELM_VALUES+="serviceAccount.name=$SERVICE_ACCOUNT_NAME"

HELM_VALUES+="$IMAGE_PARAMS"

HELM_COMMAND="install"
if [ "$DEBUG" != "" ]; then
  HELM_COMMAND="template"
fi

set -x
helm "$HELM_COMMAND" -n "$HELM_DEPLOYMENT_NAME" \
  --set $HELM_VALUES \
  --set-file "seedService.masterPublicCert=./tmp/server.crt" \
  ../conjur-oss
set +x
echo "Helm chart installed!"

# Exit early if we're just debugging templates
if [ "$DEBUG" != "" ]; then
  exit 0
fi

echo "Creating variables for authn-k8s importing..."
./authn-k8s-setup/get-vars.sh "$SERVICE_ACCOUNT_NAME"
echo "Exported the variables."
echo "** Ensure that these variables are set in conjur with authn-k8s-setup/set-conjur-vars.sh **"

#!/bin/bash -e

echo "Gathering OpenShift configuration..."
OC_USER="$(oc whoami)"
OC_NAMESPACE="$(oc project -q)"
OC_SERVER="$(oc whoami --show-server)"

# Strip scheme and port from api endpoint
OC_SERVER="${OC_SERVER##http*\/\/}"
OC_SERVER="${OC_SERVER%%:*}"

echo "Performing sanity checks..."
if [ "$OC_SERVER" == "" ]; then
  echo "ERROR: Could not detect OpenShift server!"
  exit 1
fi

if [ "$OC_NAMESPACE" == "" ]; then
  echo "ERROR: Cannot detect OpenShift namespace/project!"
  exit 1
fi

if [ "$OC_USER" == "" ]; then
  echo "ERROR: Cannot detect OpenShift user!"
  exit 1
fi

echo "OC Server: $OC_SERVER"
echo "OC Namespace: $OC_NAMESPACE"
echo "OC User: $OC_USER"

echo "Logging into the target docker repository..."
docker login -u "$OC_USER" -p "$(oc whoami -t)" "$OC_SERVER"

echo "Building individual images..."
for image_dir in ./openshift/*; do
  if [ ! -d "$image_dir" ]; then
    continue
  fi

  if [ ! -f "$image_dir/Dockerfile" ]; then
    continue
  fi

  # Used as: docker-registry.default.svc:5000/<namespace>/<image>:<tag>
  pushd "$image_dir" >/dev/null
    image_name="$(basename $image_dir)"
    oc_image_tag="$OC_SERVER/$OC_NAMESPACE/$image_name:oc-test"
    echo "Tagging and pushing $image_name image to $oc_image_tag..."
    docker tag "$image_name:oc-test" "$oc_image_tag"
    docker push "$oc_image_tag"
  popd

  echo
done

echo "Images uploaded!"

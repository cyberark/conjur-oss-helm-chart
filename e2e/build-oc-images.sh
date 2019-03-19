#!/bin/bash -e

for image_dir in ./openshift/*; do
  if [ ! -d "$image_dir" ]; then
    continue
  fi

  if [ ! -f "$image_dir/Dockerfile" ]; then
    continue
  fi

  pushd "$image_dir" >/dev/null
    image_name=$(basename $image_dir)
    echo "Building $image_name image..."
    docker build -t $image_name:oc-test .
  popd

  echo
done

echo "Builds done!"

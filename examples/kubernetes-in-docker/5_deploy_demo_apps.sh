#!/bin/bash

set -euo pipefail

. utils.sh

conjur_demo_scripts_path="temp/kubernetes-conjur-demo"

# Clone the conjurdemos/kubernetes-conjur-demo repo
rm -rf "$conjur_demo_scripts_path"
announce "Cloning Kubernetes Conjur Demo scripts to $conjur_demo_scripts_path"
mkdir -p temp
git clone https://github.com/conjurdemos/kubernetes-conjur-demo "$conjur_demo_scripts_path"

# Because the kubernetes-conjur-demo scripts use a different naming convention
# for the Conjur namespace env variable, some translation is required.
export CONJUR_NAMESPACE_NAME="$CONJUR_NAMESPACE"

announce "Running the Kubernetes Conjur Demo scripts"
cd "$conjur_demo_scripts_path"
./start

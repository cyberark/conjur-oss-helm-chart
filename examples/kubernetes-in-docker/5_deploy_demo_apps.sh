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

announce "Cleaning up test/validation deployments and pods"
# The 'test-app-with-host-outside-apps-branch-summon-init' deployment
# is used to test that authentication works with the Conjur host defined
# anywhere in the policy branch. It can be deleted now.
kubectl delete deployment -n "$TEST_APP_NAMESPACE_NAME" \
        test-app-with-host-outside-apps-branch-summon-init
if [[ "$TEST_APP_LOADBALANCER_SVCS" == "false" ]]; then
    kubectl delete pod -n "$TEST_APP_NAMESPACE_NAME" test-curl
fi

announce "Deployment of Conjur and demo applications is complete!"

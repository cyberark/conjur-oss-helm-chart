#!/bin/bash

set -euo pipefail

. utils.sh

master_pod="$(get_master_pod_name)"
echo "$(kubectl exec \
        -n "$CONJUR_NAMESPACE" \
        "$master_pod" \
        --container=conjur-oss \
        -- conjurctl role retrieve-key "$CONJUR_ACCOUNT":user:admin | tail -1)"

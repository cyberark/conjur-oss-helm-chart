#!/bin/bash

# Run from top level dir
cd "$(dirname $0)/.."

if jq -e . >/dev/null < ./conjur-oss/values.schema.json; then
    echo "Helm chart values schema is valid JSON." && exit 0
else
    echo "Helm chart values schema is not valid JSON." && exit 1
fi

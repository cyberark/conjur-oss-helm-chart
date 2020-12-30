#!/bin/bash

# Run from top level dir
cd "$(dirname $0)/.."

JSON=$(cat ./conjur-oss/values.schema.json)

if jq -e . >/dev/null 2>&1 <<<"${JSON}"; then
    echo "JSON Schema is valid." && exit 0
else
    echo "Failed to parse JSON, or got false/null" && exit 1
fi

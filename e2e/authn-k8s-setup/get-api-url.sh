#!/bin/bash -e

kubectl config view --minify -o json | jq -r '.clusters[0].cluster.server'

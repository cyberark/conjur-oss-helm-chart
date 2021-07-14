#!/usr/bin/env bash

check_env_var() {
  if [[ -z "${!1+x}" ]]; then
    echo "$1 must be exported before running these scripts."
    exit 1
  fi
}

announce() {
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo ""
  echo "$@"
  echo ""
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

conjur_master_labels() {
    echo "app=conjur-oss,release=$HELM_RELEASE"
}

conjur_postgres_labels() {
    echo "app=conjur-oss-postgres,release=$HELM_RELEASE"
}

get_master_pod_name() {
  pod_name=$(kubectl get pods \
             -n "$CONJUR_NAMESPACE" \
             -l "$(conjur_master_labels)" \
             -o jsonpath="{.items[0].metadata.name}")
  echo $pod_name
}

has_namespace() {
  if kubectl get namespace  "$1" > /dev/null; then
    true
  else
    false
  fi
}

wait_for_it() {
  local timeout=$1
  local spacer=2
  shift

  if ! [ $timeout = '-1' ]; then
    local times_to_run=$((timeout / spacer))

    echo "Waiting for '$@' up to $timeout s"
    for i in $(seq $times_to_run); do
      eval $@ > /dev/null && echo 'Success!' && return 0
      echo -n .
      sleep $spacer
    done

    # Last run evaluated. If this fails we return an error exit code to caller
    eval $@
  else
    echo "Waiting for '$@' forever"

    while ! eval $@ > /dev/null; do
      echo -n .
      sleep $spacer
    done
    echo 'Success!'
  fi
}

wait_for_conjur_ready() {
  echo "Waiting for Conjur pod to be ready"
  kubectl wait --for=condition=ready pod \
                     -n $CONJUR_NAMESPACE \
                     -l "$(conjur_master_labels)" \
                     --timeout 300s
  echo "Waiting for Postgres pod to be ready"
  kubectl wait --for=condition=ready pod \
                     -n $CONJUR_NAMESPACE \
                     -l "$(conjur_postgres_labels)" \
                     --timeout 300s
}

oldest_version() {
  v1=$1
  v2=$2

  echo "$(printf '%s\n' "$v1" "$v2" | sort -V | head -n1)"
}

meets_min_version() {
  actual_version=$1
  min_version=$2

  oldest="$(oldest_version $actual_version $min_version)"
  if [ "$oldest" = "$min_version" ]; then
    true
  else
    false
  fi
}

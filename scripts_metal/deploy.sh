#!/bin/bash

set -eu -o pipefail

timeout='60'
master_node='k3s-master-m'

cur_hashes="$(kubectl get node "$master_node" -o jsonpath='{.metadata.annotations.home-server-hashes}')"

compare_hash() {
  yaml="$1"
  hash=$(shasum "$yaml" | awk '{print $1}')

  if [[ "$cur_hashes" =~ $hash ]]
  then
    return 0
  else
    return 1
  fi
}

# Deploy all services if there is a template change
for yaml in templates/*.yaml
do
  if ! compare_hash "$yaml"
  then
    deploy_all=true
  fi
done

# Deploy individual service changes
for yaml in values_metal/*.yaml
do
  if ! compare_hash "$yaml" || [[ "${deploy_all:-}" == true ]]
  then
    name=$(grep '^name:' "$yaml" | awk '{print $2}')
    helm upgrade --install --atomic --timeout="${timeout}s" -f "$yaml" "$name" .
    made_changes=true
  fi
done

if [[ "${made_changes:-}" ]]
then
  new_hashes="$(find templates values_metal -type f -name '*.yaml' -exec shasum {} \+)"
  kubectl annotate node "$master_node" home-server-hashes="$new_hashes" --overwrite=true
fi
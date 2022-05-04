#!/bin/bash

set -eu -o pipefail

timeout='120'

# Deploy individual service changes
for yaml in values/*.yaml
do
  name=$(grep '^name:' "$yaml" | awk '{print $2}')
  diffs=$(helm diff upgrade -f "$yaml" "$name" . | wc -l)

  if (( diffs > 0 )); then
    helm upgrade --install --atomic --timeout="${timeout}s" -f "$yaml" "$name" .
  fi
done

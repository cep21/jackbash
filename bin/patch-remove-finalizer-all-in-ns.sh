#!/bin/bash
# Run with ns
set -exuo pipefail
if [ $# -ne 1 ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

NS="$1"

export DR="--dry-run=server"
if [[ "${DRY_RUN-}" == "false" ]]; then
  export DR=""
fi

kubectl api-resources --verbs=list --namespaced -o name   | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $NS -o=jsonpath='{range .items[*]}{.kind}{":"}{.metadata.name}{":"}{.metadata.namespace}{"\n"}{end}' | while IFS=':' read -r KIND OBJ NS ; do
  # Unsure why I need this
  KIND="${KIND#\'}"
  echo "$OBJ $NS"
  kubectl patch "$KIND" "$OBJ" --namespace "$NS" --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]' $DR 
done

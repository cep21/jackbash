#!/bin/bash
# Run with kubectl get autoscalingrunnersets.actions.github.com -A -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.namespace}{"\n"}{end}'
set -euo pipefail
if [ $# -ne 2 ]; then
  echo "Usage: $0 <crd-type> <namespace>"
  exit 1
fi

OBJ_TYPE="$1"
QUERY=( "kubectl" "get" "$1" )
if [[ "$2" == "-A" ]]; then
	QUERY+=("-A")
else
	QUERY+=("--namespace" "$2")
fi
QUERY+=("-o=jsonpath='{range .items[*]}{.metadata.name}{\":\"}{.metadata.namespace}{\"\\n\"}{end}'")
echo "${QUERY[@]}"
eval "${QUERY[@]}"

export DR="--dry-run=server"
if [[ "${DRY_RUN-}" == "false" ]]; then
export DR=""
fi

while IFS=':' read -r OBJ NS ; do
  # Unsure why I need this
  NS="${NS#\'}"
  OBJ="${OBJ#\'}"
  echo "$OBJ $NS"
  export DRY_RUN="--dry-run"
  kubectl patch "$1" "$OBJ" --namespace "$NS" --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]' "$DR"
done < <("${QUERY[@]}")

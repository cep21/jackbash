#!/bin/bash
set -euo pipefail

# Check for 4 arguments

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 <kind> <name> <release-name> <namespace>"
    exit 1
fi
KIND=$1
NAME=$2
RELEASE_NAME=$3
NAMESPACE=$4

# Verify namespace exists.  Fail with message if it does not.
if ! kubectl get namespace "$NAMESPACE"; then
    echo "Namespace $NAMESPACE does not exist"
    exit 1
fi

# Verify the object exists locally
if ! kubectl get "$KIND" "$NAME"; then
    echo "$KIND $NAME does not exist"
    exit 1
fi

kubectl annotate "$KIND" "$NAME" "meta.helm.sh/release-name=$RELEASE_NAME"
kubectl annotate "$KIND" "$NAME" "meta.helm.sh/release-namespace=$NAMESPACE"
kubectl label "$KIND" "$NAME" app.kubernetes.io/managed-by=Helm


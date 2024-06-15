#!/bin/bash
set -exuo pipefail
NS=$(kubectl config view --minify -o jsonpath='{..namespace}')
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n "$NS"
